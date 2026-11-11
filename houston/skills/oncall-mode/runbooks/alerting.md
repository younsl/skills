### Alerting

Alert rules, SLOs, and dashboard panels.

1. Read label names and values from the metrics API, not from cloud tags or naming conventions (**principle-trust-but-curl**).
2. Write the expression with the **promql-generator** skill. Run every query against live data and confirm it returns the expected series.
3. Alerts are code in the repo the team edits. Team dashboards live where the team maintains them. Ask when the request does not say (**principle-source-of-truth**).
4. Alert copy names the subject, the threshold, and the first action, in a sentence an on-call can act on (**principle-3am-reader**).
5. Prove the alert fires: evaluate it against a window where the condition held, or lower the threshold in a test rule and watch it fire.
6. Run Shipping.

**Reply:** the expression, the query result that proves it matches, the firing evidence, and the routing and severity.
