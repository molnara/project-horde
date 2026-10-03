# Phase 1 setup and verification

Implemented: feature `001-core-gameplay-prototype`, T001–T004 only.
The main scene is an empty `Node3D`. Definitions, gameplay, visual placeholders,
the native suite and the full diagnostic classifier remain later tasks.
This phase establishes no gameplay or performance acceptance.

Run from the workspace root:

```powershell
& ./tools/validate.ps1 -Mode All
# Optional explicit absolute Windows console executable:
& ./tools/validate.ps1 -GodotBin $verifiedConsolePath -Mode All
```

Without an override, discovery selects the first nonempty `GODOT_BIN` in
Process → User → Machine order. An invalid explicit override never falls back.
Inaccessible scope reads block with a diagnostic; supply an explicit path if
sandbox registry isolation hides persistent values. The launcher verifies the
PE console subsystem, official 4.7.2 stable version, Standard edition and CLI
help. No installation or persistent environment change is made.

Each invocation creates ignored `.cache/validation/<session>/` output. Process
APPDATA, LOCALAPPDATA, TEMP and TMP are redirected there, then prior present/
absent values restored in `finally`. Every command receives an absolute workspace
log path. Commands, exits, outcomes, warnings and original output are retained
in separate stdout/stderr/engine logs and `results.json`.

Before the real project runs, an isolated generated editor project under
`.cache/` imports only a path-report plugin. The plugin queries actual OS user/
data/config/cache and `EditorInterface.get_editor_paths()` locations. Absolute
paths, containment and reparse-point ancestors are checked, and observed paths
are retained in `verified-paths.json`. External self-contained markers that
would redirect editor data outside `.cache/` block launch. No external marker is
created. The real project must retain the verified `Project Horde` name and
non-custom user-directory policy, with contained source and `.godot/` paths.
The isolated probe is the only editor project executed before the real-project
gate; no game resources or plugins run in that probe.

