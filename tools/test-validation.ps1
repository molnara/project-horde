<#
.SYNOPSIS
Exercise real launcher functions and selected-engine diagnostic/timeout fixtures.
.DESCRIPTION
Runs All first so no fixture engine command bypasses verified containment.
Intentional child failures stay in infrastructure-child-results.json. A fixture
passes only when its asserted failure, diagnostic, cleanup and exit are observed.
#>
[CmdletBinding()]
param([Alias('GodotBin')][string] $FixtureGodotBin, [switch] $DefineOnly, [switch] $RenderedProfileSmoke)

function Invoke-ValidationInfrastructureFixtures {
    $parentResults = $script:results
    $script:results = [Collections.Generic.List[object]]::new()
    $fixtureChecks = [Collections.Generic.List[object]]::new()
    $fixturesCompleted = $false
    $fixtureRoot = New-ContainedDirectory (Join-Path $sessionDir 'fixtures')
    function Assert-Fixture([bool] $Condition, [string] $Name) {
        $fixtureChecks.Add([pscustomobject]@{Name=$Name; Outcome=if ($Condition) {'PASSED'} else {'FAILED'}})
        Write-Host "FIXTURE [$Name]: $(if ($Condition) {'PASSED'} else {'FAILED'})"
        if (-not $Condition) { throw "FAILED: infrastructure fixture '$Name'." }
    }
    function Assert-Rejection([scriptblock] $Action, [string] $Message, [string] $Name) {
        $caught = $null
        try { & $Action | Out-Null } catch { $caught = $_.Exception.Message }
        Assert-Fixture ($null -ne $caught -and $caught.Contains($Message)) $Name
    }
    function Invoke-FixtureScript([string] $Name, [string] $Code, [bool] $ExpectFailure, [string] $Diagnostic = '', [int] $Limit = 30) {
        $path = Join-Path $fixtureRoot "$Name.gd"
        Write-ContainedText $path $Code
        $caught = $null
        $beforeCount = $script:results.Count
        try { [void](Invoke-GodotCheck $Name @('--headless', '--path', $workspace, '--script', $path) $workspace $Limit) }
        catch { $caught = $_.Exception.Message }
        Assert-Fixture ($script:results.Count -eq $beforeCount + 1) "$Name retained child result"
        $childResult = $script:results[$script:results.Count - 1]
        Assert-Fixture (($null -ne $caught) -eq $ExpectFailure) "$Name expected outcome"
        if ($Diagnostic) { Assert-Fixture ($childResult.Output.Contains($Diagnostic)) "$Name original diagnostic retained" }
        if ($ExpectFailure) {
            Assert-Fixture ($childResult.Outcome -eq 'FAILED') "$Name genuine failed child"
        } else { Assert-Fixture ($childResult.Outcome -eq 'PASSED') "$Name passed child" }
        return $childResult
    }
    try {
        # Selection seam changes only scope reads; selected paths still pass the
        # exact production PE/version/path gates. No persistent registry writes.
        $noRead = { param($Scope) throw "Override must not inspect $Scope" }
        Assert-Fixture ((Resolve-GodotExecutable -Explicit $true -Override $engine -ReadScope $noRead) -eq $engine) 'explicit override precedence'
        Assert-Rejection { Resolve-GodotExecutable -Explicit $true -Override '' -ReadScope $noRead } 'explicit -GodotBin is empty' 'empty override no fallback'
        $badPath = Join-Path $fixtureRoot 'absent.exe'
        Assert-Rejection { Assert-ConsoleExecutable (Resolve-GodotExecutable -Explicit $true -Override $badPath -ReadScope $noRead) } 'does not exist' 'invalid explicit override no fallback'
        Assert-Rejection { Assert-ConsoleExecutable 'relative.exe' } 'absolute Windows' 'relative executable rejected'
        $fakeExe = Join-Path $fixtureRoot 'invalid.exe'
        Write-ContainedText $fakeExe 'not a PE binary'
        Assert-Rejection { Assert-ConsoleExecutable $fakeExe } 'not a verified Windows console binary' 'PE gate unchanged'
        Assert-Fixture ((Assert-ConsoleExecutable $engine) -eq $engine) 'actual selected console validated'
        foreach ($chosenScope in @('Process', 'User', 'Machine')) {
            $scopeValues = @{}
            $scopeValues[$chosenScope] = @{GODOT_BIN=$engine}
            $reader = { param($Scope)
                if ($scopeValues.ContainsKey($Scope)) { return $scopeValues[$Scope] }
                if (@('Process', 'User', 'Machine').IndexOf($Scope) -gt @('Process', 'User', 'Machine').IndexOf($chosenScope)) { throw 'Read past first nonempty scope.' }
                return @{GODOT_BIN=' '}
            }.GetNewClosure()
            Assert-Fixture ((Resolve-GodotExecutable -Explicit $false -ReadScope $reader) -eq $engine) "first nonempty $chosenScope discovery"
        }
        Assert-Rejection { Resolve-GodotExecutable -Explicit $false -ReadScope { param($Scope) @{} } } 'absent/empty in Process, User and Machine' 'all absent scopes explicit blocker'
        Assert-Rejection { Resolve-GodotExecutable -Explicit $false -ReadScope { param($Scope) if ($Scope -eq 'User') { throw 'fixture access denied' }; @{} } } 'cannot inspect GODOT_BIN User scope' 'inaccessible scope explicit blocker'
        $outside = [IO.Path]::GetFullPath((Join-Path $workspace '../fixture-outside'))
        Assert-Rejection { Assert-ContainedPath $outside } 'outside' 'workspace path escape rejected without write'
        Assert-Rejection { Assert-ContainedPath 'relative' } 'absolute Windows path' 'relative containment rejected'
        Assert-Fixture ((Assert-ContainedPath $fixtureRoot) -eq $fixtureRoot) 'fixture output contained'

        foreach ($text in @('Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org', '[ 50% ] import progress', 'Vulkan 1.4 Forward+ NVIDIA RTX 3080', 'An arbitrary error word is informational.', "`e[32mnormal ANSI text`e[0m")) {
            Assert-Fixture (-not (Get-ValidationDiagnostics -Text $text).Failed) 'harmless diagnostic text accepted'
        }
        foreach ($text in @('SCRIPT ERROR: Parse Error: bad token', 'PARSE ERROR: bad token', 'ERROR: Failed loading resource: res://missing.tres', 'RUNTIME ERROR: bad call', 'FATAL ERROR: failure')) {
            Assert-Fixture (Get-ValidationDiagnostics -Text $text).Failed 'recognized severity rejected at exit zero'
        }
        $ambiguous = Get-ValidationDiagnostics -Text 'ERROR malformed severity without colon'
        Assert-Fixture ($ambiguous.Failed -and $ambiguous.Ambiguous.Count -eq 1) 'ambiguous severity requires investigation'
        $warning = Get-ValidationDiagnostics -Text 'WARNING: fixture warning'
        Assert-Fixture (-not $warning.Failed -and $warning.Warnings.Count -eq 1) 'warnings recorded separately'
        Assert-Fixture (Get-ValidationDiagnostics -Text 'normal' -EngineLog 'ERROR: log-only failure').Failed 'engine-log-only error detected'
        $captureFault = 'Profile capture failure: {"cause":"Frame safety ceiling reached; capture is incomplete."}'
        Assert-Fixture (Get-ValidationDiagnostics -Text $captureFault).Failed 'application capture fault detected'
        Assert-Fixture (Get-ValidationDiagnostics -Text 'normal' -EngineLog $captureFault).Failed 'log-only capture fault detected'
        Assert-Fixture (Get-ValidationDiagnostics -Text 'normal' -RequireProfileResult).Failed 'missing Profile receipt cannot pass'
        $receipt = 'HORDE_PROFILE_RESULT=' + (ConvertTo-Json -Compress -InputObject @{profile_capture_outcome='passed';capture_diagnostics=@();evidence_path='fixture.json';frame_evidence_path='fixture.bin';frame_sample_count=0;acceptance_invalid=$false})
        Assert-Fixture (-not (Get-ValidationDiagnostics -Text $receipt -RequireProfileResult).Failed) 'explicit successful capture receipt classified'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($receipt.Replace('"passed"','"outstanding"')) -RequireProfileResult).Failed 'incomplete Profile receipt fails'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($receipt + "`n" + $receipt) -RequireProfileResult).Failed 'duplicate Profile receipt fails'
        $app = @{case='fault';source='fixture';field='cap';observed='0';constraint='positive integer';cause='intentional'}
        $begin = 'HORDE_CASE_BEGIN=' + (ConvertTo-Json -Compress -InputObject @{case='fault';seed=1;expected=@(@{source='fixture';constraint='positive integer';count=1})})
        $fault = 'HORDE_APP_DIAGNOSTIC=' + (ConvertTo-Json -Compress -InputObject $app)
        $end = 'HORDE_CASE_END=' + (ConvertTo-Json -Compress -InputObject @{case='fault';assertions=1;passed=$true;completed=$true})
        $summary = 'HORDE_SUITE_END=' + (ConvertTo-Json -Compress -InputObject @{required=1;executed=1;assertions=1;passed=$true})
        $declared = @($begin,$fault,$end,$summary) -join "`n"
        Assert-Fixture (-not (Get-ValidationDiagnostics -Text $declared -AllowCaseDeclarations).Failed) 'declared application diagnostic accepted'
        Assert-Fixture (Get-ValidationDiagnostics -Text $declared).Failed 'undeclared application diagnostic rejected'
        Assert-Fixture (Get-ValidationDiagnostics -Text (@($begin,$fault,$fault,$end,$summary) -join "`n") -AllowCaseDeclarations).Failed 'application count mismatch rejected'
        Assert-Fixture (Get-ValidationDiagnostics -Text (@($begin,$end,$summary) -join "`n") -AllowCaseDeclarations).Failed 'missing expected diagnostic rejected'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($declared + "`nSCRIPT ERROR: genuine exception") -AllowCaseDeclarations).Failed 'expected fault never masks engine exception'
        Assert-Fixture (Get-ValidationDiagnostics -Text (@($begin, $fault.Replace('"source":"fixture"', '"source":"wrong"'), $end, $summary) -join "`n") -AllowCaseDeclarations).Failed 'fault matching requires declared source'

        $captureApp = @{case='capture-fault';source='ProfileCapture';field='evidence_path';observed='fixture.json';constraint='required output written successfully';cause='intentional open fault'}
        $captureBegin = 'HORDE_CASE_BEGIN=' + (ConvertTo-Json -Compress -InputObject @{case='capture-fault';seed=1;expected=@(@{source='ProfileCapture';constraint=$captureApp.constraint;count=1})})
        $captureEnd = 'HORDE_CASE_END=' + (ConvertTo-Json -Compress -InputObject @{case='capture-fault';assertions=1;passed=$true;completed=$true})
        $captureRecord = 'HORDE_APP_DIAGNOSTIC=' + (ConvertTo-Json -Compress -InputObject $captureApp)
        $capturePayload = $captureApp.Clone()
        $capturePayload.Remove('case')
        $captureLine = 'Profile capture failure: ' + (ConvertTo-Json -Compress -InputObject $capturePayload)
        $captureDeclared = @($captureBegin,$captureRecord,$captureEnd,$summary,$captureLine) -join "`n"
        Assert-Fixture (-not (Get-ValidationDiagnostics -Text $captureDeclared -EngineLog $captureLine -AllowCaseDeclarations).Failed) 'exact declared capture fault accepted once across stream and log'
        Assert-Fixture (Get-ValidationDiagnostics -Text $captureDeclared -EngineLog ($captureLine + "`n" + $captureLine.Replace('fixture.json','undeclared.json')) -AllowCaseDeclarations).Failed 'declared stream capture fault cannot mask log-only capture failure'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($captureDeclared + "`n" + $captureLine) -AllowCaseDeclarations).Failed 'extra printed capture fault rejected'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($captureDeclared.Replace('Profile capture failure: {', 'Profile capture failure: {"extra":true,')) -AllowCaseDeclarations).Failed 'capture payload with undeclared extra fields rejected'
        Assert-Fixture (Get-ValidationDiagnostics -Text ($captureDeclared + "`nSCRIPT ERROR: genuine exception") -AllowCaseDeclarations).Failed 'declared capture fault cannot mask genuine engine errors'
        foreach ($field in @('source','field','observed','constraint','cause')) {
            $alteredPayload = $capturePayload.Clone()
            $alteredPayload[$field] = 'wrong'
            $alteredLine = 'Profile capture failure: ' + (ConvertTo-Json -Compress -InputObject $alteredPayload)
            Assert-Fixture (Get-ValidationDiagnostics -Text ($captureDeclared.Replace($captureLine,$alteredLine)) -AllowCaseDeclarations).Failed "capture fault requires exact $field"
        }

        $controls = Invoke-FixtureScript 'fixture-restart-controls' @'
