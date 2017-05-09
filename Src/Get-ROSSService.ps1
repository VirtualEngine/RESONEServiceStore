function Get-ROSSService {
<#
    .SYNOPSIS
        Returns a RES ONE Service Service reference.
    .EXAMPLE
        Get-ROSSService -All

        Returns the first 50 RES ONE Service Store services.
    .EXAMPLE
        Get-ROSSService -All -PageSize 100

        Returns the first 100 RES ONE Service Store services.
    .EXAMPLE
        Get-ROSSService -All -PageSize 25 -Page 2

        Returns the second set of 25 RES ONE Service Store services.
    .EXAMPLE
        Get-ROSSService -ServiceName 'Assign'

        Returns all services with 'Assign Departmental Services' in their name.
    .EXAMPLE
        Get-ROSSService -ServiceId 'a13003e7-3c51-4c22-9c9e-0a8210813ed1'

        Returns a single service with the specified identifier.
    .NOTES
        The RES ONE Service Store API performs a wildcard search on the service name when specified.
#>
    [CmdletBinding(DefaultParameterSetName = 'ServiceName')]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies the name of the service(s) to return.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceName')]
        [System.String[]] $ServiceName,

        # Specifies the RES ONE Service Store Service Id(s) to return
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceId')]
        [System.String[]] $ServiceId,

        # Specifies returning all services.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServiceAll')]
        [System.Management.Automation.SwitchParameter] $All,

        # Search page number to return. By default, search results are paginated and only the first page results are returned.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Int32] $Page = 1,

        # Specifies the number of results per page. By default, search results are paginated and only the first page results are returned.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1,65535)]
        [System.Int32] $PageSize = 50
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        $typeName = 'VirtualEngine.ROSS.Service';

        try {

            if ($PSCmdlet.ParameterSetName -ne 'ServiceId') {

                ## The RES ONE Service Store API returns a subset of properties when searching
                ## for services. Therefore, perform the search and retrieve the service Ids
                $ServiceId = @();

                if ($PSCmdlet.ParameterSetName -eq 'ServiceAll') {

                    $invokeROSSRestMethodParams = @{
                        Uri = Get-ROSSResourceUri -Session $Session -Service -Search;
                        Method = 'Post';
                        Body = @{
                            pageNumber = $Page;
                            pageSize = $PageSize;
                        }
                        ExpandProperty = 'Result';
                    }

                    $services = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;
                    $ServiceId += $services.Id;

                }
                elseif ($PSCmdlet.ParameterSetName -eq 'ServiceName') {

                    foreach ($name in $ServiceName) {

                        $invokeROSSRestMethodParams = @{
                            #Uri = Get-ROSSResourceUri -Session $Session -Service -Search -Filter $serviceName;
                            Uri = Get-ROSSResourceUri -Session $Session -Service -Search;
                            Method = 'Post';
                            Body = @{
                                pageNumber = $Page;
                                pageSize = $PageSize;
                                freeTextFilter = $name;
                            }
                            ExpandProperty = 'Result';
                        }

                        $services = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;
                        $ServiceId += $services.Id;

                    }
                }
            }

            foreach ($id in $ServiceId) {

                $invokeROSSRestMethodParams = @{
                    Session = $Session;
                    Uri = '{0}/{1}' -f (Get-ROSSResourceUri -Session $Session -Service), $id;
                    Method = 'Get';
                    TypeName = $typeName;
                }
                Write-Output -InputObject (Invoke-ROSSRestMethod @invokeROSSRestMethodParams);
            }
        }
        catch {

            throw;
        }

    } #end process
} #end function

