<#
.SYNOPSIS
Launch Project Horde checks with workspace-contained Godot paths.
.DESCRIPTION
All imports, parses every source/test GDScript, runs the future native suite,
and starts main. Missing later-phase prerequisites are BLOCKED, never passes.
Play/Profile wait for the interactive child without an automatic timeout.
No installation, persistent environment change or external marker is made.
#>
[CmdletBinding()]
param(
    [string] $GodotBin,
    [ValidateSet('All', 'Play', 'Profile')][string] $Mode = 'All',
    [switch] $InfrastructureFixtures,
    [switch] $RenderedProfileSmoke,
    [ValidateSet('All', 'Foundation')][string] $SuiteScope = 'All',
    [ValidateRange(1, 86400)][int] $PreflightTimeoutSeconds = 30,
    [ValidateRange(1, 86400)][int] $ImportTimeoutSeconds = 180,
    [ValidateRange(1, 86400)][int] $ParseTimeoutSeconds = 30,
    [ValidateRange(1, 86400)][int] $SuiteTimeoutSeconds = 120,
    [ValidateRange(1, 86400)][int] $StartupTimeoutSeconds = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$workspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\', '/')
$cacheRoot = Join-Path $workspace '.cache'
$results = [Collections.Generic.List[object]]::new()
$savedEnvironment = @{}
$sessionDir = $null
$exitStatus = 1
$utf8 = [Text.UTF8Encoding]::new($false)
. (Join-Path $PSScriptRoot 'validation_diagnostics.ps1')

function Assert-NoReparsePoint([string] $Path) {
    # Reject junction/symlink escapes in existing ancestors before any write.
    $cursor = [IO.Path]::GetFullPath($Path)
    while (-not [string]::IsNullOrEmpty($cursor)) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "BLOCKED: reparse point prevents verified containment: $cursor"
            }
        }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
}

function Assert-ContainedPath([string] $Path, [string] $Root = $workspace) {
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+\\)') {
        throw "BLOCKED: expected an absolute Windows path, observed '$Path'."
    }
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    if (-not $full.Equals($base, [StringComparison]::OrdinalIgnoreCase) -and
        -not $full.StartsWith($base + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw "BLOCKED: path '$full' is outside '$base'."
    }
    Assert-NoReparsePoint $full
    return $full
}

function New-ContainedDirectory([string] $Path) {
    $full = Assert-ContainedPath $Path
    [void][IO.Directory]::CreateDirectory($full)
    return $full
}

function Write-ContainedText([string] $Path, [string] $Text) {
    $full = Assert-ContainedPath $Path
    [IO.File]::WriteAllText($full, $Text, $utf8)
}

function Resolve-GodotExecutable {
    param([bool] $Explicit = $script:explicitGodotBin, [string] $Override = $GodotBin,
          [scriptblock] $ReadScope = { param($Scope) [Environment]::GetEnvironmentVariables($Scope) })
    if ($Explicit) {
        if ([string]::IsNullOrWhiteSpace($Override)) { throw 'BLOCKED: explicit -GodotBin is empty; no fallback is permitted.' }
        Write-Host 'Executable selection: explicit -GodotBin override.'
        return $Override
    }
    foreach ($scope in @('Process', 'User', 'Machine')) {
        try {
            $variables = & $ReadScope $scope
            if (-not $variables.Contains('GODOT_BIN') -or [string]::IsNullOrWhiteSpace([string]$variables['GODOT_BIN'])) {
                Write-Host "GODOT_BIN $scope scope: absent/empty (registry isolation may hide persistent values)."
                continue
            }
            Write-Host "Executable selection: first nonempty GODOT_BIN in $scope scope."
            return [string]$variables['GODOT_BIN']
        } catch {
            throw "BLOCKED: cannot inspect GODOT_BIN $scope scope: $($_.Exception.Message). Supply -GodotBin explicitly."
        }
    }
    throw 'BLOCKED: GODOT_BIN absent/empty in Process, User and Machine scopes, or hidden by registry isolation. Supply an absolute console executable with -GodotBin; no installation was attempted.'
}