extends SceneTree
func _initialize() -> void:
    call_deferred("exercise")
func exercise() -> void:
    var main = load("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    var coordinator = main.coordinator
    coordinator.set_physics_process(false)
    for key in [KEY_ENTER, KEY_SPACE]:
        coordinator.player.health.apply_damage(100)
        var generation: int = coordinator.run_generation
        var echo := InputEventKey.new()
        echo.keycode = key
        echo.pressed = true
        echo.echo = true
        main.get_viewport().push_input(echo)
        assert(coordinator.run_generation == generation, "Held key echo cannot restart")
        echo.echo = false
        main.get_viewport().push_input(echo)
        assert(main.coordinator == coordinator and coordinator.run_generation == generation + 1 and coordinator.state == "Active", "Real keyboard event restarts once")
    coordinator.player.health.apply_damage(100)
    var generation: int = coordinator.run_generation
    var button = coordinator.hud.get_node("GameOver/Panel/Restart")
    await process_frame
    var mouse := InputEventMouseButton.new()
    mouse.button_index = MOUSE_BUTTON_LEFT
    mouse.position = button.get_global_rect().get_center()
    mouse.global_position = mouse.position
    mouse.pressed = true
    main.get_viewport().push_input(mouse, true)
    mouse.pressed = false
    main.get_viewport().push_input(mouse, true)
    assert(coordinator.run_generation == generation + 1 and coordinator.state == "Active", "Real mouse click restarts once")
    coordinator.spawn_failure_count = 1
    coordinator.acceptance_invalid = true
    coordinator.spawn_diagnostics.append({"cause": "prior fault"})
    var completed: Array = []
    coordinator.state_changed.connect(func(state):
        if state == "GameOver": coordinator.request_restart())
    coordinator.time_changed.connect(func(time): completed.append(time))
    coordinator.player.health.apply_damage(99)
    var enemy = coordinator.create_enemy()
    enemy.configure(coordinator.runtime_definition.enemy, 0)
    coordinator.spawner.add_child(enemy)
    coordinator.registry.add(enemy, 0)
    coordinator.step(0.125)
    assert(completed == [0.125], "Reentrant restart waits for lethal final commit")
    await process_frame
    assert(coordinator.state == "Active" and coordinator.active_time == 0 and coordinator.spawn_failure_count == 0, "Deferred guarded restart restores fresh state")
    assert(coordinator.retained_attempts.back().active_time == 0.125 and coordinator.retained_attempts.back().spawn_failure_count == 1 and coordinator.retained_attempts.back().spawn_diagnostics.size() == 1, "Normal Play retains old failed attempt")
    print("RESTART_CONTROLS_ASSERTIONS=8")
    main.free()
    quit(0)
'@ $false 'RESTART_CONTROLS_ASSERTIONS=8'
        Assert-Fixture ($controls.ExitCode -eq 0) 'real Enter Space mouse echo and reentrant lethal restart passed'

        $profileRestartPath = Join-Path $fixtureRoot 'profile-restarts.gd'
        Write-ContainedText $profileRestartPath @'
extends SceneTree
func _initialize() -> void:
    call_deferred("exercise")
func exercise() -> void:
    var main = load("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    var coordinator = main.coordinator
    coordinator.set_physics_process(false)
    assert(main.capture != null)
    for cycle in 3:
        var old_frame_callback: Callable = main.frame_callback
        coordinator.player.health.apply_damage(100)
        coordinator.request_restart()
        assert(main.coordinator == coordinator and main.capture.retained_attempts.size() == cycle + 1)
        var before: int = main.capture.frame_sample_count
        old_frame_callback.call()
        assert(main.capture.frame_sample_count == before, "Saved old Main frame callback cannot tag a frame with the new generation")
    print("PROFILE_RESTART_ASSERTIONS=7")
    main.free()
    quit(0)
'@
        $profileRestart = Invoke-GodotCheck 'profile-startup' @('--headless','--path',$workspace,'--script',$profileRestartPath,'--','--profile') $workspace 30
        Assert-Fixture ($profileRestart.ExitCode -eq 0 -and $profileRestart.Output.Contains('PROFILE_RESTART_ASSERTIONS=7') -and $profileRestart.Diagnostics.ProfileResults.Count -eq 1) 'three production Profile restarts emit one validated application receipt'
        Assert-Fixture ($profileRestart.Diagnostics.ProfileResults[0].retained_attempts.Count -eq 3) 'every retired Profile stream manifest and sidecar validated'

        $invalidScript = Join-Path $fixtureRoot 'invalid-restart-app.gd'
        Write-ContainedText $invalidScript @'
extends "res://scripts/run/main.gd"
func _ready() -> void:
    run_definition = run_definition.duplicate()
    run_definition.player = run_definition.player.duplicate()
    super._ready()
    call_deferred("exercise")
func exercise() -> void:
    coordinator.set_physics_process(false)
    coordinator.player.health.apply_damage(100)
    run_definition.player.max_health = 0
    coordinator.request_restart()
    assert(failure_status == 1 and coordinator.state == "ConfigurationError" and coordinator.player == null and not coordinator.simulation_enabled)
    coordinator.request_restart()
    assert(coordinator.run_generation == 2 and failure_status == 1)
    print("INVALID_RESTART_STATUS=1; ASSERTIONS=2")
'@
        $invalidScene = Join-Path $fixtureRoot 'invalid-restart-app.tscn'
        $invalidResource = 'res://' + $invalidScript.Substring($workspace.Length + 1).Replace('\','/')
        Write-ContainedText $invalidScene ("[gd_scene load_steps=2 format=3]`n[ext_resource type=`"Script`" path=`"$invalidResource`" id=`"1`"]`n[node name=`"InvalidRestartApp`" type=`"Node3D`"]`nscript = ExtResource(`"1`")`n")
        $invalidResultIndex = $script:results.Count
        $invalidRejection = $null
        try { [void](Invoke-GodotCheck 'fixture-invalid-restart-app' @('--headless','--path',$workspace,$invalidScene,'--quit-after','120') $workspace 30) }
        catch { $invalidRejection = $_.Exception.Message }
        Assert-Fixture ($null -ne $invalidRejection -and $script:results.Count -eq $invalidResultIndex + 1) 'invalid restart application fails contained check'
        $invalidResult = $script:results[$invalidResultIndex]
        Assert-Fixture ($invalidResult.ExitCode -eq 1 -and $invalidResult.Output.Contains('INVALID_RESTART_STATUS=1; ASSERTIONS=2')) 'actual invalid restart retains failure status and exits one'

        $harmless = Invoke-FixtureScript 'fixture-info' @'
extends SceneTree
func _initialize() -> void:
    print("renderer/device information; error count is zero")
    quit(0)
'@ $false 'error count is zero'
        Assert-Fixture ($harmless.ExitCode -eq 0) 'real harmless engine output exit zero'
        $warningChild = Invoke-FixtureScript 'fixture-warning' @'
extends SceneTree
func _initialize() -> void:
    push_warning("HORDE fixture warning")
    quit(0)
'@ $false 'WARNING: HORDE fixture warning'
        Assert-Fixture ($warningChild.Warnings.Count -eq 1) 'real warning format recorded'
        $zeroError = Invoke-FixtureScript 'fixture-zero-error' @'
extends SceneTree
func _initialize() -> void:
    push_error("HORDE fixture genuine zero-exit error")
    quit(0)
'@ $true 'ERROR: HORDE fixture genuine zero-exit error'
        Assert-Fixture ($zeroError.ExitCode -eq 0 -and $zeroError.Diagnostics.Errors.Count -gt 0) 'real error exit zero still fails'
        [void](New-ContainedDirectory (Join-Path $cacheRoot 'profile-fixtures'))
        $captureFailure = Invoke-FixtureScript 'fixture-capture-failure' @'
extends SceneTree
const Capture = preload("res://scripts/run/profile_capture.gd")
func _initialize() -> void:
    var capture := Capture.new()
    root.add_child(capture)
    var blocker := ProjectSettings.globalize_path("res://.cache/profile-fixtures/output-blocker")
    var output := FileAccess.open(blocker, FileAccess.WRITE)
    output.store_string("Intentional file prevents child directory creation")
    output.close()
    capture.configure(blocker + "/child")
    capture.open_attempt(1, 0.0)
    capture.record_step(1, 300.0, 18000, 300.0, 1, true)
    capture.shutdown(301.0)
    quit(0)
'@ $true 'Profile capture failure:'
        Assert-Fixture ($captureFailure.ExitCode -eq 0 -and $captureFailure.Diagnostics.Errors.Count -gt 0) 'actual output fault at exit zero fails launcher'
        $truncatedCapture = Invoke-FixtureScript 'fixture-truncated-capture' @'
extends SceneTree
const Capture = preload("res://scripts/run/profile_capture.gd")
func _initialize() -> void:
    var capture := Capture.new()
    root.add_child(capture)
    capture.configure(ProjectSettings.globalize_path("res://.cache/profile-fixtures/truncated"))
    capture.open_attempt(1, 0.0)
    capture.record_frame(1, 0.25)
    capture.record_frame(1, 0.5)
    capture._flush_frames()
    capture.frame_output.close()
    capture.frame_output = null
    var output := FileAccess.open(capture.frame_evidence_path, FileAccess.WRITE)
    output.store_double(0.25)
    output.close()
    capture.record_step(1, 300.0, 18000, 300.0, 1, true)
    capture.shutdown(301.0)
    quit(0)
'@ $true 'Frame stream length does not match every recorded callback.'
        Assert-Fixture ($truncatedCapture.ExitCode -eq 0) 'truncated raw evidence fails despite clean exit'
        $sidecarFailure = Invoke-FixtureScript 'fixture-sidecar-failure' @'
extends SceneTree
const Capture = preload("res://scripts/run/profile_capture.gd")
func _initialize() -> void:
    var capture := Capture.new()
    root.add_child(capture)
    capture.configure(ProjectSettings.globalize_path("res://.cache/profile-fixtures/sidecar-failure"))
    capture.open_attempt(1, 0.0)
    capture.record_frame(1, 0.25)
    capture.record_step(1, 300.0, 18000, 300.0, 1, true)
    DirAccess.make_dir_recursive_absolute(capture.evidence_path + ".outcomes.json")
    capture.shutdown(301.0)
    quit(0)
'@ $true 'Profile capture failure:'
        Assert-Fixture ($sidecarFailure.ExitCode -eq 0 -and $sidecarFailure.Output.Contains('"profile_capture_outcome":"outstanding"')) 'sidecar output failure changes final receipt to incomplete'
        if ($RenderedProfileSmoke) {
            $rendered = Invoke-GodotCheck 'profile-startup' @('--path', $workspace, '--quit-after', '6000', '--', '--profile') $workspace 30
            Assert-Fixture ($rendered.Diagnostics.ProfileResults[0].frame_sample_count -gt 0) 'real rendered Main callbacks captured'
            $manifest = [IO.File]::ReadAllText($rendered.Diagnostics.ProfileResults[0].evidence_path) | ConvertFrom-Json
            Assert-Fixture ($manifest.summary.frame_callback_audit.repeated_engine_frame_ids -eq 0 -and $manifest.summary.frame_callback_audit.skipped_engine_frame_ids -eq 0) 'one real callback per successive engine draw'
            Assert-Fixture ($manifest.summary.frame_callback_audit.last_engine_frame - $manifest.summary.frame_callback_audit.first_engine_frame + 1 -eq $manifest.frame_stream.sample_count) 'engine draw IDs independently reconcile raw sample count'
        }
        $monitor = Invoke-FixtureScript 'fixture-error-monitor' @'
extends SceneTree
const Monitor = preload("res://tests/support/error_monitor.gd")
func _initialize() -> void:
    var monitor := Monitor.new()
    OS.add_logger(monitor)
    push_error("HORDE monitor engine-error fixture")
    var observed := monitor.snapshot()
    OS.remove_logger(monitor)
    print("MONITORED_ERRORS=" + str(observed.errors.size()))
    quit(1 if observed.errors.size() == 1 else 0)
'@ $true 'MONITORED_ERRORS=1'
        Assert-Fixture ($monitor.ExitCode -eq 1) 'native engine-error monitor makes failure exit nonzero'
        $assertion = Invoke-FixtureScript 'fixture-assertion' @'
extends SceneTree
const Context = preload("res://tests/support/test_context.gd")
func _initialize() -> void:
    var ctx := Context.new("intentional-assertion", 4702012)
    ctx.check(false, "intentional assertion failure")
    ctx.done()
    quit(1 if not ctx.failures.is_empty() else 0)
'@ $true 'HORDE_ASSERTION_FAILED='
        Assert-Fixture ($assertion.ExitCode -eq 1) 'native failed assertion makes failure exit nonzero'
        [void](Invoke-FixtureScript 'fixture-parse' "extends SceneTree`nfunc invalid( -> void:`n" $true 'Parse Error')
        $runtime = Invoke-FixtureScript 'fixture-runtime' @'
extends SceneTree
func _initialize() -> void:
    call_deferred("bad_call")
    call_deferred("finish")
func bad_call() -> void:
    var values := []
    print(values[3])
func finish() -> void:
    quit(0)
'@ $true 'SCRIPT ERROR:'
        Assert-Fixture ($runtime.ExitCode -eq 0) 'real runtime exception exit zero still fails'
        [void](Invoke-FixtureScript 'fixture-resource' @'
extends SceneTree
func _initialize() -> void:
    var missing := "res://.cache/intentional-missing-resource.tres"
    if ResourceLoader.exists(missing):
        quit(2)
        return
    # Deliberately load known absence to validate the selected engine's format.
    ResourceLoader.load(missing)
    quit(0)
'@ $true 'ERROR:')
        $timeout = Invoke-FixtureScript 'fixture-timeout' @'
extends SceneTree
func _initialize() -> void:
    print("HORDE_TIMEOUT_PID=" + str(OS.get_process_id()))
    OS.delay_msec(5000)
    quit(0)
'@ $true 'HORDE_TIMEOUT_PID=' 1
        Assert-Fixture $timeout.TimedOut 'child timeout enforced'
        foreach ($pidValue in @($timeout.ChildId, [int]([regex]::Match($timeout.Output, 'HORDE_TIMEOUT_PID=(\d+)').Groups[1].Value))) {
            $alive = $false
            try { $probeProcess = [Diagnostics.Process]::GetProcessById($pidValue); $alive = -not $probeProcess.HasExited; $probeProcess.Dispose() }
            catch [ArgumentException] { $alive = $false }
            Assert-Fixture (-not $alive) "launched/owned process $pidValue cleaned up"
        }
        foreach ($kind in @('empty', 'duplicate', 'missing', 'unregistered', 'unexecuted')) {
            $code = @'
extends SceneTree
const Manifest = preload("res://tests/case_manifest.gd")
func _initialize() -> void:
    var entry := {"id":"one", "script":"fixture", "maps":["fixture"], "seed":1, "expected":[]}
    var found := {"id":"one", "script":"fixture"}
    var required := [entry]
    var discovered := [found]
    var executed := ["one"]
    match "FIXTURE_KIND":
        "empty":
            required = []
            discovered = []
            executed = []
        "duplicate": required.append(entry)
        "missing": discovered = []
        "unregistered": required = []
        "unexecuted": executed = []
    var errors: Array[String] = Manifest.reconcile(required, discovered, executed, true)
    print("RECONCILIATION=" + str(errors))
    quit(1 if not errors.is_empty() else 0)
'@
            $code = $code.Replace('FIXTURE_KIND', $kind)
            $result = Invoke-FixtureScript "fixture-runner-$kind" $code $true 'RECONCILIATION='
            Assert-Fixture ($result.ExitCode -eq 1) "runner $kind nonzero failure"
        }
        Write-Host "Infrastructure fixtures: $($fixtureChecks.Count) assertions passed."
        $fixturesCompleted = $true
    } finally {
        Write-ContainedText (Join-Path $sessionDir 'infrastructure-child-results.json') (ConvertTo-Json -InputObject @($script:results.ToArray()) -Depth 10)
        Write-ContainedText (Join-Path $sessionDir 'infrastructure-fixtures.json') (ConvertTo-Json -InputObject @($fixtureChecks.ToArray()) -Depth 6)
        $script:results = $parentResults
        $passed = $fixturesCompleted -and $fixtureChecks.Count -gt 0 -and @($fixtureChecks | Where-Object Outcome -eq 'FAILED').Count -eq 0
        $script:results.Add([pscustomobject]@{Name='infrastructure';Outcome=if ($passed) {'PASSED'} else {'FAILED'};Assertions=$fixtureChecks.Count})
    }
}

if (-not $DefineOnly) {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $saved = @{}
    $variables = [Environment]::GetEnvironmentVariables('Process')
    foreach ($name in @('APPDATA', 'LOCALAPPDATA', 'TEMP', 'TMP', 'GODOT_BIN')) { $saved[$name] = @{Present=$variables.Contains($name);Value=$variables[$name]} }
    $fixtureExit = 1
    try {
        # Test real restoration of expected absence as well as present values.
        if (Test-Path -LiteralPath 'Env:TEMP') { Remove-Item -LiteralPath 'Env:TEMP' }
        $before = [Environment]::GetEnvironmentVariables('Process')
        if ($before.Contains('TEMP')) { throw 'FAILED: fixture could not create an absent TEMP.' }
        # Infrastructure remains independently runnable while authored gameplay
        # cases wait for Phase 3B. Full-suite acceptance still uses default All.
        $arguments = @{Mode='All';InfrastructureFixtures=$true;SuiteScope='Foundation';RenderedProfileSmoke=$RenderedProfileSmoke}
        if ($PSBoundParameters.ContainsKey('FixtureGodotBin')) { $arguments.GodotBin = $FixtureGodotBin }
        & (Join-Path $PSScriptRoot 'validate.ps1') @arguments
        $fixtureExit = $LASTEXITCODE
        $after = [Environment]::GetEnvironmentVariables('Process')
        foreach ($name in $saved.Keys) {
            if ($before.Contains($name) -ne $after.Contains($name) -or $before[$name] -cne $after[$name]) { throw "FAILED: environment restoration for $name." }
            Write-Host "FIXTURE [environment restoration $name]: PASSED (present=$($after.Contains($name)))"
        }
    } finally {
        foreach ($name in $saved.Keys) {
            if ($saved[$name].Present) { [Environment]::SetEnvironmentVariable($name, $saved[$name].Value, 'Process') }
            elseif (Test-Path -LiteralPath "Env:$name") { Remove-Item -LiteralPath "Env:$name" }
        }
    }
    exit $fixtureExit
}
