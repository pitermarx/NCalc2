$root = (split-path -parent $MyInvocation.MyCommand.Definition) + '\..'
$version = [System.Reflection.Assembly]::LoadFile("$root\Evaluant.Calculator\bin\Release\NCalc.dll").GetName().Version
$versionStr = "{0}.{1}.{2}" -f ($version.Major, $version.Minor, $version.Build)

Write-Host "Setting .nuspec version tag to $versionStr"

$content = (Get-Content $root\NuGet\NCalc2.nuspec)
$content = $content -replace '\$version\$',$versionStr

$content | Out-File $root\nuget\NCalc2.compiled.nuspec

& nuget pack $root\nuget\NCalc2.compiled.nuspec