This follows Godot's documented [data paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html)
and [editor path API](https://docs.godotengine.org/en/stable/classes/class_editorpaths.html).
Environment redirection was verified against the selected executable.

`All` imports first, checks every project/test `.gd` with `--check-only`, runs
`res://tests/run_tests.gd` when present, and starts main with `--quit-after 120`.
Generated cache/probe and workflow directories are excluded from source parsing.
Missing prerequisites return nonzero. A missing suite is BLOCKED while independent
bootstrap startup still runs. No source scripts means parsing is SKIPPED.
The initial severity guard rejects recognized engine errors even on exit zero;
the complete fixture-tested classifier and expected-fault policy remain T011.

| Check | Default per-command limit | Override |
|---|---:|---|
| Version, help, path preflight | 30 s | `-PreflightTimeoutSeconds` |
| Import | 180 s | `-ImportTimeoutSeconds` |
| Each script parse | 30 s | `-ParseTimeoutSeconds` |
| Suite | 120 s | `-SuiteTimeoutSeconds` |
| Main startup | 30 s | `-StartupTimeoutSeconds` |

Timeouts fail and kill only the launched console child; the official wrapper
closes its owned engine job. Diagnostics remain. Investigate before explicitly
overriding a limit and retrying. `Play`/`Profile` have no automatic timeout.
`Play` currently opens the empty bootstrap. `Profile` blocks until the later
capture component exists, then passes `--profile` as a user argument with engine
log switches preceding the user-argument delimiter.

## Actual results — 2026-10-02 (America/Toronto)

Initial Git status was clean. Requirements-quality gates passed: requirements
16/16, technical 36/36. `.specify/extensions.yml` was absent at both hook checks.

| Executed command/check | Actual outcome |
|---|---|
| `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` | PASSED, exit 0; correct absolute feature directory and design documents |
| PowerShell `Parser.ParseFile` on `tools/validate.ps1` | PASSED; zero syntax errors |
| `tools/validate.ps1 -GodotBin <verified console path> -Mode All` outside sandbox isolation | Version/help/paths/import/startup PASSED, each exit 0; aggregate exit 1 solely because T010 suite is absent |
| Version subprocess `--headless --version` | PASSED; `4.7.2.stable.official.ed1daf0bf`, exit 0; probe reported `mono=false` |
| Isolated path subprocess `--headless --path <preflight> --import` | PASSED; user/data/config/cache/editor data/config/cache under workspace `.cache/`, editor project path under preflight |
| Import `--headless --path <workspace> --import` | PASSED, exit 0; no error diagnostics |
| Startup `--headless --path <workspace> --quit-after 120` | PASSED, exit 0; empty main loads without error diagnostics; iterations are not seconds |
| `./.cache/phase1-checks.ps1` one-off smoke harness | PASSED, exit 0; uses launcher body without final exit and with script root bound explicitly for inspection |
| Omitted override in smoke harness | PASSED; Process absent, persistent User value selected |
| Present/absent process environment restoration | PASSED; APPDATA/LOCALAPPDATA/TEMP/TMP/GODOT_BIN unchanged, including deliberately absent TEMP |
| Temporary `.cache/phase1-settings.gd` parse and execution through the verified helper | PASSED, both exit 0; engine-read renderer/resolution/physics/scale/AA/VSync/FPS settings, physical WASD/Escape bindings, empty scene and real-project user path match baseline |
| One-second limit on a five-second sleeping temporary probe | Expected subprocess FAILED, exit -1, timed out; smoke check PASSED: original output retained, launched wrapper and reported engine PID both gone |
| Explicit relative executable smoke check | PASSED rejection; BLOCKED without fallback or engine execution |
| `git check-ignore .godot/probe .cache/probe` | PASSED, exit 0; both generated roots excluded |
| `git check-ignore scripts/example.gd.uid` | Expected exit 1 (not ignored); source UIDs remain trackable; none required by script-free bootstrap |
| `git diff --check` | PASSED, exit 0 |
| Final completed-task marker inspection | PASSED; exactly T001–T004 checked, all later tasks pending |

Final bootstrap/import/smoke evidence is retained in
`.cache/validation/20261003T014933817-ed69d67112ff4f36b8fdbd178433e9af/`.
Per-command records hold actual absolute command lines and original outputs;
`phase1-smoke-results.json` includes the intentionally failed timeout. The one-off
probes/harness are ignored development output, not the T012 reusable fixture suite.

The first sandboxed probe failed despite exit 0: Windows certificate-store access
was denied; its early custom SceneTree shutdown produced leak errors, and the
attempted Engine singleton lookup did not expose EditorPaths. No real-project
check ran then. A generated editor plugin with normal import shutdown corrected
the probe, and authorized execution outside sandbox isolation resolved certificate
access. Those errors did not recur. The first temporary smoke-harness invocation
also failed because a dynamic script block lacked `PSScriptRoot`; explicit original
tools-directory binding corrected it. The final smoke run passed. No failures
were suppressed or counted as successful engine checks.
The first final marker inspection used incorrect regex-group collection indexing;
corrected per-match enumeration passed and confirmed the task file was accurate.

## Outstanding verification and manual check

- BLOCKED: native suite, supplied by T010; `All` correctly remains nonzero now.
- SKIPPED: source `.gd` parsing; Phase 1 contains none. The generated settings
  probe was parsed and executed successfully.
- BLOCKED: Profile capture, supplied by later US1 tasks.
- UNRUN: graphical Play, controls/visuals/game feel, gameplay/data tests, full
  launcher fixtures/classification and performance. Headless startup proves none
  of those acceptance criteria.

Optional Phase 1 manual check: run `tools/validate.ps1 -Mode Play` through the
same contained launcher, confirm an empty window opens, then close it. WASD,
mouse and Escape have no behavior yet. Use the approved quickstart's gameplay
playtests after their owning tasks are implemented. Phase 2 onward remains
unchecked. No commit or push was made.
