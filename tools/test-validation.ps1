<#
.SYNOPSIS
Exercise real launcher functions and selected-engine diagnostic/timeout fixtures.
.DESCRIPTION
Runs All first so no fixture engine command bypasses verified containment.
Intentional child failures stay in infrastructure-child-results.json. A fixture
passes only when its asserted failure, diagnostic, cleanup and exit are observed.
#>
[CmdletBinding()]
param([Alias('GodotBin')][string] $FixtureGodotBin, [switch] $DefineOnly)

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
        $arguments = @{Mode='All';InfrastructureFixtures=$true;SuiteScope='Foundation'}
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
