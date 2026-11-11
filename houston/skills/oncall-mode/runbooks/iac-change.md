### IaC change

Terraform or Terragrunt resources and IAM policies. Every apply is non-destructive unless the request named the deletion.

1. Read the live resources and the current state before writing code. Someone may have changed them by hand (**principle-trust-but-curl**).
2. Write the code with the **terraform-generator** skill. Names and tags are literal in the unit that creates them (**principle-explicit-beats-clever**). IAM gets a dedicated policy per service and feature.
3. Check the plan with `tf-safe-apply --plan-only` from the **terraform-generator** skill's `scripts/`. It saves the plan and stops on any delete or replace that was not declared intended (**principle-measure-twice-rm-once**).
4. A stop means the code or the state is wrong, not that the check is in the way. Fix the cause and plan again. Pass `--allow-delete <address>` only for addresses the request asked to remove, and list them in the reply.
5. A teammate's unmerged change showing up as drift is not applied or reverted. Target your own resources or stop (**principle-not-your-diff**).
6. Apply only through `tf-safe-apply`, which applies exactly the checked plan and then requires a clean plan. Raw `apply`, `-auto-approve`, and `destroy` are blocked by the houston guard hook. Production and shared accounts get the exact `tf-safe-apply` command handed to the operator unless told to run it in this turn (**principle-no-friday-deploys**).
7. A post-apply plan that is not empty means drift or a provider default. Investigate it before calling the change done (**principle-proof-of-done**). Run Shipping.
8. Host configuration and machine images outside clusters follow the same shape: check mode and diff first, one host group at a time. Replace a single-instance group by raising desired capacity to two, waiting for target health, then removing the old instance.

**Reply:** resources added, changed, and destroyed with the plan check output, every `--allow-delete` address with the request that named it, the apply result, and the post-apply plan.