function Assert-ConsoleExecutable([string] $Path) {
    if ($Path -notmatch '^(?:[A-Za-z]:[\\/]|\\\\[^\\]+\\[^\\]+\\)' -or [IO.Path]::GetExtension($Path) -ine '.exe') {
        throw "BLOCKED: GodotBin must be an absolute Windows .exe path: '$Path'."
    }
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "BLOCKED: selected executable does not exist: $Path. No fallback is permitted." }
    Assert-NoReparsePoint $Path
    $stream = [IO.File]::OpenRead($Path)
    $reader = [IO.BinaryReader]::new($stream)
    try {
        if ($reader.ReadUInt16() -ne 0x5A4D) { throw 'Missing DOS MZ header.' }
        $stream.Position = 0x3C
        $peOffset = $reader.ReadUInt32()
        if ($peOffset + 94 -gt $stream.Length) { throw 'Truncated PE header.' }
        $stream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x4550) { throw 'Missing PE signature.' }
        $stream.Position = $peOffset + 24
        if ($reader.ReadUInt16() -notin @(0x10B, 0x20B)) { throw 'Unsupported PE optional header.' }
        $stream.Position = $peOffset + 24 + 68
        if ($reader.ReadUInt16() -ne 3) { throw 'PE subsystem is not Windows console (3).' }
    } catch {
        throw "BLOCKED: selected executable is not a verified Windows console binary: $Path. $($_.Exception.Message)"
    } finally { $reader.Dispose(); $stream.Dispose() }
    # Self-contained Godot can ignore APPDATA and write beside its binary.
    foreach ($marker in @('._sc_', '_sc_')) {
        $markerPath = Join-Path (Split-Path -Parent $Path) $marker
        if (Test-Path -LiteralPath $markerPath) {
            [void](Assert-ContainedPath (Join-Path (Split-Path -Parent $Path) 'editor_data') $cacheRoot)
        }
    }
    return [IO.Path]::GetFullPath($Path)
}

