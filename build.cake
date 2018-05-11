#tool "nuget:?package=GitVersion.CommandLine&version=3.6.5"
#tool "nuget:?package=coveralls.net&version=0.7.0"
#tool "nuget:?package=coveralls.io&version=1.4.2"
#tool "nuget:?package=OpenCover&version=4.6.519"
#addin "nuget:?package=Cake.Coveralls&version=0.8.0"

var nugetApiToken = EnvironmentVariable("nuget_api_token");
var configuration = Argument("configuration", "Release");
var target = Argument("target", "Default");

Task("CleanRestore")
    .Does(() => 
{
    CleanDirectories("./**/bin");
    CleanDirectories("./**/obj");
    CleanDirectories("./**/TestResults");
    NuGetRestore("src/NCalc2.sln");
});

Task("Build")
    .IsDependentOn("CleanRestore")
    .Does(() => 
{
    var version = GitVersion(new GitVersionSettings{}).NuGetVersionV2;
    if(AppVeyor.IsRunningOnAppVeyor)
    {
        AppVeyor.UpdateBuildVersion(version);
    }
    MSBuild("src/NCalc2.sln", configurator =>
        configurator
            .WithProperty("PackageVersion", version)
            .UseToolVersion(MSBuildToolVersion.VS2017)
            .SetConfiguration(configuration)
            .SetVerbosity(Verbosity.Minimal));
});

Task("Test")
    .IsDependentOn("Build")
    .Does((ctx) => 
{
    var project = GetFiles("./src/**/*.Tests.csproj").First();
    OpenCover(
        tool => tool.DotNetCoreTest(project.ToString(), new DotNetCoreTestSettings
        {
            Framework = "net46",
            NoBuild = true,
            NoRestore = true,
            Configuration = configuration,
            ArgumentCustomization = a => a.Append("--logger:nunit;LogFilePath=../../TestResult.xml")
        }),
        "coverage.xml",
        new OpenCoverSettings().WithFilter("+[NCalc2]* -[*.Tests]*"));
    
    if (AppVeyor.IsRunningOnAppVeyor)
    {
        AppVeyor.UploadTestResults("TestResult.xml", AppVeyorTestResultsType.NUnit3); 
        CoverallsIo("coverage.xml", new CoverallsIoSettings
        {
            RepoToken = EnvironmentVariable("COVERALLS_TOKEN")
        });
    }
});

Task("Publish")
    .WithCriteria(AppVeyor.IsRunningOnAppVeyor)
    .IsDependentOn("Test")
    .Does(() =>
{
    var file = GetFiles("./**/bin/Release/*.nupkg").First();
    AppVeyor.UploadArtifact(file);
    
    var tagged = AppVeyor.Environment.Repository.Tag.IsTag && 
        !string.IsNullOrWhiteSpace(AppVeyor.Environment.Repository.Tag.Name);

    if (tagged)
    { 
        // Push the package.
        NuGetPush(file, new NuGetPushSettings 
        {
            Source = "https://www.nuget.org/api/v2/package",
            ApiKey = nugetApiToken
        });
}
});

Task("Default")
    .IsDependentOn("Publish");

RunTarget(target);