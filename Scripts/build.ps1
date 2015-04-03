& cov-build --dir cov-int msbuild /t:Rebuild
& nuget install PublishCoverity
& .\PublishCoverity.0.9.0\PublishCoverity.exe compress -o NCalc2.zip
& .\PublishCoverity.0.9.0\PublishCoverity.exe publish -t $env:COVERITY_TOKEN -e $env:EMAIL `
-z NCalc2.zip -d "AppVeyor scheduled build ($env:APPVEYOR_BUILD_VERSION)." --codeVersion $env:APPVEYOR_BUILD_VERSION
