#!/usr/bin/env pwsh

$version = gitversion | ConvertFrom-Json

$manifest = Get-Content ./roku/manifest
$output = ""
$manifest | ForEach-Object {
    if ($_ -like "major_version=*") {
        $output += $("major_version=$($version.major)`r`n")
    }
    elseif ($_ -like "minor_version=*") {
        $output += $("minor_version=$($version.minor + 1)`r`n")
    }
    elseif ($_ -like "build_version=*") {
        $output += $("build_version=$("$($version.patch)".padleft(2,"0"))$($version.CommitsSinceVersionSource)`r`n")
    }
    else {
        $output += "$($_)`r`n"
    }
}
Set-Content ./roku/manifest -Value $output
git add ./roku/manifest