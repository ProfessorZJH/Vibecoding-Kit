# Adapter Block Demo

This demo shows `adapter-block.sh` replacing only the Vibecoding Kit managed
block while preserving user-owned content around it.

Scenario:

1. Create a target adapter file with user header/footer and old kit content.
2. Create a template adapter file with template header/footer and new kit
   content.
3. Validate the target managed block.
4. Update the target from the template managed block.
5. Verify user content is preserved and template outer content is not copied.

Run from the repository root:

```bash
bash examples/adapter-block-demo/run-demo.sh
```

Key output:

```txt
DEMO_STEP check_valid_block
DEMO_STEP update_managed_block
DEMO_STEP user_content_preserved
DEMO_PASS
```

The demo uses temporary files and deletes them on exit.
