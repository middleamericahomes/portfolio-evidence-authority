#!/usr/bin/env bash
set -euo pipefail

validator="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/validate-dispatch.sh"
digest="22ae0c11ebd96834b38ad5bca6fe3dea29ea2d445cf40ebdd9157c859743ee4d"
uppercase_digest="$(printf '%s' "$digest" | tr '[:lower:]' '[:upper:]')"

pass() {
  CEREMONY="$1" \
  SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="portfolio-evidence-$1-$digest.json" \
  "$validator" >/dev/null
}

reject() {
  local label="$1"
  shift
  if env "$@" "$validator" >/dev/null 2>&1; then
    echo "FAIL accepted adversarial case: $label" >&2
    exit 1
  fi
  printf 'EXPECTED REJECT: %s\n' "$label"
}

pass activation
pass retirement
pass execution-ledger

reject unknown-ceremony \
  CEREMONY=score SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="portfolio-evidence-score-$digest.json"
reject uppercase-digest \
  CEREMONY=activation SUBJECT_SHA256="$uppercase_digest" \
  SUBJECT_NAME="portfolio-evidence-activation-$uppercase_digest.json"
reject short-digest \
  CEREMONY=activation SUBJECT_SHA256="${digest:0:63}" \
  SUBJECT_NAME="portfolio-evidence-activation-${digest:0:63}.json"
reject traversal-name \
  CEREMONY=activation SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="../portfolio-evidence-activation-$digest.json"
reject mismatched-digest-name \
  CEREMONY=activation SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="portfolio-evidence-activation-${digest%?}0.json"
reject ceremony-name-confusion \
  CEREMONY=retirement SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="portfolio-evidence-activation-$digest.json"
reject extension-confusion \
  CEREMONY=activation SUBJECT_SHA256="$digest" \
  SUBJECT_NAME="portfolio-evidence-activation-$digest.json.exe"
reject missing-name \
  CEREMONY=activation SUBJECT_SHA256="$digest" SUBJECT_NAME=

echo "PASS controls=3 adversarial_rejections=8"
