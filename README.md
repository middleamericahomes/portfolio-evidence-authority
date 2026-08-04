# Portfolio Evidence Authority

This public repository is the external trust authority for MiddleAmericaHomes portfolio
evidence-runner receipts. It holds no private key, customer data, evidence payload, or scorer
output. GitHub Actions receives only a subject name and SHA-256 digest, then GitHub's OIDC and
Sigstore public-good service create an artifact attestation recorded in the public transparency
log.

The authority is intentionally fail-closed:

- only the immutable `authority-v1` tag may sign canonical receipts;
- the workflow and every action dependency are pinned to exact commits;
- the subject name must include the exact digest and ceremony type;
- verification pins this repository, workflow path, tagged source ref, signer commit, GitHub
  OIDC issuer, and GitHub-hosted runner.

## Dispatch

```sh
gh workflow run attest.yml \
  --repo middleamericahomes/portfolio-evidence-authority \
  --ref authority-v1 \
  -f ceremony=activation \
  -f subject_name=portfolio-evidence-activation-<sha256>.json \
  -f subject_sha256=<sha256>
```

The subject bytes never need to leave their controlled evidence workspace. The attestation
binds their exact digest.

## Verify

```sh
gh attestation verify <receipt.json> \
  --repo middleamericahomes/portfolio-evidence-authority \
  --signer-workflow middleamericahomes/portfolio-evidence-authority/.github/workflows/attest.yml \
  --source-ref refs/tags/authority-v1 \
  --signer-digest <authority-v1-commit> \
  --deny-self-hosted-runners
```

The caller must also preserve the downloaded Sigstore bundle and a fresh trusted-root snapshot
for durable offline verification.
Immutable GitHub Actions and Sigstore trust authority for portfolio evidence receipts
