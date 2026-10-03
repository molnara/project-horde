# Prototype profiling — T053 preparation and T054 owner procedure

Prepared 2026-10-03 against HEAD `dc4706afc99b3a46f475979b08ed895c4800c800`;
initial working tree clean. This is preparation, not a new performance result.
T054–T056 are UNRUN. SC-006/007 qualification remains outstanding; SC-005 is
**future/unverified** (60 FPS with 200 representative active enemies).

The authoritative [measurement plan](../../specs/001-core-gameplay-prototype/plan.md#measurement-conditions-fixed-before-profiling)
and [SC-006/007 requirements](../../specs/001-core-gameplay-prototype/spec.md#success-criteria-mandatory)
are unchanged. The [Phase 3B correction and artifact review](core-gameplay.md#phase-3b-independent-profile-artifact-review--2026-10-03)
already establish the reusable capture pipeline. Historical captures cannot
certify this integrated build or supply missing warm-up/source provenance.

## Pre-recorded conditions

| Field | Preparation evidence / required session confirmation |
|---|---|
| Engine | Retained DX-001 Full receipt: Godot Standard `4.7.2.stable.official.ed1daf0bf`, console executable `C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe`; launcher rechecks version every session |
| OS | Read-only CIM discovery: Microsoft Windows 10 IoT Enterprise LTSC, `10.0.19044`, build 19044 |
| CPU / RAM | Intel i7-12700KF; `34099900416` physical-memory bytes reported by CIM (32 GB installed reference) |
| GPU / driver | NVIDIA GeForce RTX 3080; Windows driver version `32.0.16.1062`, driver date 2026-06-10 |
| VRAM | Reference is 10 GB. Actual capacity UNVERIFIED: CIM AdapterRAM returned `4293918720`, unsuitable as capacity evidence for this GPU. Owner may record capacity from the existing NVIDIA/System Information UI; do not infer it from CIM |
| Build / launch | Standalone debug game, no editor/debugger; contained `validate.ps1 -Mode Profile`; not export/release, headless, fixed-FPS or profiler-connected play |
| Rendering | Forward+, 1920×1080 content/window, 100% 3D scale; MSAA/FXAA/TAA, VSync, frame cap off; one directional light, shadows/SSAO/SSIL/glow off |
| Physics | 60 ticks/s; completed active simulation and wall time recorded separately |
| Scenario | Normal arena, one enemy type, ongoing spawn/pursuit/automatic combat/contact damage; cap 50, player vulnerable; actual observed population varies with play/kills |
| Warm-up | Separate attempt lasting at least 30 completed active seconds; close normally and relaunch from zero. **UNRUN in this preparation batch** |
| Sampling | Clean measured attempt from ready-before-first-step through first committed step reaching >=300 simulation seconds, alive; no pause; normal continuation until death |
| Deviations | No source-setting/tuning deviation found. Session window size, driver overrides, host load, owner identity, warm-up and physical setup still need confirmation before measured play |

Settings were checked in `project.godot` and `scenes/main.tscn`. Do not resize
the window, force driver VSync/AA/FPS limits, attach a debugger or change tuning
between warm-up and measurement. Record deviations before launch; a deviation
does not silently satisfy the fixed plan. Record relevant background load and
overlays; do not install measurement software for this procedure.

Exact tuning is already maintained in the [quickstart defaults table](../../specs/001-core-gameplay-prototype/quickstart.md#current-defaults-from-production).
All five `resources/definitions/*.tres` are captured with the source archive
below; Main also serializes actual runtime tuning. In particular: player health
100/speed 6; enemy health 30/speed 3/contact distance 1.2/damage 10/interval 1;
weapon range 4/damage 10/interval 0.6/feedback 0.12; spawn interval 1.5/cap 50.
No tuning or performance target changes are authorized by this preparation.

## Start the owner session after review

Use one PowerShell session in `C:\GameDev\project-horde`. Commands here are
future owner instructions; they were not executed as a T054 session. When Codex
launches Godot, use the established approval-mediated outside-isolation route
with this same launcher. The launcher still verifies actual contained paths and
keeps all writes in the workspace. Do not invoke the engine directly.

1. Confirm the machine/settings above, owner name, and no tuning changes. Save
   the actual source and environment before launching either attempt:

```powershell
Set-Location 'C:\GameDev\project-horde'
$GodotBin = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path -LiteralPath $GodotBin -PathType Leaf)) {
    throw 'The recorded console executable is missing; select the existing approved installation.'
}
$hordePreparation = Join-Path $PWD ('.cache/t053-owner-' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfff') + '-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $hordePreparation | Out-Null
git rev-parse HEAD | Set-Content (Join-Path $hordePreparation 'revision.txt')
if ($LASTEXITCODE -ne 0) { throw 'Cannot record source revision.' }
git status --short --untracked-files=all | Set-Content (Join-Path $hordePreparation 'status.txt')
if ($LASTEXITCODE -ne 0) { throw 'Cannot record working-tree status.' }
git archive --format=zip --output="$hordePreparation/source-head.zip" HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot archive source.' }
git diff HEAD --binary --output="$hordePreparation/source-working.patch"
if ($LASTEXITCODE -ne 0) { throw 'Cannot record working-tree changes.' }
[pscustomobject]@{
    RecordedUtc = [DateTime]::UtcNow.ToString('o')
    OS = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop | Select-Object Caption,Version,BuildNumber)
    CPU = (Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object Name)
    RAM = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop | Select-Object TotalPhysicalMemory)
    GPU = (Get-CimInstance Win32_VideoController -ErrorAction Stop | Select-Object Name,DriverVersion,DriverDate)
} | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $hordePreparation 'environment.json')
Get-FileHash (Join-Path $hordePreparation 'source-head.zip'),(Join-Path $hordePreparation 'source-working.patch') |
    Format-List | Out-File (Join-Path $hordePreparation 'source-hashes.txt')
Write-Host "Session notes and source: $hordePreparation"
```

Review `status.txt`: archive plus patch preserve tracked source, including staged
changes, but not untracked files. If executable resources/scripts are untracked,
stop and retain their contents before validation/play; do not pretend the archive
contains them. Documentation-only untracked files do not change runtime source.
Retain this directory and the revision in the report; caches are ignored and must
not be committed or deleted while evidence is needed. Record manual confirmations
in `session-notes.md` inside that directory (owner, VRAM or unavailable reason,
window/settings/driver overrides/load, deviations, warm-up and measured receipts).
If CIM access is denied, record BLOCKED environment discovery and request the
established read-only approval or record the same fields from system information.

2. Confirm required technical validation for the exact runtime source. The
   retained DX-001 Full run is reusable while executable source is unchanged.
   For a clean checkout without retained evidence, or executable changes that
   require Full under the [DX-001 policy](../../tests/README.md#dx-001-batch-5-execution-workflow), run:

```powershell
./tools/validate.ps1 -Mode All -InfrastructureFixtures -SuiteTimeoutSeconds 240 -GodotBin $GodotBin
if ($LASTEXITCODE -ne 0) { throw 'Required validation failed; inspect the printed session before profiling.' }
```

Record its `results.json` path. Full includes all 88 cases, infrastructure,
import, all script parses and both startups. Documentation-only preparation
uses static checks; it does not require repeating Full. Profile does not import
or run tests first. Missing required validation is outstanding, not a pass.

3. Perform the **separate warm-up** with this exact command:

```powershell
./tools/validate.ps1 -Mode Profile -GodotBin $GodotBin
if ($LASTEXITCODE -ne 0) { throw 'Warm-up capture failed; retain its printed validation session and inspect diagnostics.' }
```

Move with WASD and use the mouse while normal enemies/combat/damage remain active.
Stay alive through at least 00:30 without pausing, then close normally with Alt+F4.
The launcher waits for closure. Verify the warm-up receipt's
`completed_simulation_duration >= 30` and `completed_step_count >= 1800`, no
interruption/spawn failure/capture fault; record its manifest/session paths as
**warm-up**, not survival success. HUD 00:30 is a cue; metadata is the authority.
If defeated early, retain that failed warm-up and repeat in a new process.
There is no living-run Restart. Do not use the short 6,000-iteration smoke as
the warm-up: iterations are not active seconds.

4. After warm-up evidence is verified, launch a **new measured process**:

```powershell
./tools/validate.ps1 -Mode Profile -GodotBin $GodotBin
if ($LASTEXITCODE -ne 0) { throw 'Measured capture failed; retain its printed validation session and inspect diagnostics.' }
```

Start from full health/00:00. Use normal WASD/mouse play, observe spawn/pursuit,
automatic attacks/kills and vulnerability, and survive uninterrupted past 05:00.
Do not press Escape or restart within the qualifying attempt. After 05:00,
continue moving and rotating the view; observe time advancement and a later
scheduled spawn opportunity (a full-cap skip is valid automated evidence).
Observe attacks if targets are eligible; do not force an attack if none are.
Continue normally until death, observe Game Over/final time, then close with
Alt+F4 without restarting. Record responsiveness, any stutter and relevant HUD
times after closure; do not pause to take notes. No screen recording is required.
Death before 300 is a retained failed attempt; repeat from a new clean process,
never join attempts. Later death preserves a valid alive window but leaves any
unobserved continuation clauses outstanding. Any pause even after 300, or any
unexpected spawn failure throughout continuation, disqualifies the full attempt.

## Find, retain and interpret the evidence

The launcher prints `Validation evidence: <session>` and result statuses. After
each invocation, copy that exact directory path into the following command;
the only varying input is the printed path, not a measurement parameter:
run this retention block even if the launch command above threw on failure,
before retrying. Keep the same PowerShell session and `$hordePreparation`.

```powershell
$hordeValidation = Read-Host 'Paste the printed validation session directory'
if (-not (Test-Path -LiteralPath (Join-Path $hordeValidation 'results.json') -PathType Leaf)) {
    throw 'No results.json at that session path.'
}
$hordeResults = Get-Content (Join-Path $hordeValidation 'results.json') -Raw | ConvertFrom-Json
$hordeProfile = @($hordeResults | Where-Object Name -eq 'profile')
$hordeRetained = Join-Path $hordePreparation (Split-Path $hordeValidation -Leaf)
New-Item -ItemType Directory -Path $hordeRetained -ErrorAction Stop | Out-Null
Get-ChildItem -LiteralPath $hordeValidation -File | Copy-Item -Destination $hordeRetained
# Copy every available artifact even when capture failed. Keep originals too.
foreach ($hordeResult in $hordeProfile) {
    foreach ($hordeReceiptItem in $hordeResult.Diagnostics.ProfileResults) {
        $hordeAttempts = @($hordeReceiptItem) + @($hordeReceiptItem.retained_attempts)
        foreach ($hordeAttempt in $hordeAttempts) {
            if ($null -eq $hordeAttempt) { continue }
            $hordeEvidencePaths = @($hordeAttempt.evidence_path) + @($hordeAttempt.segments | ForEach-Object evidence_path)
            foreach ($hordeEvidencePath in ($hordeEvidencePaths | Where-Object { $_ } | Select-Object -Unique)) {
                foreach ($hordeArtifact in @($hordeEvidencePath,($hordeEvidencePath + '.frames.bin'),($hordeEvidencePath + '.outcomes.json'))) {
                    if (Test-Path -LiteralPath $hordeArtifact -PathType Leaf) {
                        Copy-Item -LiteralPath $hordeArtifact -Destination $hordeRetained -ErrorAction Stop
                    } else {
                        Write-Warning "Missing artifact (retain diagnostic status): $hordeArtifact"
                    }
                }
            }
        }
    }
}
Write-Host "Retained available evidence: $hordeRetained"
if ($hordeProfile.Count -ne 1 -or $hordeProfile[0].Outcome -ne 'PASSED') {
    throw 'Profile invocation did not pass; retain all logs and investigate.'
}
$hordeReceipt = $hordeProfile[0].Diagnostics.ProfileResults[0]
$hordeManifest = Get-Content -LiteralPath $hordeReceipt.evidence_path -Raw | ConvertFrom-Json
$hordeOutcomes = Get-Content -LiteralPath ($hordeReceipt.evidence_path + '.outcomes.json') -Raw | ConvertFrom-Json
$hordeManifest | Select-Object completed_simulation_duration,completed_step_count,t0,t1,conditions,frame_stream,summary | ConvertTo-Json -Depth 12
$hordeOutcomes | Select-Object survival_window_outcome,continuation_outcome,continuation_evidence,profile_capture_outcome,interrupted,acceptance_invalid,spawn_failure_count | ConvertTo-Json -Depth 6
```

Use receipt paths, not the newest `attempt-*` filename: tests also write captures,
and the timestamp suffix is a process-relative monotonic clock, not a date or a
globally unique identifier. Each manifest name is
`attempt-<generation>-<serial>-<ticks_usec>.json` under `.cache/profile/`.
Retain the exact manifest, `.json.frames.bin`, `.json.outcomes.json`, and the
entire validation session (`results.json`, stdout/stderr, engine log,
`verified-paths.json`, restoration receipts). Store a copy of each session's
artifact set inside the unique `$hordePreparation` directory after closure,
before another run; the existing filenames do not guarantee cross-process
uniqueness. For retained restarts/pauses, follow every `retained_attempts` and
`segments` descriptor; retain all referenced manifests, streams and sidecars,
including failed ones. Never overwrite failed evidence with a later success.
Interrupted segmented captures remain diagnostic, not qualifying survival.

| Evidence | Meaning / interpretation |
|---|---|
| Manifest `conditions` | Actual engine, OS family, debug build, renderer, viewport, cap/VSync, physics and runtime tuning. `source_revision`, `warmup`, `owner_acceptance` are instruction strings, **not proof**; use pre-recorded source, notes and warm-up receipt |
| Manifest endpoint | `completed_simulation_duration`, `completed_step_count`, `t0`, `t1`; first committed >=300 step after combat determines survival, not HUD or wall stopwatch |
| Raw `frame_stream` | Lossless little-endian float64 monotonic wall seconds, eight bytes per callback; bounded 4,096-entry chunks with no sampling/overwrite; byte length must equal `sample_count * 8` |
| Summary FPS | `whole_window_fps = callback_count / (t1-t0)` with callbacks in `(t0,t1]`, including active startup/stalls; separately `full_interval_fps = interval_count / interval_coverage` for full consecutive intervals wholly inside `[t0,t1]` |
| Summary frame times | `minimum_fps` reciprocal longest full interval; empirical nearest-rank `p50_ms/p95_ms/p99_ms/max_ms`, `stalls_over_16_67/stalls_over_33_33`; exact source-microsecond frequency counts over the full raw stream |
| Boundary / sparse evidence | `initial_partial_seconds`, `final_partial_seconds`, stall flags, `uncovered_wall_seconds`; no prorated frames. If full intervals unavailable, keep null minimum/distributions and `unavailable_reason`; do not invent values |
| Enemy load | `enemy_samples` at one-second completed-simulation opportunities with `active_time`, `wall_time`, `count`; `enemy_min/max/mean` are observed samples, not proof of constant cap or 200 enemies |
| Instrumentation | `frame_callback_audit` must have zero repeated/skipped draw IDs; `sampler_overhead_usec` includes callback/step/chunk writes/final flush, excludes endpoint summary/JSON; `engine_monitors` are endpoint process/physics time, static memory, objects and draw calls |
| Final outcomes | Sidecar/receipt retain latest `continuation_evidence` simulation timestamps, survival/capture/continuation results, interruption and late failure invalidity; endpoint manifest alone cannot establish final continuation |

These are **CPU-observed frame-loop** measurements, not GPU timing or display
presentation FPS. Endpoint monitors cannot establish per-system bottleneck
causes. Record observed stutters with approximate simulation time; attribution
or GPU metrics remain unavailable unless separately measured. No numerical
prototype FPS acceptance threshold is introduced; never extrapolate this cap-50
run to SC-005.

Automation collects clocks, endpoints, counts, actual tuning, continuation
movement/view/spawn/eligible-attack timestamps and retained failure/capture
outcomes. The owner must actually play, confirm setup and warm-up, observe normal
spawning/pursuit/combat/vulnerability and continuation to death, and report
responsiveness/stutters. The owner need not count ticks, time attacks with a
stopwatch, decode binary frames or identify internal bottlenecks. Codex reviews
the artifact set and source provenance for T054/T055 after the owner session.
Successful launcher exit or `qualifies_attempt()` alone never establishes
SC-006/007 or feature acceptance. Genuine errors, missing/failed output, setup
BLOCKED and dependent UNRUN checks must remain explicit; preserve logs and use
the existing approved route for diagnosis without changing host configuration.

## Session record to complete later

For every warm-up, failed attempt and measured attempt, record: owner/date,
source archive/revision/diff, actual conditions/deviations, validation session,
manifest/raw/sidecar paths, warm-up duration/ticks, pause/death status and reason.
For the measured attempt, reconcile endpoint simulation/ticks/wall duration,
normal gameplay observations, final continuation timestamps and observed death,
zero unexpected failures, capture integrity and unavailable evidence.
Record T054 observations in [the gameplay ledger](core-gameplay.md); T055 will
summarize this attempt's complete statistics/conditions/bottlenecks here.

Use this note template, filling measured fields from the receipt rather than
estimates: `Owner/date: …; setup/deviations/load: …; source directory/revision: …;
attempt role: warm-up/failed/measured; validation directory: …; manifest: …;
simulation seconds/ticks/wall seconds: …; interruption/failures/capture: …;
normal spawning/pursuit/combat/vulnerability observed: …; post-300 movement/view/
time/spawn/eligible attack timestamps and observations: …; later death/final HUD:
…; responsiveness/stutters and unavailable evidence: …`.

No new owner session is recorded in this preparation. The procedure is ready
for review; the original T053 checkbox stays open until its explicit warm-up
and clean-relaunch prerequisites have actual evidence. T054–T056 remain open.

## Executed preparation verification

Documentation-only impact: no gameplay, tuning, launcher, validation or capture
source changes. DX-001 selects static checks; Full was not rerun. Executed
`./.cache/t053-preparation-audit.ps1 | Tee-Object -FilePath .cache/t053-preparation-audit.txt`
passed, exit 0. It checks PowerShell example syntax, local links, whitespace,
unchanged executable source and retained Full/rendered artifact evidence.

Reinspected DX-001 Full session
`.cache/validation/20261003T193507973-e6dea706ae574483b01e2d34ffc05ce9/`:
88/88 cases, 4,152 assertions, 38 parses, import/both startups, 163 infrastructure
expectations and four environment restorations passed. Source hashes still
match `.cache/dx001-batch5-source/hashes.json`; executable source has no changes
between DX-001 closure commit `c558409`, current HEAD and the working tree.
This is retained executed evidence, not a newly executed engine check.

Reinspected Phase 3B rendered smoke session
`.cache/validation/20261003T052322559-870b0bee964d4220a426c9a60103e527/`
and `.cache/profile/attempt-1-1-777285.json` with raw/sidecar: complete capture,
6,000 ordered callbacks, 48,000 raw bytes, no repeated/skipped draw IDs. Its
2.06666666666666 active seconds proves artifact generation, not the 30-second
warm-up. The earlier complete owner capture `attempt-1-1-693766.json` is already
reviewed in the Phase 3B ledger; it remains historical with unresolved source
provenance. No historical result is promoted to current acceptance.

Read-only CIM discovery initially returned access denied under isolation
(BLOCKED environment discovery); approved read-only retry passed. An initial
report read failed because this report was absent, and an initial search failed
on PowerShell-incompatible brace syntax; corrected inspection succeeded.
No engine/certificate investigation was performed. New warm-up, measured owner
play, bottleneck analysis and T054–T056 verification are UNRUN.
