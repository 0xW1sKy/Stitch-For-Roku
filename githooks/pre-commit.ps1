#!/usr/bin/env pwsh

$version = gitversion | ConvertFrom-Json

$manifest = Get-Content ./manifest