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
expect ask 'git commit -m "terraform apply docs"'
expect none 'git commit -m "docs: describe the plan check"'
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
expect deny 'sudo -u ops terraform apply'
expect deny 'time -p terraform apply'
expect deny 'terraform "apply"'
expect deny 'terraform \apply'
expect deny 'terraform apply &'
expect deny 'true & terraform apply'
expect deny 'if true; then terraform apply; fi'
expect deny '{ terraform apply; }'
expect deny "$(printf 'terraform plan\nterraform apply')"
expect deny 'terragrunt apply-all'
expect deny 'bash -c "terraform apply"'
expect deny 'TF_IN_AUTOMATION=1 /usr/local/bin/terraform apply'
# shellcheck disable=SC2016
expect ask 'eval "$CMD terraform"'
expect ask 'watch terraform plan'
expect ask 'terragrunt destroy-all'
expect ask 'terraform apply -destroy=true'
expect ask 'echo terraform apply'
expect ask 'grep -r "terraform apply" docs'
expect none 'grep -r "terraform plan" docs'
expect ask 'git -c alias.x="!terraform apply" x'
expect ask 'sed -n "1e terraform apply" file'
# shellcheck disable=SC2016
expect ask 'TF=terraform; $TF apply'
expect deny 'Terraform apply'
expect deny 'TOFU APPLY'
expect none 'ls ~/.terraform.d'
expect none 'cat skills/terraform-generator/SKILL.md'
expect ask 'terraform destroy -target=aws_s3_bucket.x'
expect ask 'terraform apply -destroy'
expect ask 'terragrunt destroy'
expect ask 'terraform state rm aws_s3_bucket.x'
expect ask 'terraform import aws_s3_bucket.x bucket'
expect ask 'tf-safe-apply --allow-delete aws_s3_bucket.x'

nojq="$(mktemp -d)"
trap 'rm -rf "$nojq"' EXIT
for t in tr basename dirname; do
  ln -s "$(command -v "$t")" "$nojq/$t"
done
got="$(printf '{"tool_input":{"command":"terraform apply"}}' | PATH="$nojq" "$BASH" "$guard")"
if [[ "$got" != *'"permissionDecision":"ask"'* ]]; then
  echo "FAIL without jq: want ask, got: ${got:-none}" >&2
  fail=1
fi

if ((fail)); then
  exit 1
fi
echo "guard ok"