function ConvertTo-WindowsArgument([string] $Value) {
    # ProcessStartInfo.Arguments needs Windows argv quoting, not shell quoting.
    if ($Value -notmatch '[\s"]' -and $Value.Length -gt 0) { return $Value }
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function Invoke-GodotCheck {
    param([string] $Name, [string[]] $Arguments, [string] $WorkingDirectory,
          [int] $TimeoutSeconds, [switch] $Interactive)
    [void](Assert-ContainedPath $WorkingDirectory)
    $logPath = Assert-ContainedPath (Join-Path $sessionDir "$Name.engine.log") $cacheRoot
    $stdoutPath = Join-Path $sessionDir "$Name.stdout.txt"
    $stderrPath = Join-Path $sessionDir "$Name.stderr.txt"
    # Engine switches must precede the user-argument delimiter in Profile mode.
    $userDelimiter = [Array]::IndexOf($Arguments, '--')
    if ($userDelimiter -ge 0) {
        $argv = @($Arguments | Select-Object -First $userDelimiter) + @('--log-file', $logPath) + @($Arguments | Select-Object -Skip $userDelimiter)
    } else { $argv = @($Arguments) + @('--log-file', $logPath) }
    $command = (ConvertTo-WindowsArgument $engine) + ' ' + (($argv | ForEach-Object { ConvertTo-WindowsArgument $_ }) -join ' ')
    Write-Host "COMMAND [$Name]: $command"
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $engine
    $startInfo.Arguments = ($argv | ForEach-Object { ConvertTo-WindowsArgument $_ }) -join ' '
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $child = [Diagnostics.Process]::new()
    $child.StartInfo = $startInfo
    $timedOut = $false
    $launched = $false
    try {
        if (-not $child.Start()) { throw "Could not start child for $Name." }
        $launched = $true
        $stdoutTask = $child.StandardOutput.ReadToEndAsync()
        $stderrTask = $child.StandardError.ReadToEndAsync()
        if ($Interactive) { $child.WaitForExit() }
        elseif (-not $child.WaitForExit($TimeoutSeconds * 1000)) {
            $timedOut = $true
            # Kill this launched child only; the official console wrapper owns its engine job.
            if (-not $child.HasExited) { $child.Kill() }
            if (-not $child.WaitForExit(5000)) { throw "TIMEOUT: launched child $($child.Id) did not terminate." }
        }
        # Bounded drain: do not hang forever if an unsupported wrapper leaves pipe owners alive.
        if (-not $stdoutTask.Wait(5000) -or -not $stderrTask.Wait(5000)) {
            throw "FAILED: $Name output pipes remain open after child exit; process cleanup is unverified."
        }
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        Write-ContainedText $stdoutPath $stdout
        Write-ContainedText $stderrPath $stderr
        $engineLog = ''
        if (Test-Path -LiteralPath $logPath -PathType Leaf) { $engineLog = [IO.File]::ReadAllText($logPath) }
        $combined = $stdout + "`n" + $stderr + "`n" + $engineLog
        $plain = [regex]::Replace($combined, '\x1B\[[0-?]*[ -/]*[@-~]', '')
        $diagnostics = Get-ValidationDiagnostics -Text ($stdout + "`n" + $stderr) -EngineLog $engineLog -AllowCaseDeclarations:($Name -eq 'suite') -RequireProfileResult:($Name -in @('profile', 'profile-startup'))
        try {
            if (-not $diagnostics.Failed) {
                foreach ($receipt in $diagnostics.ProfileResults) {
                    $attemptReceipts = @($receipt)
                    if ($null -ne $receipt.PSObject.Properties['retained_attempts']) { $attemptReceipts += @($receipt.retained_attempts) }
                    foreach ($attemptReceipt in $attemptReceipts) {
                        if ($attemptReceipt.profile_capture_outcome -cne 'passed' -or @($attemptReceipt.capture_diagnostics).Count -ne 0) {
                            throw 'FAILED: a Profile attempt has incomplete capture; fresh counters do not erase prior failures.'
                        }
                        foreach ($path in @($attemptReceipt.evidence_path, ($attemptReceipt.evidence_path + '.outcomes.json'), $attemptReceipt.frame_evidence_path)) {
                            [void](Assert-ContainedPath $path $cacheRoot)
                            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "FAILED: required Profile evidence is missing: $path" }
                        }
                        if ((Get-Item -LiteralPath $attemptReceipt.frame_evidence_path).Length -ne $attemptReceipt.frame_sample_count * 8) {
                            throw 'FAILED: Profile raw stream length disagrees with the completion result.'
                        }
                        $manifest = [IO.File]::ReadAllText($attemptReceipt.evidence_path) | ConvertFrom-Json
                        if ($manifest.frame_stream.sample_count -ne $attemptReceipt.frame_sample_count -or $manifest.frame_stream.path -cne $attemptReceipt.frame_evidence_path -or
                            $manifest.profile_capture_outcome -cne 'passed' -or @($manifest.capture_diagnostics).Count -ne 0) {
                            throw 'FAILED: Profile manifest disagrees with the completion result.'
                        }
                        $outcomes = [IO.File]::ReadAllText($attemptReceipt.evidence_path + '.outcomes.json') | ConvertFrom-Json
                        if ($outcomes.profile_capture_outcome -cne 'passed' -or @($outcomes.capture_diagnostics).Count -ne 0) {
                            throw 'FAILED: persisted Profile outcome reports incomplete capture.'
                        }
                    }
                    Write-Host "Profile capture: $($receipt.profile_capture_outcome); survival: $($receipt.survival_window_outcome); continuation: $($receipt.continuation_outcome). Owner/performance acceptance requires ledger review."
                }
            }
        } catch {
            $diagnostics.Errors += $_.Exception.Message
            $diagnostics.Failed = $true
        }
        $outcome = if ($timedOut -or $child.ExitCode -ne 0 -or $diagnostics.Failed) { 'FAILED' } else { 'PASSED' }
        $result = [pscustomobject]@{Name=$Name; Command=$command; ChildId=$child.Id; ExitCode=$child.ExitCode; Outcome=$outcome; TimedOut=$timedOut; TimeoutSeconds=if ($Interactive) {$null} else {$TimeoutSeconds}; Stdout=$stdoutPath; Stderr=$stderrPath; EngineLog=$logPath; Warnings=$diagnostics.Warnings; Diagnostics=$diagnostics; Output=$plain}
        $results.Add($result)
        Write-Host "RESULT [$Name]: $outcome; exit=$($child.ExitCode); timeout=$timedOut; logs=$sessionDir"
        foreach ($warning in $diagnostics.Warnings) { Write-Host "Recorded $warning" }
        foreach ($record in $diagnostics.Ambiguous) { Write-Host "INVESTIGATE: ambiguous diagnostic: $record" }
        if ($outcome -ne 'PASSED') {
            Write-Host $plain
            if ($timedOut) { throw "FAILED: $Name exceeded its ${TimeoutSeconds}s limit; launched child terminated. Inspect retained logs, then explicitly override the limit to retry." }
            throw "FAILED: $Name exited $($child.ExitCode) or reported an engine/application error or incomplete capture; dependent checks were not run. Inspect $logPath and captured streams."
        }
        return $result
    } finally {
        if ($launched -and -not $child.HasExited) { $child.Kill(); [void]$child.WaitForExit(5000) }
        $child.Dispose()
    }
}

