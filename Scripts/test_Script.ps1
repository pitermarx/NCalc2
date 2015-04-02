cd scripts

# Variables
$config = if ($env:CONFIGURATION) { $env:CONFIGURATION } else { "Debug" }

Write-Host "----------------------"
Write-Host "   Running Coverage   "
Write-Host "----------------------"
& ..\packages\OpenCover.4.5.3522\OpenCover.Console.exe -register:user `
-returntargetcode "-filter:+[NCalc*]*" "-target:nunit.bat" `
"-targetargs: $config"

Write-Host "----------------------------"
Write-Host "Sending data to Coveralls.io"
Write-Host "----------------------------"
& ..\packages\coveralls.net.0.5.0\csmacnz.Coveralls.exe --opencover -i results.xml `
--repoToken $env:COVERALLS_REPO_TOKEN --commitId $env:APPVEYOR_REPO_COMMIT `
--commitBranch $env:APPVEYOR_REPO_BRANCH --commitAuthor pitermarx `
--commitEmail pedrohmarques@gmail.com --commitMessage $env:APPVEYOR_REPO_COMMIT_MESSAGE `
--jobId $env:APPVEYOR_JOB_ID

Write-Host "----------------------"
Write-Host "Generating HTML Report"
Write-Host "----------------------"
& ..\packages\ReportGenerator.2.1.4.0\ReportGenerator.exe -reports:results.xml `
-targetdir:Reports\Latest -sourcedirs:Evaluant.Calculator -historydir:Reports\History
