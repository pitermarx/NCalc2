# Variables
$config = if ($env:CONFIGURATION) { $env:CONFIGURATION } else { "Debug" }

Write-Host "Running Coverage"
& .\packages\OpenCover.4.5.3522\OpenCover.Console.exe -register:user -target:"nunit-console" `
-register:user "-targetargs:""Evaluant.Calculator.Tests\bin\$config\NCalc.Tests.dll"" /noshadow" `
-filter:"+[NCalc*]*" -excludebyfile:NCalc2Lexer.cs;NCalc2Parser.cs`
-output:opencoverCoverage.xml

Write-Host "Sending data to Coveralls.io"
& .\packages\coveralls.net.0.5.0\csmacnz.Coveralls.exe --opencover -i opencoverCoverage.xml `
--repoToken $env:COVERALLS_REPO_TOKEN --commitId $env:APPVEYOR_REPO_COMMIT `
--commitBranch $env:APPVEYOR_REPO_BRANCH --commitAuthor pitermarx `
--commitEmail pedrohmarques@gmail.com --commitMessage $env:APPVEYOR_REPO_COMMIT_MESSAGE `
--jobId $env:APPVEYOR_JOB_ID

Write-Host "Generating HTML Report"
& .\packages\ReportGenerator.2.1.4.0\ReportGenerator.exe -reports:opencoverCoverage.xml `
-targetdir:Reports\Latest -sourcedirs:Evaluant.Calculator -historydir:Reports\History
