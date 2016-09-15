data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        CannotFindPathError            = Cannot find path '{0}' because it does not exist.

        ResourceCorrectPropertyState   = Resource property '{0}' is in the desired state.
        ResourceIncorrectPropertyState = Resource property '{0}' is NOT in the desired state. Expected '{1}', actual '{2}'.
        ResourceInDesiredState         = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState      = Resource '{0}' is NOT in the desired state.
        ImportingBuildingBlock         = Importing building block '{0}'.
'@
}

#region Private

function SetBuildingBlockFileHash {
<#
    .SYNOPSIS
        Updates the registry with friendly names and hash values.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.String] $RegistryName,

        [Parameter(Mandatory)]
        [System.String] $FileHash
    )
    process {

        if (-not (Test-Path -Path $script:DefaultRegistryPath -PathType Container)) {
            $registryParentPath = Split-Path -Path $script:DefaultRegistryPath -Parent;
            $registryKeyName = Split-Path -Path $script:DefaultRegistryPath -Leaf;
            [ref] $null = New-Item -Path $registryParentPath -ItemType Directory -Name $registryKeyName;
        }

        [ref] $null = Set-ItemProperty -Path $script:DefaultRegistryPath -Name $RegistryName -Value $FileHash;

    } #end process
} #end function SetBuildingBlockFileHash


function ResolveBuildingBlock {
<#
    .SYNOPSIS
        Returns a list of resolved RES ONE Automation building block files/hashes.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        ## File path containing RES ONE Service Store building blocks.
        [Parameter(Mandatory)]
        [System.String] $Path
    )
    process {

        $paths = @()
        foreach ($filePath in $Path) {

            if (-not (Test-Path -Path $filePath)) {

                $exMessage = $localizedData.CannotFindPathError -f $filePath;
                $ex = New-Object System.Management.Automation.ItemNotFoundException $exMessage;
                $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                $errRecord = New-Object System.Management.Automation.ErrorRecord $ex, 'PathNotFound', $category, $filePath;
                $psCmdlet.WriteError($errRecord);
                continue;
            }

            # Resolve any wildcards that might be in the path
            $provider = $null;
            $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($filePath, [ref] $provider);

        }

        foreach ($filePath in $paths) {
            Write-Output -InputObject ([PSCustomObject] @{
                Path = $filePath;
                FileHash = (Get-FileHash -Path $filePath -Algorithm MD5).Hash;
                RegistryName = (Split-Path -Path $filePath -Leaf).Replace(' ','').Replace('-','').Replace('.','_');
            });
        }

    } #end process
} #end function ResolveBuildingBlock

