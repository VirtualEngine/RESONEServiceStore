function Export-ROSSBuildingBlock {
<#
    .SYNOPSIS
        Imports a RES ONE Service Store building block.
#>
    [CmdletBinding()]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies a path to one or more locations. Wildcards are permitted.
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        # Specifies services should be included in the exported building block file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Services,

        # Specifies organizational contexts should be included in the exported building block file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Organisations')]
        [System.Management.Automation.SwitchParameter] $Organizations,

        # Specifies data sources should be included in the exported building block file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $DataSources,

        # Specifies data sources should be included in the exported building block file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $DataConnections,

        # Specifies data sources should be included in the exported building block file.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Branding,

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

        $requestBody = @{
            suggestedName = Split-Path -Path $Path -Leaf;
            includeImages = -not $ExcludeImages.ToBool();
        }

        if ($Services) {
            $requestBody['rootServiceId'] = [System.Guid]::Empty.ToString();
        }
        if ($Organizations) {
            $requestBody['rootOrganizationId'] = [System.Guid]::Empty.ToString();
        }
        if ($DataSources) {
            $requestBody['rootDataSourceId'] = [System.Guid]::Empty.ToString();
        }
        if ($DataConnections) {
            $requestBody['rootDataConnectionId'] = [System.Guid]::Empty.ToString();
        }
        if ($Branding) {
            $requestBody['rootBrandingId'] = [System.Guid]::Empty.ToString();
        }

        if ($requestBody.Keys.Count -le 2) {
            ## No export options provided, so add 'em all!
            $requestBody['rootServiceId'] = [System.Guid]::Empty.ToString();
            $requestBody['rootOrganizationId'] = [System.Guid]::Empty.ToString();
            $requestBody['rootDataSourceId'] = [System.Guid]::Empty.ToString();
            $requestBody['rootDataConnectionId'] = [System.Guid]::Empty.ToString();
            $requestBody['rootBrandingId'] = [System.Guid]::Empty.ToString();
        }

        $invokeROSSRestMethodParams = @{
            Session = $Session;
            Uri = Get-ROSSResourceUri -Session $Session -BuildingBlock -Export;
            Method = 'POST';
            Body = $requestBody;
            ExpandProperty = 'Bytes';
        }
        $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

        ## Convert the Base64 response into a Byte[]
        $buildingBlockBytes = [System.Convert]::FromBase64String($response);

        # Modify [CmdletBinding()] to [CmdletBinding(SupportsShouldProcess=$true)]
        $paths = @()
        foreach ($filePath in $Path) {
            # Resolve any relative paths
            $paths += $psCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath($filePath)
        }

        foreach ($filePath in $paths) {

            if ($NoClobber -and (Test-Path -Path $filePath -PathType Leaf)) {

                $exceptionMessage = $localizedData.FileAlreadyExistsError -f $filePath;
                $exception = New-Object System.IO.IOException $exceptionMessage;
                $category = [System.Management.Automation.ErrorCategory]::OpenError;
                $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'FileExists', $category, $filePath;
                $psCmdlet.WriteError($errorRecord);
                continue;

            }
            else {

                [System.IO.File]::WriteAllBytes($filePath, $buildingBlockBytes);

                if ($PassThru) {
                    $buildingBlockItem = Get-Item -Path $filePath;
                    Write-Output -InputObject $buildingBlockItem;
                }
            }

        } #end foreach file path

    } #end process
} #end function Export-ROSSBuildingBlock
