#!/usr/bin/env bash
set -euo pipefail

IMAGE_URI="${1:?Usage: deploy-verify.sh IMAGE_URI}"
REPO="acme/payments-api"
SIGNER_WORKFLOW="acme/payments-api/.github/workflows/release.yml"

echo "1) Verify Sigstore signature"
cosign verify \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate-identity-regexp "https://github.com/${SIGNER_WORKFLOW}@refs/heads/main" \
  "${IMAGE_URI}" >/dev/null

# Verification uses GitHub API lookup by default (requires network access to
# api.github.com). For air-gapped or OCI-native verification, add
# --bundle-from-oci instead of -R. See:
# https://cli.github.com/manual/gh_attestation_verify
echo "2) Verify build provenance"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" \
  --signer-workflow "${SIGNER_WORKFLOW}" >/dev/null

echo "3) Verify SBOM attestation"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" \
  --signer-workflow "${SIGNER_WORKFLOW}" \
  --predicate-type "https://spdx.dev/Document/v2.3" >/dev/null

echo "4) Pull SBOM payload for policy checks"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" \
  --signer-workflow "${SIGNER_WORKFLOW}" \
  --predicate-type "https://spdx.dev/Document/v2.3" \
  --format json \
  --jq '.[].verificationResult.statement.predicate' > verified-sbom.json

echo "4a) Check SBOM contains package data"
jq -e '(.packages // .components) | length > 0' verified-sbom.json >/dev/null

echo "4b) Check all packages have non-empty names"
jq -e '[(.packages // .components)[] | select(.name == null or .name == "")] | length == 0' verified-sbom.json >/dev/null

echo "4c) Check all packages have versions"
jq -e '[(.packages // .components)[] | select(.versionInfo == null and .version == null)] | length == 0' verified-sbom.json >/dev/null

echo "4d) Check license information is present"
jq -e '[(.packages // .components)[] | select(.licenseConcluded != null or .licenseDeclared != null or .licenses != null)] | length > 0' verified-sbom.json >/dev/null

echo "All supply-chain checks passed"
