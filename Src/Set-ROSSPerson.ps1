function Set-ROSSPerson {
<#
    .SYNOPSIS
        Updates a RES ONE Service Store person by reference.
    .EXAMPLE
        $person = Get-ROSSPerson -PersonName 'HJohn Smith'
        $person.Name = 'Joe Bloggs'
        $person | Set-ROSSPerson

        Renames an existing RES ONE Service Store person from 'John Smith' to 'Joe Bloggs'
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


        foreach ($person in $InputObject) {

            try {

                if ($Force -or ($PSCmdlet.ShouldProcess($person.Name, $localizedData.ShouldProcessSet))) {

                    $uri = '{0}/{1}' -f (Get-ROSSResourceUri -Session $Session -Person), $person.Id;

                    $invokeROSSRestMethodParams = @{
                        Session = $Session;
                        Uri = $Uri;
                        Method = 'Put';
                        InputObject = $person;
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

        } #end foreach person

    } #end process
} #end function
