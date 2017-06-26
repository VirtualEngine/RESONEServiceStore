Describe 'Integration\RESONEServiceStore' {

    It 'Should load module without throwing' {

        $repoRoot = (Resolve-Path "$PSScriptRoot\..\..").Path;
        $moduleName = (Get-Item -Path $repoRoot).Name;

        { Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psd1") -Force } | Should Not Throw;

    }

    $dscResourcesPath = Get-ChildItem -Path (Resolve-Path "$PSScriptRoot\..\..\DSCResources").Path -Directory -Exclude '_*';
    foreach ($module in $dscResourcesPath) {

        ## Cannot load composite resources..
        $moduleManifestPath = Join-Path -Path $module.FullName -ChildPath "$($module.Name).psm1";
        if (Test-Path -Path $moduleManifestPath) {

            It "Should load resource '$($module.Name)' without throwing" {
                { Import-Module $moduleManifestPath -Force } | Should Not Throw;
            }
        
        }
    } #end foreach module

} #end describe
