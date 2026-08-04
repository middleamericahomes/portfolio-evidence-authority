#!/usr/bin/env bash
set -euo pipefail

: "${CEREMONY:?CEREMONY is required}"
: "${SUBJECT_NAME:?SUBJECT_NAME is required}"
: "${SUBJECT_SHA256:?SUBJECT_SHA256 is required}"

case "$CEREMONY" in
  activation|retirement|execution-ledger) ;;
  *)
    echo "Invalid ceremony: $CEREMONY" >&2
    exit 1
    ;;
esac

if [[ ! "$SUBJECT_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "subject_sha256 must be exactly 64 lowercase hexadecimal characters" >&2
  exit 1
fi

expected_name="portfolio-evidence-${CEREMONY}-${SUBJECT_SHA256}.json"
if [[ "$SUBJECT_NAME" != "$expected_name" ]]; then
  echo "subject_name must be exactly $expected_name" >&2
  exit 1
fi

printf 'PASS ceremony=%s subject=%s digest=%s\n' \
  "$CEREMONY" "$SUBJECT_NAME" "$SUBJECT_SHA256"
