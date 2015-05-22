#if($env:APPVEYOR_SCHEDULED_BUILD -eq "True")
#{
#
    #& cov-build --dir cov-int msbuild /t:Rebuild "/l:C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll"
    #& nuget install PublishCoverity
    #& .\PublishCoverity.0.9.0\PublishCoverity.exe compress -o NCalc2.zip
    #& .\PublishCoverity.0.9.0\PublishCoverity.exe publish -t $env:COVERITY_TOKEN -e $env:EMAIL `
    #-z NCalc2.zip -d "AppVeyor scheduled build ($env:APPVEYOR_BUILD_VERSION)." --codeVersion $env:APPVEYOR_BUILD_VERSION
#}
#else
#{
    & msbuild "/t:Clean;Build" "/p:Configuration=Release" "/l:C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll" NCalc2.sln
#}
