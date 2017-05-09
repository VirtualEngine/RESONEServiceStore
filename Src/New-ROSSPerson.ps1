function New-ROSSPerson {
<#
    .SYNOPSIS
        Creates a new RES ONE Service Store person.
    .EXAMPLE
        $person = New-ROSSPerson -PersonName 'Joe Bloggs' -Active

        Creates a new active/licensed RES ONE Service Store person called 'Joe Bloggs'
    .EXAMPLE
        'Joe Bloggs' | New-ROSSPerson

        Creates a new inactive/unlicensed RES ONE Service Store person called 'John Smith'

#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Creates people records with the specified RES ONE Service Store name(s).
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [System.String[]] $PersonName,

        # Specifies that the people should be activated/licensed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Active,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        foreach ($name in $PersonName) {

            try {

                if ($Force -or ($PSCmdlet.ShouldProcess($name, $localizedData.ShouldProcessNew))) {

                    $invokeROSSRestMethodParams = @{
                        Session = $Session;
                        Uri = Get-ROSSResourceUri -Session $Session -Person -New;
                        Method = 'Get';
                    }
                    $person = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    $person.Id = [System.Guid]::NewGuid().ToString();
                    $person.Active = $Active.ToBool();
                    $person.Name = $name;

                    $invokeROSSRestMethodParams = @{
                        Session = $Session;
                        Uri = Get-ROSSResourceUri -Session $Session -Person;
                        Method = 'Post';
                        InputObject = $person;
                    }
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;
                
                    Write-Output -InputObject $person;
                }
            }
            catch {

                throw;
            }

        } #end foreach person

    } #end process
} #end function
