### IaC change

Terraform or Terragrunt resources and IAM policies.

1. Read the live resources and the current state before writing code. Someone may have changed them by hand (**principle-trust-but-curl**).
2. Write the code with the **terraform-generator** skill. Names and tags are literal in the unit that creates them (**principle-explicit-beats-clever**). IAM gets a dedicated policy per service and feature.
3. Run a plan that takes no lock and changes nothing. Any destroy or replace in the plan stops the run and is reported (**principle-measure-twice-rm-once**).
4. A teammate's unmerged change showing up as drift is not applied or reverted. Target your own resources or stop (**principle-not-your-diff**).
5. Hand the apply to the operator as an exact command with the target account, unless told to run it in this turn (**principle-no-friday-deploys**).
6. After apply, run the plan again and confirm zero changes. Run Shipping.

**Reply:** resources added, changed, destroyed with the plan excerpt, the apply command or its result, and the post-apply plan.
