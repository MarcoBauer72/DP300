1) Baixar TFS 2017 -> https://devblogs.microsoft.com/bharry/team-explorer-for-tfs-2017/


2) Habilitar Source Control no SSMS -> https://stackoverflow.com/questions/42348016/how-do-i-USE-source-control-with-sql-server-management-studio

Enabling source control integration in SSMS To enable TFS integration in SSMS, follow these steps:

1) Close SSMS if it is running.

2) Install Visual Studio 2015 on your SSMS machine. If you don’t already have Visual Studio, Community Edition will work fine. This is a large download but you can save some space by unselecting all languages during the Visual Studio install if your only purpose is to enable Source Control in SSMS.

3) Edit the ssms.pkgundef file found at C:\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\ManagementStudio\ssms.pkgundef.

At the top of this file there are a series of packages grouped together related to TFS Source Control features. These packages must be removed from the pkgundef file. This can be done by either deleting the section or commenting out each line using ‘//’. Here is an example of what the section should look like if commented out:// TFS SCC Configuration entries. The TFS entries block Team Explorer from loading.

// Microsoft.VisualStudio.TeamFoundation.Lab
//[$RootKey$\Packages\{17c5d08a-602c-4dfb-82b5-8e0f7f50c9d7}]
// GitHub Package
//[$RootKey$\Packages\{c3d3dc68-c977-411f-b3e8-03b0dccf7dfc}]
// Team Foundation Server Provider Package
//[$RootKey$\Packages\{5BF14E63-E267-4787-B20B-B814FD043B38}]
// Microsoft.VisualStudio.TeamFoundation.WorkItemTracking.WitPcwPackage
//[$RootKey$\Packages\{6238f138-0c0c-49ec-b24b-215ee59d84f0}]
// Microsoft.VisualStudio.TeamFoundation.Build.BuildPackage
//[$RootKey$\Packages\{739f34b3-9ba6-4356-9178-ac3ea81bdf47}]
// Microsoft.VisualStudio.TeamFoundation.WorkItemTracking
//[$RootKey$\Packages\{ca39e596-31ed-4b34-aa36-5f0240457a7e}]
// Microsoft.VisualStudio.TeamFoundation
//[$RootKey$\Packages\{b80b010d-188c-4b19-b483-6c20d52071ae}]
// Microsoft.TeamFoundation.Git.Provider.SccProviderPackage
//[$RootKey$\Packages\{7fe30a77-37f9-4cf2-83dd-96b207028e1b}]
// Microsoft.VisualStudio.TeamFoundation.VersionControl.SccPcwPluginPackage
//[$RootKey$\Packages\{1b4f495a-280a-3ba4-8db0-9c9b735e98ce}]
// Microsoft.VisualStudio.TeamFoundation.VersionControl.HatPackage
//[$RootKey$\Packages\{4CA58AB2-18FA-4F8D-95D4-32DDF27D184C}]
// Visual SourceSafe Provider Package
//[$RootKey$\Packages\{AA8EB8CD-7A51-11D0-92C3-00A0C9138C45}]
// Visual SourceSafe Provider Stub Package
//  [$RootKey$\Packages\{53544C4D-B03D-4209-A7D0-D9DD13A4019B}]
// Microsoft.VisualStudio.TeamFoundation.Initialization.InitializationPackage
 // [$RootKey$\Packages\{75DF55D4-EC28-47FC-88AC-BE56203C9012}]
// Team Foundation Server Provider Stub Package
//  [$RootKey$\Packages\{D79B7E0A-F994-4D4D-8FAE-CAE147279E21}]
// Microsoft.VisualStudio.Services.SccDisplayInformationPackage
//  [$RootKey$\Packages\{D7BB9305-5804-4F92-9CFE-119F4CB0563B}]
// Microsoft.VisualStudio.TeamFoundation.Lab.LabPcwPluginPackage
 //  [$RootKey$\Packages\{e0910062-da1f-411c-b152-a3fc6392ee1f}]
//   [$RootKey$\ToolsOptionsPages\Source Control]
 //  [$RootKey$\AutoLoadPackages\{11b8e6d7-c08b-4385-b321-321078cdd1f8}]
// TFS SCC Configuration entries.

