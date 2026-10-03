Set-StrictMode -Version Latest

function Get-ValidationDiagnostics {
    [CmdletBinding()]
    param([AllowEmptyString()][string] $Text, [AllowEmptyString()][string] $EngineLog = '', [switch] $AllowCaseDeclarations, [switch] $RequireProfileResult)
    $plain = [regex]::Replace($Text, '\x1B\[[0-?]*[ -/]*[@-~]', '')
    $logPlain = [regex]::Replace($EngineLog, '\x1B\[[0-?]*[ -/]*[@-~]', '')
    $errors = [Collections.Generic.List[string]]::new()
    $warnings = [Collections.Generic.List[string]]::new()
    $ambiguous = [Collections.Generic.List[string]]::new()
    $expectedFaults = [Collections.Generic.List[object]]::new()
    $cases = @{}
    $summary = $null
    $profileResults = @()
    $certificateStoreFailure = $false
    # Severity records from either copy count, but duplicate stream/log copies
    # do not multiply application diagnostic expectations.
    foreach ($line in (($plain + "`n" + $logPlain) -split '\r?\n' | Select-Object -Unique)) {
        if ($line -match 'Failed to read the root certificate store') {
            $certificateStoreFailure = $true
            $errors.Add($line)
        }
        elseif ($line -match '^\s*(?:SCRIPT ERROR|PARSE ERROR|RUNTIME ERROR|FATAL ERROR|ERROR):') { $errors.Add($line) }
        elseif ($line -match '^\s*WARNING:') { $warnings.Add($line) }
        elseif ($line -match '^\s*(?:SCRIPT ERROR|PARSE ERROR|RUNTIME ERROR|FATAL ERROR|ERROR|WARNING)\b' -or
                $line -match '^\s*(?:Failed (?:loading|to load) resource|Parse Error|Exception|Unhandled exception)\s*[:(]') {
            $ambiguous.Add($line)
        }
    }
    foreach ($line in ($plain -split '\r?\n')) {
        if ($RequireProfileResult -and $line.StartsWith('HORDE_PROFILE_RESULT=')) {
            try {
                $receipt = $line.Substring('HORDE_PROFILE_RESULT='.Length) | ConvertFrom-Json -ErrorAction Stop
                $profileResults += $receipt
                if ($receipt.profile_capture_outcome -cne 'passed' -or @($receipt.capture_diagnostics).Count -ne 0 -or
                    [string]::IsNullOrWhiteSpace($receipt.evidence_path) -or [string]::IsNullOrWhiteSpace($receipt.frame_evidence_path) -or
                    $receipt.frame_sample_count -lt 0 -or $receipt.acceptance_invalid -cne $false) {
                    throw 'Incomplete/invalid application capture; inspect evidence and diagnostics.'
                }
            } catch { $errors.Add("Invalid Profile result: $($_.Exception.Message)") }
        }
        if ($line -notmatch '^HORDE_(CASE_BEGIN|APP_DIAGNOSTIC|CASE_END|SUITE_END|ASSERTION_FAILED|SUITE_FAILURE)=') { continue }
        $kind = $Matches[1]
        if ($kind -in @('ASSERTION_FAILED', 'SUITE_FAILURE')) { $errors.Add($line); continue }
        if (-not $AllowCaseDeclarations) { $errors.Add("Undeclared application/test record: $line"); continue }
        try {
            $record = $line.Substring($line.IndexOf('=') + 1) | ConvertFrom-Json -ErrorAction Stop
            switch ($kind) {
                'CASE_BEGIN' {
                    if ($cases.ContainsKey([string]$record.case)) { throw 'Duplicate case begin.' }
                    $declarations = @($record.expected)
                    foreach ($declaration in $declarations) {
                        if ([string]::IsNullOrWhiteSpace($declaration.source) -or [string]::IsNullOrWhiteSpace($declaration.constraint) -or
                            $declaration.count -isnot [long] -and $declaration.count -isnot [int] -or $declaration.count -lt 1) { throw 'Invalid expected diagnostic declaration.' }
                    }
                    $cases[[string]$record.case] = @{ Expected=$declarations; Counts=@{}; Ended=$false }
                }
                'APP_DIAGNOSTIC' {
                    if (-not $cases.ContainsKey([string]$record.case) -or $cases[[string]$record.case].Ended) { throw 'Diagnostic outside an open declared case.' }
                    foreach ($field in @('source', 'field', 'observed', 'constraint', 'cause')) {
                        if ($null -eq $record.PSObject.Properties[$field]) { throw "Missing application diagnostic $field." }
                    }
                    $case = $cases[[string]$record.case]
                    $matching = @()
                    for ($i=0; $i -lt $case.Expected.Count; $i++) {
                        if ($record.source -ceq $case.Expected[$i].source -and $record.constraint -ceq $case.Expected[$i].constraint) { $matching += $i }
                    }
                    if ($matching.Count -ne 1) { throw 'Unexpected/ambiguous application source or constraint.' }
                    $index = $matching[0]
                    if (-not $case.Counts.ContainsKey($index)) { $case.Counts[$index] = 0 }
                    $case.Counts[$index]++
                    $expectedFaults.Add($record)
                }
                'CASE_END' {
                    if (-not $cases.ContainsKey([string]$record.case) -or $cases[[string]$record.case].Ended) { throw 'Missing/duplicate case begin.' }
                    $case = $cases[[string]$record.case]
                    $case.Ended = $true
                    if ($record.passed -cne $true -or $record.completed -cne $true -or $record.assertions -lt 1) { throw 'Failed/incomplete/empty case.' }
                    for ($i=0; $i -lt $case.Expected.Count; $i++) {
                        $count = if ($case.Counts.ContainsKey($i)) { $case.Counts[$i] } else { 0 }
                        if ($count -ne $case.Expected[$i].count) { throw 'Expected diagnostic count mismatch.' }
                    }
                }
                'SUITE_END' {
                    if ($null -ne $summary) { throw 'Duplicate suite summary.' }
                    $summary = $record
                    if ($record.passed -cne $true -or $record.required -lt 1 -or $record.executed -ne $record.required -or $record.assertions -lt 1) { throw 'Failed/incomplete/empty suite.' }
                }
            }
        } catch { $errors.Add("Invalid $kind record: $($_.Exception.Message) Original: $line") }
    }
    # stderr is collected separately from stdout, so correlate each printed
    # capture payload with one fully validated, case-tagged application record.
    # Preserve multiplicity and log-only faults without counting duplicate copies.
    $captureLines = [Collections.Generic.List[string]]::new()
    $streamCounts = @{}
    $logCounts = @{}
    foreach ($line in ($plain -split '\r?\n' | Where-Object { $_ -match '^\s*Profile capture failure:' })) {
        $captureLines.Add($line)
        $streamCounts[$line] = 1 + [int]$streamCounts[$line]
    }
    foreach ($line in ($logPlain -split '\r?\n' | Where-Object { $_ -match '^\s*Profile capture failure:' })) {
        $logCounts[$line] = 1 + [int]$logCounts[$line]
    }
    foreach ($line in $logCounts.Keys) {
        for ($i=[int]$streamCounts[$line]; $i -lt $logCounts[$line]; $i++) { $captureLines.Add($line) }
    }
    $usedCaptureRecords = @{}
    foreach ($line in $captureLines) {
        try {
            if (-not $AllowCaseDeclarations) { throw 'Capture failure outside declared suite.' }
            $fault = ($line -replace '^\s*Profile capture failure:\s*', '') | ConvertFrom-Json -ErrorAction Stop
            if (@($fault.PSObject.Properties).Count -ne 5) { throw 'Capture payload must contain exactly the five declared diagnostic fields.' }
            $matching = @()
            for ($i=0; $i -lt $expectedFaults.Count; $i++) {
                if ($usedCaptureRecords.ContainsKey($i)) { continue }
                $candidate = $expectedFaults[$i]
                $same = $candidate.source -ceq 'ProfileCapture' -and $cases[[string]$candidate.case].Ended
                foreach ($field in @('source', 'field', 'observed', 'constraint', 'cause')) {
                    if ($null -eq $fault.PSObject.Properties[$field] -or $fault.$field -cne $candidate.$field) { $same = $false }
                }
                if ($same) { $matching += $i }
            }
            if ($matching.Count -ne 1) { throw 'Capture payload lacks one exact declared case diagnostic.' }
            $usedCaptureRecords[$matching[0]] = $true
        } catch { $errors.Add("$line ($($_.Exception.Message))") }
    }
    if ($AllowCaseDeclarations) {
        if ($null -eq $summary -or $summary.executed -ne $cases.Count) { $errors.Add('Missing or inconsistent native-suite completion evidence.') }
        foreach ($caseId in $cases.Keys) { if (-not $cases[$caseId].Ended) { $errors.Add("Unfinished case: $caseId") } }
    }
    if ($RequireProfileResult -and $profileResults.Count -ne 1) { $errors.Add('Missing or duplicate application Profile completion result.') }
    return [pscustomobject]@{
        Errors=@($errors.ToArray()); Warnings=@($warnings.ToArray()); Ambiguous=@($ambiguous.ToArray())
        ExpectedApplicationFaults=@($expectedFaults.ToArray())
        ProfileResults=@($profileResults)
        CertificateStoreFailure=$certificateStoreFailure
        Failed=($errors.Count -gt 0 -or $ambiguous.Count -gt 0)
    }
}
