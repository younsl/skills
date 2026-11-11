### Access change

SSO clients, identity provider integrations, user accounts, roles, and access grants on shared systems.

1. Find how the system manages identity today: an SSO client, a local account, a role mapping, or a cluster access entry. Read the live config, including default and wildcard mappings that grant more than the named role (**principle-trust-but-curl**).
2. Follow the existing client conventions: a description naming environment and platform, one client per app and environment, exact redirect URIs for the app's callback path, and the narrowest flow the app needs. A tool that logs in through a local callback gets a fixed callback port. An API that only validates tokens gets a bearer-only client and an audience mapper (**principle-precedent-before-guess**).
3. Client secrets and passwords go straight into the secret store, and the app reads them through its existing secret reference. Never in values files, tickets, or chat (**principle-no-secrets-in-argv**).
4. Changes through an admin API run from a script that reads the admin password from a prompt or stdin, and the operator runs it (**principle-no-friday-deploys**).
5. Grant the least role that does the job. A new role, policy, or mapping serves one service and feature (**principle-blast-radius**).
6. Verify with the identity that will use it: a login through the real flow, a token with the expected audience and claims, and one call that is denied without the grant.
7. For systems that keep identity config outside git, record what was created where in the ticket or the owning doc (**principle-source-of-truth**).

**Reply:** what was created or changed per system and environment, where each secret lives, and the allow and deny checks that prove it.
