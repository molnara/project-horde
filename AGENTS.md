# Project Horde — Codex Instructions

The [Project Horde Constitution](.specify/memory/constitution.md), currently
v1.0.0, is the authoritative source of engineering principles. Follow it and
surface conflicts to the product owner; these instructions do not replace it.

- Before implementation, read the constitution and relevant feature specifications,
  plans, and tasks. Keep changes aligned with the active feature's scope and acceptance criteria.
- Follow the Spec Kit workflow: specification → plan → tasks → implementation → verification.
- Use Godot 4.7.2 Standard Edition and GDScript. Do not use C#.
- Prefer small, independently verifiable changes that advance the current playable slice.
- Use headless Godot validation whenever applicable, including project loading,
  script parsing, and relevant scene startup. Provide manual playtest steps for
  controls, visuals, and game feel.
- After modifying code, run relevant tests and report the commands and actual results.
  Distinguish passed, failed, skipped, blocked, and unrun checks. Never claim a test
  passed unless it executed successfully; explain unavailable checks and outstanding verification.
- Check optional files and environment variables for existence before accessing them.
  Handle expected absence explicitly rather than suppressing errors.
- Investigate unexpected nonzero command exit codes and explain the failing
  subcommand, cause, and effect on the task before claiming completion.
- Do not create, modify, move, or delete files outside the project workspace without
  explicit approval, including installations, global configuration, caches, and temporary output.
- Preserve existing user changes and avoid unrelated edits.
- Do not introduce unnecessary dependencies or plugins. Justify any addition with
  a present need and why existing code or built-in Godot facilities are insufficient.
- Preserve Project Horde's original game assets and creative identity. Use Megabonk
  only for broad gameplay inspiration; do not copy its distinctive creative content.
  Follow the active specification's asset restrictions and record asset provenance.
- Do not commit generated caches, import output, credentials, secrets, temporary
  files, or machine-specific state.
- Do not make Git commits automatically. Commit only when explicitly requested.
