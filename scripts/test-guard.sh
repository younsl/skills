#!/usr/bin/env bash
# Usage: scripts/test-guard.sh
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
guard=houston/hooks/guard.sh
fail=0

expect() {
  local want="$1" cmd="$2" got
  got="$(jq -n --arg c "$cmd" '{tool_input: {command: $c}}' | CLAUDE_PLUGIN_ROOT=/plugin bash "$guard" | jq -r '.hookSpecificOutput.permissionDecision // "none"')"
  got="${got:-none}"
  if [[ "$got" != "$want" ]]; then
    printf 'FAIL want=%s got=%s: %s\n' "$want" "$got" "$cmd" >&2
    fail=1
  fi
}

expect none 'terraform plan -out=tfplan'
expect none 'terraform state list'
expect none 'terragrunt hcl validate'
expect none 'git commit -m "terraform apply docs"'
expect none 'kubectl get pods'
expect none '/plugin/skills/terraform-generator/scripts/tf-safe-apply'
expect none 'tf-safe-apply --plan-only'
expect deny 'terraform apply'
expect deny 'terraform apply tfplan'
expect deny 'cd infra && terraform -chdir=a apply -auto-approve'
expect deny 'tofu apply'
expect deny 'terragrunt run-all apply'
expect deny 'terragrunt run --all -- apply'
expect deny 'echo ok; TF_LOG=1 terraform apply'
# shellcheck disable=SC2016
expect deny 'echo $(terraform apply)'
expect deny '(cd a && terraform apply)'
expect deny 'tf-safe-apply --plan-only && terraform apply'
expect ask 'terraform destroy -target=aws_s3_bucket.x'
expect ask 'terraform apply -destroy'
expect ask 'terragrunt destroy'
expect ask 'terraform state rm aws_s3_bucket.x'
expect ask 'terraform import aws_s3_bucket.x bucket'
expect ask 'tf-safe-apply --allow-delete aws_s3_bucket.x'

if ((fail)); then
  exit 1
fi
echo "guard ok"
