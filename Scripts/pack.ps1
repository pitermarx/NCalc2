$config = if ($isAppVeyor) { $env:CONFIGURATION } else { "Debug" }
$root = (split-path -parent $MyInvocation.MyCommand.Definition) + '\..'
$version = [System.Reflection.Assembly]::LoadFile("$root\NCalc2\bin\$config\NCalc2.dll").GetName().Version
$versionStr = "{0}.{1}.{2}" -f ($version.Major, $version.Minor, $version.Build)

$content = (Get-Content $root\NCalc2\NCalc2.nuspec)

Write-Host "Setting .nuspec version tag to $versionStr"
$content = $content -replace '\$version\$',$versionStr

Write-Host "Setting .nuspec configuratio to $config"
$content = $content -replace '\$config\$',$config

$content | Out-File $root\NCalc2\NCalc2.compiled.nuspec

& nuget pack $root\NCalc2\NCalc2.compiled.nuspec
