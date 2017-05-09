function Set-ROSSService {
<#
    .SYNOPSIS
        Updates a RES ONE Service Store service by reference.
    .EXAMPLE
        $service = Get-ROSSService -ServiceName 'My Hidden Service'
        $service.ShowInStore = $false
        $service | Set-ROSSService

        Hides a service named 'My Hidden Service' from the RES ONE Service Store web portal.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies the RES ONE Service Store object(s) to update.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [PSCustomObject[]] $InputObject,

        # Returns an object representing the server with which you are working. By default, this cmdlet does not generate any output.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        foreach ($service in $InputObject) {

            try {

                if ($Force -or ($PSCmdlet.ShouldProcess($service.Name, $localizedData.ShouldProcessSet))) {

                    $uri = '{0}/{1}' -f (Get-ROSSResourceUri -Session $Session -Service), $service.Id;

                    $invokeROSSRestMethodParams = @{
                        Session = $Session;
                        Uri = $Uri;
                        Method = 'Put';
                        InputObject = $service;
                    }
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if ($PassThru) {
                        Write-Output -InputObject $response;
                    }

                }
            }
            catch {

                throw;
            }

        } #end foreach service

    } #end process
} #end function
