function Enable-ROSSPerson {
<#
    .SYNOPSIS
        Sets a RES ONE Service person to active.
    .EXAMPLE
        Enable-ROSSPerson -PersonName 'Sales'

        Enables all people with a name matching 'Sales'.
    .EXAMPLE
        Get-ROSSOrganization -Path 'Departments\Sales' | Enable-ROSSPerson

        Enables all people in the 'Departments\Sales' organizational context.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'PersonName')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies returning people records with the specified RES ONE Service Store name(s).
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'PersonName')]
        [System.String[]] $PersonName,

        # Specifies returning people records with the specified RES ONE Service Store idenitifier(s).
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'PersonId')]
        [System.String[]] $PersonId,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [PSCustomObject] $InputObject,

        # Returns the updated RES ONE Service Store service object to the pipeline.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PersonId')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PersonName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'InputObject')]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Assert-ROSSSession -Session $Session;

    }
    process {

        if ($PSCmdlet.ParameterSetName -eq 'PersonId') {

            $InputObject = Get-ROSSPerson -Session $Session -PersonId $PersonId;
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'PersonName') {

            $InputObject = Get-ROSSPerson -Session $Session -PersonName $PersonName;
        }

        try {

            foreach ($person in $InputObject) {

                if ($Force -or ($PSCmdlet.ShouldProcess($person.Name, $localizedData.ShouldProcessDisable))) {

                    $service.Active = $true;
                    $setROSSPersonParams = @{
                        Session = $Session;
                        InputObject = $person;
                        Force = $Force;
                        Confirm = $false;
                    }
                    Set-ROSSPerson @setROSSPersonParams;

                    if ($PassThru) {
                        ## Set-ROSSPerson only returns the response length, so we'll have to fetch it
                        Write-Output -InputObject (Get-ROSSPerson -Session $Session -PersonId $person.Id);
                    }
                }
            }
        }
        catch {

            throw;
        }

    } #end process
} #end function