#endregion Private

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        # RES ONE Service Store building block file path
        [Parameter(Mandatory)]
        [System.String] $Path,

        # RES ONE Service Store API hostname/endpoint
        [Parameter(Mandatory)]
        [System.String] $Server,

        # RES ONE Service Store API credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        # Specifies connecting to the RES ONE Service Store API endpoint using TLS/SSL
        [Parameter()]
        [System.Boolean] $UseHttps,

        # Specifies imported service objects should be enabled
        [Parameter()]
        [System.Boolean] $EnableTransactions,

        # Specifies imported service objects should not overwrite existing objects
        [Parameter()]
        [System.Boolean] $NoClobber
    )
    process {

        $buildingBlocks = ResolveBuildingBlock -Path $Path;
        foreach ($bb in $buildingBlocks) {
            Write-Output -InputObject @{ Path = $bb.Path; }
        }

    }
} #end function Get-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        # RES ONE Service Store building block file path
        [Parameter(Mandatory)]
        [System.String] $Path,

        # RES ONE Service Store API hostname/endpoint
        [Parameter(Mandatory)]
        [System.String] $Server,

        # RES ONE Service Store API credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        # Specifies connecting to the RES ONE Service Store API endpoint using TLS/SSL
        [Parameter()]
        [System.Boolean] $UseHttps,

        # Specifies imported service objects should be enabled
        [Parameter()]
        [System.Boolean] $EnableTransactions,

        # Specifies imported service objects should not overwrite existing objects
        [Parameter()]
        [System.Boolean] $NoClobber
    )
    process {

        $inCompliance = $true;
        $buildingBlocks = ResolveBuildingBlock -Path $Path;

        foreach ($bb in $buildingBlocks) {

            $registryName = $bb.RegistryName;
            $registryHash = (Get-ItemProperty -Path $script:DefaultRegistryPath -Name $bb.RegistryName -ErrorAction SilentlyContinue).$RegistryName;
            if ($bb.FileHash -ne $registryHash) {

                Write-Verbose -Message ($localizedData.ResourceIncorrectPropertyState -f $bb.RegistryName, $bb.FileHash, $registryHash);
                $inCompliance = $false;
            }
            else {

                Write-Verbose -Message ($localizedData.ResourceCorrectPropertyState -f $bb.RegistryName);
            }

        }

        if ($inCompliance) {

            Write-Verbose -Message ($localizedData.ResourceInDesiredState -f $Path);
            return $true;
        }
        else {

            Write-Verbose -Message ($localizedData.ResourceNotInDesiredState -f $Path);
            return $false;
        }

    }
} #end function Test-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        # RES ONE Service Store building block file path
        [Parameter(Mandatory)]
        [System.String] $Path,

        # RES ONE Service Store API hostname/endpoint
        [Parameter(Mandatory)]
        [System.String] $Server,

        # RES ONE Service Store API credential
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()] $Credential,

        # Specifies connecting to the RES ONE Service Store API endpoint using TLS/SSL
        [Parameter()]
        [System.Boolean] $UseHttps,

        # Specifies imported service objects should be enabled
        [Parameter()]
        [System.Boolean] $EnableTransactions,

        # Specifies imported service objects should not overwrite existing objects
        [Parameter()]
        [System.Boolean] $NoClobber
    )
    process {

        $buildingBlocks = ResolveBuildingBlock -Path $Path;

        foreach ($bb in $buildingBlocks) {

            $registryName = $bb.RegistryName;
            $registryHash = (Get-ItemProperty -Path $script:DefaultRegistryPath -Name $bb.RegistryName -ErrorAction SilentlyContinue).$registryName;
            if ($bb.FileHash -ne $registryHash) {

                try {

                    ## Connect to the API endpoint
                    $connectROSSSessionParams = @{
                        Server = $Server;
                        Credential = $Credential;
                        UseHttps = $UseHttps;
                    }
                    $session = Connect-ROSSSession @connectROSSSessionParams -PassThru;

                    ## Import RES ONE Service Store building block
                    $importROSSBuildingBlockParams = @{
                        Session = $Session;
                        Path = $bb.Path;
                        EnableTransactions = $EnableTransactions;
                        NoClobber = $NoClobber;
                    }
                    Import-ROSSBuildingBlock @importROSSBuildingBlockParams;

                    ## Update the registry/hash value
                    SetBuildingBlockFileHash -RegistryName $bb.RegistryName -FileHash $bb.FileHash;

                }
                catch {

                    throw $_
                }
            }

        } #end foreach building block

    } #end process
} #end function Set-TargetResource


## Import the RESONEServiceStore base module \Src functions
$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleDscResourcesRoot = Split-Path -Path $moduleRoot -Parent;
$baseModuleRoot = Split-Path -Path $moduleDscResourcesRoot -Parent;
$baseModuleSrcPath = Join-Path -Path $baseModuleRoot -ChildPath 'Src';
Get-ChildItem -Path $baseModuleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }

$script:DefaultRegistryPath = 'HKLM:\SOFTWARE\Virtual Engine\RESONEServiceStoreDsc';

Export-ModuleMember -Function *-TargetResource;