function Add-BlockedCheck([string] $Name, [string] $Reason) {
    $results.Add([pscustomobject]@{Name=$Name; Outcome='BLOCKED'; ExitCode=$null; Reason=$Reason})
    Write-Host "RESULT [$Name]: BLOCKED; $Reason"
}

$explicitGodotBin = $PSBoundParameters.ContainsKey('GodotBin')
try {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'BLOCKED: this launcher requires the approved Windows environment.' }
    Assert-NoReparsePoint $workspace
    $engine = Assert-ConsoleExecutable (Resolve-GodotExecutable)
    $sessionDir = New-ContainedDirectory (Join-Path $cacheRoot ('validation/' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfff') + '-' + [Guid]::NewGuid().ToString('N')))
    $processEnvironment = [Environment]::GetEnvironmentVariables('Process')
    foreach ($name in @('APPDATA', 'LOCALAPPDATA', 'TEMP', 'TMP')) {
        $savedEnvironment[$name] = @{ Present=$processEnvironment.Contains($name); Value=$processEnvironment[$name] }
        $isolatedPath = New-ContainedDirectory (Join-Path $sessionDir $name.ToLowerInvariant())
        [Environment]::SetEnvironmentVariable($name, $isolatedPath, 'Process')
    }
    # An isolated preflight project contains only our path-report script. No game
    # resources, plugins or scenes execute until its observed paths are verified.
    $probeDir = New-ContainedDirectory (Join-Path $sessionDir 'preflight')
    Write-ContainedText (Join-Path $probeDir 'project.godot') @'
config_version=5
[application]
config/name="Project Horde"
config/use_custom_user_dir=false
[rendering]
renderer/rendering_method="gl_compatibility"
[editor_plugins]
enabled=PackedStringArray("res://addons/horde_path_probe/plugin.cfg")
'@
    $probeAddonDir = New-ContainedDirectory (Join-Path $probeDir 'addons/horde_path_probe')
    Write-ContainedText (Join-Path $probeAddonDir 'plugin.cfg') @'
[plugin]
name="Horde containment preflight"
description="Reports paths before the real project is allowed to execute."
author="Project Horde"
version="1"
script="paths.gd"
'@
    Write-ContainedText (Join-Path $probeAddonDir 'paths.gd') @'
@tool
extends EditorPlugin

func _enter_tree() -> void:
    var paths: Dictionary = {
        "user": OS.get_user_data_dir(),
        "data": OS.get_data_dir(),
        "config": OS.get_config_dir(),
        "cache": OS.get_cache_dir(),
        "mono": OS.has_feature("mono"),
        "editor_available": Engine.is_editor_hint()
    }
    if Engine.is_editor_hint():
        var editor = EditorInterface.get_editor_paths()
        paths["editor_data"] = editor.get_data_dir()
        paths["editor_config"] = editor.get_config_dir()
        paths["editor_cache"] = editor.get_cache_dir()
        paths["editor_project"] = ProjectSettings.globalize_path(editor.get_project_settings_dir())
    print("HORDE_PATHS=" + JSON.stringify(paths))
'@
    $version = Invoke-GodotCheck 'version' @('--headless', '--version') $probeDir $PreflightTimeoutSeconds
    if ($version.Output -notmatch '(?m)^4\.7\.2\.stable\.official\.[0-9a-f]+\s*$' -or $version.Output -match '(?i)mono|\.net') {
        throw 'BLOCKED: version does not match approved Godot 4.7.2 Standard official stable.'
    }
    $help = Invoke-GodotCheck 'help' @('--headless', '--help') $probeDir $PreflightTimeoutSeconds
    foreach ($option in @('--headless', '--path', '--script', '--check-only', '--import', '--editor', '--quit-after', '--log-file')) {
        if (-not $help.Output.Contains($option)) { throw "BLOCKED: selected engine help does not advertise required $option." }
    }
    $probe = Invoke-GodotCheck 'paths' @('--headless', '--path', $probeDir, '--import') $probeDir $PreflightTimeoutSeconds
    $pathLines = @($probe.Output -split '\r?\n' | Where-Object { $_.StartsWith('HORDE_PATHS=') } | Select-Object -Unique)
    if ($pathLines.Count -ne 1) { throw 'BLOCKED: missing or ambiguous actual Godot path report.' }
    $paths = $pathLines[0].Substring('HORDE_PATHS='.Length) | ConvertFrom-Json
    if ($paths.mono -or -not $paths.editor_available) { throw 'BLOCKED: Standard editor paths could not be verified.' }
    foreach ($field in @('user', 'data', 'config', 'cache', 'editor_data', 'editor_config', 'editor_cache')) {
        [void](Assert-ContainedPath ([string]$paths.$field) $cacheRoot)
        Write-Host "Verified Godot $field path: $($paths.$field)"
    }
    [void](Assert-ContainedPath ([string]$paths.editor_project) $probeDir)
    Write-ContainedText (Join-Path $sessionDir 'verified-paths.json') ($paths | ConvertTo-Json)
    $projectFile = Join-Path $workspace 'project.godot'
    $mainScene = Join-Path $workspace 'scenes/main.tscn'
    if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) { throw 'BLOCKED: project.godot is missing.' }
    [void](Assert-ContainedPath $projectFile)
    [void](Assert-ContainedPath (Join-Path $workspace '.godot'))
    # Keep project user-data policy identical to the verified isolated probe.
    $projectText = [IO.File]::ReadAllText($projectFile)
    if ($projectText -notmatch '(?m)^config/name="Project Horde"\s*$' -or
        $projectText -notmatch '(?m)^config/use_custom_user_dir=false\s*$') {
        throw 'BLOCKED: project user-directory policy differs from the verified Project Horde probe; reverify paths before launch.'
    }
    if (-not (Test-Path -LiteralPath $mainScene -PathType Leaf)) { throw 'BLOCKED: scenes/main.tscn is missing.' }
    [void](Assert-ContainedPath $mainScene)
    # Import can write beside discovered sources, so reject nested links first.
    $directories = [Collections.Generic.Stack[string]]::new()
    $directories.Push($workspace)
    while ($directories.Count -gt 0) {
        $directory = $directories.Pop()
        foreach ($entry in (Get-ChildItem -LiteralPath $directory -Force)) {
            if ($directory -eq $workspace -and $entry.Name -in @('.git', '.agents', '.specify', '.cache')) { continue }
            [void](Assert-ContainedPath $entry.FullName)
            if ($entry.PSIsContainer) { $directories.Push($entry.FullName) }
        }
    }

    if ($Mode -eq 'All') {
        [void](Invoke-GodotCheck 'import' @('--headless', '--path', $workspace, '--import') $workspace $ImportTimeoutSeconds)
        $scripts = @(Get-ChildItem -LiteralPath $workspace -Recurse -File -Filter '*.gd' -Force |
            Where-Object { $_.FullName.Substring($workspace.Length + 1) -notmatch '^(?:\.cache|\.godot|\.git|\.agents|\.specify)[\\/]' } |
            Sort-Object FullName)
        if ($scripts.Count -eq 0) { Write-Host 'RESULT [parse]: SKIPPED; no project/test .gd files exist in Phase 1.'; $results.Add([pscustomobject]@{Name='parse';Outcome='SKIPPED';Reason='No project/test GDScript files.'}) }
        $index = 0
        foreach ($scriptFile in $scripts) {
            [void](Assert-ContainedPath $scriptFile.FullName)
            $index++
            [void](Invoke-GodotCheck ("parse-{0:D3}" -f $index) @('--headless', '--path', $workspace, '--script', $scriptFile.FullName, '--check-only') $workspace $ParseTimeoutSeconds)
        }
        $runner = Join-Path $workspace 'tests/run_tests.gd'
        if (Test-Path -LiteralPath $runner -PathType Leaf) {
            [void](Assert-ContainedPath $runner)
            $suiteArguments = @('--headless', '--path', $workspace, '--script', 'res://tests/run_tests.gd')
            if ($SuiteScope -eq 'Foundation') { $suiteArguments += @('--', '--foundation-only') }
            Write-Host "Native suite scope: $SuiteScope (Foundation does not validate gameplay)."
            [void](Invoke-GodotCheck 'suite' $suiteArguments $workspace $SuiteTimeoutSeconds)
        } else { Add-BlockedCheck 'suite' 'tests/run_tests.gd is not supplied until T010 (Phase 2).' }
        # A missing suite does not prevent independent bootstrap startup evidence.
        [void](Invoke-GodotCheck 'startup' @('--headless', '--path', $workspace, '--quit-after', '120') $workspace $StartupTimeoutSeconds)
		# Once US1 capture exists, exercise Main's real Profile-only lifecycle too.
		# Short headless evidence is diagnostic; it cannot qualify owner profiling.
		if (Test-Path -LiteralPath (Join-Path $workspace 'scripts/run/profile_capture.gd') -PathType Leaf) {
			[void](Invoke-GodotCheck 'profile-startup' @('--headless', '--path', $workspace, '--quit-after', '120', '--', '--profile') $workspace $StartupTimeoutSeconds)
		}
        if ($InfrastructureFixtures) {
            . (Join-Path $PSScriptRoot 'test-validation.ps1') -DefineOnly -RenderedProfileSmoke:$RenderedProfileSmoke
            Invoke-ValidationInfrastructureFixtures
        }
    } else {
        if ($Mode -eq 'Profile' -and -not (Test-Path -LiteralPath (Join-Path $workspace 'scripts/run/profile_capture.gd') -PathType Leaf)) {
            throw 'BLOCKED: Profile capture is not implemented until US1; a bootstrap run cannot produce profile evidence.'
        }
        $interactiveArguments = @('--path', $workspace)
        if ($Mode -eq 'Profile') { $interactiveArguments += @('--', '--profile') }
        [void](Invoke-GodotCheck $Mode.ToLowerInvariant() $interactiveArguments $workspace 0 -Interactive)
    }
    $exitStatus = if (@($results | Where-Object { $_.Outcome -in @('FAILED', 'BLOCKED') }).Count -gt 0) { 1 } else { 0 }
} catch {
    $failure = $_.Exception.Message
    Write-Host $failure
    $results.Add([pscustomobject]@{Name='launcher';Outcome=if ($failure.StartsWith('BLOCKED:')) {'BLOCKED'} else {'FAILED'};Reason=$failure})
    $exitStatus = 1
} finally {
    foreach ($name in $savedEnvironment.Keys) {
        if ($savedEnvironment[$name].Present) {
            [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name].Value, 'Process')
        } elseif (Test-Path -LiteralPath "Env:$name") { Remove-Item -LiteralPath "Env:$name" }
    }
    $restoredEnvironment = [Environment]::GetEnvironmentVariables('Process')
    foreach ($name in $savedEnvironment.Keys) {
        $restored = $restoredEnvironment.Contains($name) -eq $savedEnvironment[$name].Present -and
                    $restoredEnvironment[$name] -ceq $savedEnvironment[$name].Value
        $results.Add([pscustomobject]@{Name="environment-$name";Outcome=if ($restored) {'PASSED'} else {'FAILED'};Present=$restoredEnvironment.Contains($name)})
        if (-not $restored) { Write-Host "FAILED: process environment restoration for $name."; $exitStatus = 1 }
    }
    if ($null -ne $sessionDir) {
        Write-ContainedText (Join-Path $sessionDir 'results.json') (ConvertTo-Json -InputObject @($results.ToArray()) -Depth 6)
        Write-Host "Validation evidence: $sessionDir"
    }
}
exit $exitStatus
