#!/usr/bin/env python3
"""Usage: scripts/eval-cases.py [SKILL]...

Render houston/skills/*/evals/evals.json into claude plugin eval cases under
houston/eval-cases/, then run from the repo root:
  claude plugin eval ./houston --eval-dir eval-cases --output-dir houston/eval-cases/results/<run>
"""
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "houston" / "skills"
OUT = ROOT / "houston" / "eval-cases"
MAX_TURNS = 25
TOOLS = "[Read, Glob, Grep, Skill]"
DRY_RUN = (
    "(Dry run: the working directory holds no code and nothing live is reachable. Do not ask "
    "for files or paths. Answer with the plan in order: the procedure you follow, what you read "
    "first, the exact commands you would run, and what you hand to the operator.)"
)
OFFLINE = (
    "The run has no access to live clusters, metrics backends, registries, cloud accounts, "
    "or Git hosts, and its tools are read-only. Grade the decisions and their order: which "
    "runbook or rule it follows, what it would read before acting, and what it hands to the "
    "operator instead of running. A response that names the exact read or command it would "
    "run counts as doing it. Fail a response that claims a live value it could not have read."
)


def render(skill, case):
    slug = f"{skill}-{case['name']}"
    case_dir = OUT / slug
    (case_dir / "graders").mkdir(parents=True)
    (case_dir / "prompt.md").write_text(
        f"---\nmax_turns: {MAX_TURNS}\nallowed_tools: {TOOLS}\n---\n\n{case['prompt']}\n\n{DRY_RUN}\n"
    )
    clauses = [c.strip().rstrip(".") for c in case["expected_output"].split("; ") if c.strip()]
    for index, clause in enumerate(clauses, 1):
        (case_dir / "graders" / f"criteria-{index:02d}.md").write_text(
            f"---\ntype: llm\nweight: 1\n---\n\n{clause}.\n\nJudge only this criterion. {OFFLINE}\n"
        )
    return len(clauses)


def main(selected):
    for results in OUT.glob("results"):
        shutil.move(results, OUT.parent / "eval-results-keep")
    if OUT.exists():
        shutil.rmtree(OUT)
    keep = OUT.parent / "eval-results-keep"
    OUT.mkdir()
    if keep.exists():
        shutil.move(keep, OUT / "results")
    files = sorted(SKILLS.glob("*/evals/evals.json"))
    if selected:
        files = [f for f in files if f.parent.parent.name in selected]
        missing = set(selected) - {f.parent.parent.name for f in files}
        if missing:
            sys.exit(f"error: no evals for {', '.join(sorted(missing))}")
    cases = graders = 0
    for path in files:
        data = json.loads(path.read_text())
        for case in data["evals"]:
            graders += render(data["skill_name"], case)
            cases += 1
    print(f"{cases} cases, {graders} graders in {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main(sys.argv[1:])
