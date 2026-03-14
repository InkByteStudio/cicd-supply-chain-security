#!/usr/bin/env bash
set -euo pipefail

IMAGE_URI="$1"
REPO="acme/payments-api"

echo "1) Verify Sigstore signature"
cosign verify \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate-identity-regexp "https://github.com/acme/payments-api/.github/workflows/release.yml@refs/heads/main" \
  "${IMAGE_URI}" >/dev/null

echo "2) Verify build provenance"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" >/dev/null

echo "3) Verify SBOM attestation"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" \
  --predicate-type "https://spdx.dev/Document/v2.3" >/dev/null

echo "4) Pull SBOM payload for policy checks"
gh attestation verify \
  "oci://${IMAGE_URI}" \
  -R "${REPO}" \
  --predicate-type "https://spdx.dev/Document/v2.3" \
  --format json \
  --jq '.[].verificationResult.statement.predicate' > verified-sbom.json

# Check that the SBOM contains package data (SPDX uses .packages, CycloneDX uses .components)
jq -e '.packages // .components | length > 0' verified-sbom.json >/dev/null

echo "All supply-chain checks passed"
