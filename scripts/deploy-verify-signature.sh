#!/usr/bin/env bash
set -euo pipefail

IMAGE_URI="$1"

cosign verify \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate-identity-regexp "https://github.com/acme/payments-api/.github/workflows/release.yml@refs/heads/main" \
  "${IMAGE_URI}"
