### Right-sizing

Resource requests, limits, autoscaling, and capacity.

1. Pull usage for a representative window (p95 and max, CPU and memory, per container) from the metrics backend (**principle-its-always-dns**).
2. Size requests from the baseline with stated headroom. Change only components that already declare resources. Record skipped components as follow-ups (**principle-blast-radius**).
3. Keep the file's existing order and placement conventions for resource blocks (**principle-no-snowflakes**).
4. For peak events, size from the measured peak of the last comparable event, not a multiplier guess.
5. Ship per environment (Config change runbook). After rollout, compare usage, throttling, and OOM kills for the same window length (**principle-before-and-after**).

**Reply:** a table of component, old and new requests and limits, the usage numbers behind them, and the post-rollout comparison.
