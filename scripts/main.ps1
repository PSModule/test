﻿$ErrorActionPreference = $env:ErrorAction

Get-ChildItem -Path (Join-Path $env:GITHUB_ACTION_PATH 'scripts' 'helpers') -Filter '*.ps1' -Recurse | ForEach-Object {
    Write-Verbose "[$($_.FullName)]" -Verbose
    . $_.FullName
}

$moduleName = [string]::IsNullOrEmpty($env:Name) ? $env:GITHUB_REPOSITORY -replace '.+/', '' : $env:Name
$codeToTest = Join-Path $env:GITHUB_WORKSPACE $env:Path $moduleName
if (-not (Test-Path -Path $codeToTest)) {
    throw "Module path [$codeToTest] does not exist."
}

try {
    $params = @{
        Path = $codeToTest
    }
    Invoke-PSModuleTest @params
} catch {
    if ($ErrorActionPreference -like '*Continue') {
        Write-Output '::warning::Errors were ignored.'
        exit
    } else {
        Write-Host "::error::$_"
        exit 1
    }
}
