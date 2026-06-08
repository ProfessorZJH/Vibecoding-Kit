# Git Checkpoint

Every task must end in one of:

```txt
COMMIT_CHECKPOINT
PUSH_CHECKPOINT
NO_COMMIT_CHECKPOINT
NO_PUSH_CHECKPOINT
```

Before work:

```bash
bash scripts/ai-preflight.sh T-xxx
git status --short
```

Before completion:

```bash
bash scripts/drift-guard.sh
bash scripts/task-closeout.sh T-xxx
git diff --check
```

Local commits are expected by default. Pushes are allowed for task branches.
Protected branches require explicit approval.
