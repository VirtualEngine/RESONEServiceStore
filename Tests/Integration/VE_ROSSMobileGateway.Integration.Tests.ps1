$script:DSCModuleName = Split-Path -Path "$PSScriptRoot\..\.." -Resolve -Leaf;
$script:DSCResourceName = (Get-Item -Path $MyInvocation.MyCommand.Path).BaseName -replace '\.Integration\.Tests','';

#region HEADER
# Integration Test Template Version: 1.1.1
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Integration 3>$null
#endregion

# Using try/finally to always cleanup even if something awful happens.
try
{
    # Import the configuration
    $configFilename = '{0}.Config.ps1' -f $script:DSCResourceName;
    $configPath = Join-Path -Path $PSScriptRoot -ChildPath $configFilename;
    . $configPath -Verbose -ErrorAction Stop 3>$null

    Describe "$($script:DSCResourceName)_Integration" {

        #region DEFAULT TEST
        It 'Should compile without throwing' {
            {
                & "$($script:DSCResourceName)_Config" `
                    -OutputPath $TestDrive `
                    -ConfigurationData $ConfigData `
                    -Path $TestDrive `
                    -HostHeader 'res.integration.test' `
                    -CertificateThumbprint '11A481C68E7F061BC85629A3E819CDF35B88DA20'
            } | Should not throw
        }
        #endregion

    }
}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $TestEnvironment 3>$null
    #endregion
}
