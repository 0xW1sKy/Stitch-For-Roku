#!/usr/bin/env pwsh

$version = gitversion | ConvertFrom-Json

$manifest = Get-Content ./manifest
$output = ""
$manifest | ForEach-Object {
    if ($_ -like "major_version=*") {
        $output += $("major_version=$($version.major)`n")
    }
    elseif ($_ -like "minor_version=*") {
        $output += $("minor_version=$($version.minor)`n")
    }
    elseif ($_ -like "build_version=*") {
        $output += $("build_version=$("$($version.patch)".padleft(2,"0"))$($version.CommitsSinceVersionSource)`n")
    }
    else {
        $output += "$($_)`n"
    }
}
Set-Content ./manifest -Value $output
git add ./manifest