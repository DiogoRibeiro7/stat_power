# Security Policy

## Supported versions

`stat_power` is in its alpha series. Only the most recent release receives
fixes; there are no maintenance branches for older alphas.

| Version        | Supported |
| -------------- | --------- |
| 0.1.0.alpha.2  | yes       |
| < 0.1.0.alpha.2| no        |

## Reporting a vulnerability

Report suspected vulnerabilities privately through GitHub's
[private vulnerability reporting](https://github.com/DiogoRibeiro7/stat_power/security/advisories/new).
Do not open a public issue for a security report.

If you cannot use GitHub Security Advisories, email
dfr@esmad.ipp.pt with `stat_power security` in the subject.

Please include:

- the affected version
- a description of the issue and its impact
- a minimal reproduction

You can expect an acknowledgement within 7 days and a status update within 30
days. If a fix is warranted it will ship in a new release with the advisory
published once users have had a chance to upgrade.

## Scope

`stat_power` is a pure-Ruby numerical library with no runtime dependencies. It
performs no network access, no file system access and no deserialization of
untrusted input. The realistic security surface is therefore small.

Reports that are in scope include denial of service through unbounded solver
iteration on adversarial inputs, and any code path that evaluates or executes
caller-supplied data.

**A numerically incorrect result is a bug, not a vulnerability.** Report those
as ordinary issues so they can be discussed in public.
