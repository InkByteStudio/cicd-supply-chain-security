# cicd-supply-chain-security

Reference workflows, scripts, and templates for hardening CI/CD pipelines with Sigstore, SLSA, and SBOMs.

This is not an application. It is a reference kit of workflows, scripts, and templates you copy into your own CI/CD pipelines. Every file comes from the companion tutorial and is designed to be forked, adapted, and extended.

## Flow

```
Source → Build → Sign (Cosign) → Attest Provenance → Generate SBOM (Syft) → Attest SBOM → Verify → Deploy
```

## What's Included

| File | Purpose |
|---|---|
| `.github/workflows/release.yml` | Full GitHub Actions workflow: build, push, Cosign signing, provenance attestation, SBOM generation, SBOM attestation |
| `scripts/deploy-verify-signature.sh` | Pre-deploy signature verification gate |
| `scripts/deploy-verify.sh` | Comprehensive pre-deploy gate: signature + provenance + SBOM verification |
| `templates/pipeline-inventory.yaml` | Pipeline stage inventory template |
| `templates/third-party-trust-points.md` | Third-party trust point checklist |
| `templates/supply-chain-policy.yaml` | Minimum policy baseline (signing, provenance, SBOM required) |
| `templates/exception-request.md` | Policy exception workflow template |

## Prerequisites

- GitHub Actions (or adapt for your CI platform)
- [Cosign](https://docs.sigstore.dev/cosign/overview/) CLI
- [Syft](https://github.com/anchore/syft) SBOM generator
- A container registry (the example uses GHCR)
- GitHub CLI (`gh`) for attestation verification

## Quick Start

1. Fork this repository
2. Copy `.github/workflows/release.yml` into your project
3. Update the environment variables:
   - `IMAGE_NAME` — your container image path
   - Registry login credentials
4. Update the certificate identity in verification scripts to match your repo and workflow
5. Copy `scripts/deploy-verify.sh` into your deployment pipeline
6. Review and adapt `templates/supply-chain-policy.yaml` for your org

## Adapt for Your Pipeline

- **Different CI platform**: The signing and verification patterns are the same. Replace GitHub Actions syntax with your platform's equivalent. Use Cosign for signing and `gh attestation verify` or `cosign verify-attestation` for verification.
- **Different artifact type**: If you ship release binaries instead of container images, use `cosign sign-blob` and adapt the SBOM generation to scan the filesystem instead of the image.
- **Different SBOM format**: Replace `spdx-json` with `cyclonedx-json` in the Syft command if your tooling prefers CycloneDX.
- **Kubernetes admission**: Add Sigstore policy-controller for admission-time enforcement.

## Related

- [Tutorial: Harden Your CI/CD Pipeline with Sigstore, SLSA, and SBOMs](https://igotasite4that.com/tutorials/harden-cicd-pipeline-sigstore-slsa-sboms)
- [Blog: Software Supply Chain Security in the AI Era](https://igotasite4that.com/blog/software-supply-chain-security-ai)

## License

MIT
