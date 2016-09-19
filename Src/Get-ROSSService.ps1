function Get-ROSSService {
<#
    .SYNOPSIS
        Returns a RES ONE Service Service reference.
#>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies the name of the service(s) to return.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Name')]
        [System.String[]] $Name,

        # Specifies returning all services.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'All')]
        [System.Management.Automation.SwitchParameter] $All,

        # Specifies the RES ONE Service Store Service Id(s) to return
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
        [System.String[]] $Id
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        $typeName = 'VirtualEngine.ROSS.Service';

        try {

            if ($PSCmdlet.ParameterSetName -ne 'Id') {

                ## The RES ONE Service Store API returns a subset of properties when searching
                ## for services. Therefore, perform the search and retrieve the service Ids
                $Id = @();

                if ($PSCmdlet.ParameterSetName -eq 'All') {

                    $uri = Get-ROSSResourceUri -Session $Session -Service -Search;
                    $services = Invoke-ROSSRestMethod -Uri $uri -Method Get -ExpandProperty 'Result';
                    $Id += $services.Id;
                }
                elseif ($PSCmdlet.ParameterSetName -eq 'Name') {

                    foreach ($serviceName in $name) {

                        $uri = Get-ROSSResourceUri -Session $Session -Service -Search -Filter $serviceName;
                        $services = Invoke-ROSSRestMethod -Uri $uri -Method Get -ExpandProperty 'Result';
                        $Id += $services.Id;
                    }
                }
            }

            foreach ($serviceId in $Id) {

                $invokeROSSRestMethodParams = @{
                    Session = $Session;
                    Uri = '{0}/{1}' -f (Get-ROSSResourceUri -Session $Session -Service), $serviceId;
                    Method = 'Get';
                    TypeName = $typeName;
                }
                Write-Output -InputObject (Invoke-ROSSRestMethod @invokeROSSRestMethodParams);
            }
        }
        catch {

            throw $_;
        }

    } #end process
} #end function Get-ROSSService
