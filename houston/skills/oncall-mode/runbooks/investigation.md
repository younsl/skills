### Investigation

Read-only. The deliverable is a cited answer, not a change.

1. Restate the question and the time window it covers. Ask once if the window or data source is unclear.
2. Map the path the question travels: caller, edge, gateway, load balancer, mesh, service, datastore. Name the owner and the data source of each hop.
3. Measure every hop for the same window. Mark a hop "not measured" rather than inferring it (**principle-its-always-dns**, **principle-trust-but-curl**).
4. Form candidate causes and eliminate them with evidence until one survives. Compare equal-length windows before and after any suspected change (**principle-before-and-after**).
5. When reproduction is needed, build the smallest repro on the real path. Leave repro resources up until the operator says to remove them (**principle-measure-twice-rm-once**).
6. For API timeouts reported by a caller, follow the **api-timeout-investigation** skill.
7. Cost questions: reconcile usage times unit price against the bill for the same window before naming a cause, then find the callers from audit or flow logs (**principle-its-always-dns**).
8. Network path questions: read route tables, security rules, and flow logs at each hop. Traffic leaving through NAT or a VPN shows the node address, not the pod, and meshed traffic arrives on the tunnel port, not the app port.
9. Load tests: tag the generated metrics with the labels the dashboards filter on, record the generator's rate next to the server's, and find the first resource that saturates (connection pool, worker threads, CPU) before reading the latency curve.
10. Audit and compliance questions: answer per resource from its live configuration, and name the guardrail that enforces it.

**Reply:** the answer first, then the evidence per hop with the query that produced each number, what was not measured, and the cheapest next check if the answer is not final.
