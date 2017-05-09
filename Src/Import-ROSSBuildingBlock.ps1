function Import-ROSSBuildingBlock {
<#
    .SYNOPSIS
        Imports a RES ONE Service Store building block.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'Path')]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [System.String[]] $Path,

        # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
        # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
        # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
        # characters as escape sequences.
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $LiteralPath,

        # Specifies imported service objects should be enabled. By default Service objects are not enabled.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $EnableTransactions,

        # Specifies imported service objects' images should not be included. By default service images are included.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ExcludeImages,

        # Specifies imported service objects should not overwrite existing objects. By default, existing objects are overwritten/merged.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoClobber,

        # Returns the RES ONE Service Store import building block API response to the pipeline.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $PassThru
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        $paths = @()
        if ($psCmdlet.ParameterSetName -eq 'Path') {

            foreach ($filePath in $Path) {

                if (-not (Test-Path -Path $filePath)) {

                    $exceptionMessage = $localizedData.CannotFindFilePathError -f $filePath;
                    $exception = New-Object System.Management.Automation.ItemNotFoundException $exceptionMessage;
                    $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'PathNotFound', $category, $filePath;
                    $psCmdlet.WriteError($errorRecord);
                    continue;
                }

                # Resolve any wildcards that might be in the path
                $provider = $null;
                $paths += $psCmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath($filePath, [ref] $provider);
            }
        }
        else {

            foreach ($filePath in $LiteralPath) {

                if (-not (Test-Path -LiteralPath $filePath)) {

                    $exceptionMessage = $localizedData.CannotFindFilePathError -f $filePath;
                    $exception = New-Object System.Management.Automation.ItemNotFoundException $exceptionMessage;
                    $category = [System.Management.Automation.ErrorCategory]::ObjectNotFound;
                    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'PathNotFound', $category, $filePath;
                    $psCmdlet.WriteError($errorRecord);
                    continue;
                }

                # Resolve any relative paths
                $paths += $psCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($filePath);
            }
        }

        foreach ($filePath in $paths) {

            if ($Force -or ($psCmdlet.ShouldProcess($filePath, $localizedData.ShouldProcessImport))) {

                try {

                    ## Convert Building Block file to a Base64String - this is need for the API
                    $buildingBlockBytes = [System.IO.File]::ReadAllBytes($filePath);
                    $buildingBlockBase64 = [System.Convert]::ToBase64String($buildingBlockBytes);

                    $body = @{
                        bytes = $buildingBlockBase64;
                        includeImages = $true;
                    }

                    ## Upload Building Block first and grab response
                    $uploadUri = Get-ROSSResourceUri -Session $Session -BuildingBlock -Upload 'RESONEServiceStore.xml';
                    $uploadResponse = Invoke-ROSSRestMethod -Uri $uploadUri -Method Post -Body $body;

                    if ($PSBoundParameters.ContainsKey('EnableTransactions')) {
                        $uploadResponse.EnableTransactions = $EnableTransactions.ToBool();
                    }

                    if ($PSBoundParameters.ContainsKey('NoClobber')) {
                        $uploadResponse.OverwriteItems = -not $NoClobber.ToBool();
                    }

                    if ($PSBoundParameters.ContainsKey('ExcludeImages')) {
                        $uploadResponse.IncludeImages = -not $ExcludeImages.ToBool();
                    }

                    ## Use response from upload to import the Building Block
                    $importUri =  Get-ROSSResourceUri -Session $Session -BuildingBlock -Import;
                    $importResponse = Invoke-ROSSRestMethod -Uri $importUri -Method Post -InputObject $uploadResponse;

                    if ($PassThru) {
                        Write-Output -InputObject $importResponse;
                    }

                }
                catch {

                    throw;
                }

            } #end if should process
        } #end foreach file path
    } #end process
} #end function
