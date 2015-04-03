# Variables
$isAppVeyor = if ($env:CONFIGURATION) { $TRUE } else { $FALSE }
$config = if ($isAppVeyor) { $env:CONFIGURATION } else { "Debug" }
$nunit = if ($isAppVeyor) { "nunit-console" } else { "packages\NUnit.Runners.2.6.4\tools\nunit-console.exe" }

Write-Host "----------------------"
Write-Host "   Running Coverage   "
Write-Host "----------------------"
& .\packages\OpenCover.4.5.3522\OpenCover.Console.exe -register:user -returntargetcode `
"-filter:+[NCalc2]* -[NCalc2]*.Grammar.* -[NCalc2.Tests]*" `
"-target:.\scripts\nunit.bat" "-targetargs: $nunit $config"

if ($isAppVeyor)
{
    Write-Host "----------------------------"
    Write-Host "Sending data to Coveralls.io"
    Write-Host "----------------------------"
    & .\packages\coveralls.net.0.5.0\csmacnz.Coveralls.exe --opencover -i results.xml `
    --repoToken $env:COVERALLS_TOKEN --commitId $env:APPVEYOR_REPO_COMMIT `
    --commitBranch $env:APPVEYOR_REPO_BRANCH --commitAuthor pitermarx `
    --commitEmail $env:EMAIL --commitMessage $env:APPVEYOR_REPO_COMMIT_MESSAGE `
    --jobId $env:APPVEYOR_JOB_ID
}
else
{
    Write-Host "----------------------"
    Write-Host "Generating HTML Report"
    Write-Host "----------------------"
    & .\packages\ReportGenerator.2.1.4.0\ReportGenerator.exe -reports:results.xml `
    -targetdir:Reports\Latest -sourcedirs:NCalc2 -historydir:Reports\History
}
