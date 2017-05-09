function Get-ROSSPerson {
<#
    .SYNOPSIS
        Returns a RES ONE Service person reference.
    .EXAMPLE
        Get-ROSSPerson -PersonName 'Sales'

        Returns all people with a name matching 'Sales'. The RES ONE Service Store API performs a pattern match.
    .EXAMPLE
        Get-ROSSOrganization -Path 'Departments\Sales' | Get-ROSSPerson

        Returns all people in the 'Departments\Sales' organizational context.
    .EXAMPLE
        Get-ROSSService -ServiceName 'Name Change' | Get-ROSSPerson -Delivered

        Returns all people that have the the 'Name Change' service delivered.
    .EXAMPLE
        Get-ROSSService -ServiceName 'Name Change' | Get-ROSSPerson -Qualified

        Returns all people qualified for the 'Name Change' service.
#>
    [CmdletBinding(DefaultParameterSetName = 'PersonName')]
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

        ## RES ONE Service Store organizational context Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'OrganizationId')]
        [System.String[]] $OrganizationId,

        ## RES ONE Service Store service Id
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'QualifiedServiceId')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveredServiceId')]
        [System.String[]] $ServiceId,

        # Specifies returning people records with the specified RES ONE Service Store idenitifier(s).
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'PersonAll')]
        [System.Management.Automation.SwitchParameter] $All,

        ## Return people who qualify for the service.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'QualifiedServiceId')]
        [System.Management.Automation.SwitchParameter] $Qualified,

        ## Return people who have the service delivered.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveredServiceId')]
        [System.Management.Automation.SwitchParameter] $Delivered,

        # Filters results, returning only Unlicensed people.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Unlicensed,

        # Filters results, returning only inactive people.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Inactive,

        # Filters results, returning only people marked for deletion.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $MarkedForDeletion,

        # Filters results, returning only people ready for deletion.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $ReadyForDeletion,

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

        if (($PSBoundParameters.ContainsKey('MarkedForDeletion')) -and
            ($PSBoundParameters.ContainsKey('ReadyForDeletion'))) {

            throw 'A person cannot both be marked for deletion and ready for deletion!';
        }

    }
    process {

        $typeName = 'VirtualEngine.ROSS.Person';

        $invokeROSSRestMethodParams = @{
            Session = $Session;
            Uri = Get-ROSSResourceUri -Session $Session -Person -Search;
            Method = 'Post';
            Body = @{
                pageSize = $PageSize;
                pageNumber = $Page;
            }
        }

        if ($PSCmdlet.ParameterSetName -ne 'PersonId') {

            $Id = @();

            if ($PSCmdlet.ParameterSetName -eq 'PersonAll') {

                $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                if ($null -ne $response.Result.Id) {
                    $Id +=  $response.Result.Id;
                }

            }
            elseif ($PSCmdlet.ParameterSetName -eq 'PersonName') {

                foreach ($name in $PersonName) {

                    $invokeROSSRestMethodParams.Body['freeTextFilter'] = $name;
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if ($null -ne $response.Result.Id) {
                        $Id +=  $response.Result.Id;
                    }
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'OrganizationId') {

                foreach ($organization in $OrganizationId) {

                    $invokeROSSRestMethodParams.Body['filters'] = @(
                        @{
                            filterType = 'organization';
                            values = @($organization);
                        }
                    )
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if ($null -ne $response.Result.Id) {
                        $Id +=  $response.Result.Id;
                    }
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'QualifiedServiceId') {

                foreach ($service in $serviceId) {

                    $invokeROSSRestMethodParams.Body['filters'] = @(
                        @{
                            filterType = 'qualifiedFor';
                            values = @($service);
                        }
                    )
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if ($null -ne $response.Result.Id) {
                        $Id +=  $response.Result.Id;
                    }

                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'DeliveredServiceId') {

                foreach ($service in $serviceId) {

                    $invokeROSSRestMethodParams.Body['filters'] = @(
                        @{
                            filterType = 'deliveredTo';
                            values = @($service);
                        }
                    )
                    $response = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if ($null -ne $response.Result.Id) {
                        $Id +=  $response.Result.Id;
                    }
                }
            }

        }
        ## Search for each Person Id
        foreach ($personId in $Id) {

            if (-not ([System.String]::IsNullOrEmpty($personId))) {

                try {

                    $invokeROSSRestMethodParams = @{
                        Session = $Session;
                        Uri = '{0}/{1}' -f (Get-ROSSResourceUri -Session $Session -Person), ($personId -as [String]);
                        Method = 'Get';
                        TypeName = $typeName;
                    }

                    $isPersonFiltered = $false;
                    $person = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

                    if (($PSBoundParameters.ContainsKey('Unlicensed')) -and
                        ($person.IsLicensed -eq $Unlicensed.ToBool())) {
                            $isPersonFiltered = $true;
                    }
                    if (($PSBoundParameters.ContainsKey('Inactive')) -and
                        ($person.Active -eq $Inactive.ToBool())) {
                            $isPersonFiltered = $true;
                    }
                    if (($PSBoundParameters.ContainsKey('MarkedForDeletion')) -and
                        ($person.IsMarkedForDeletion -ne $MarkedForDeletion.ToBool())) {
                            $isPersonFiltered = $true;
                    }
                    if (($PSBoundParameters.ContainsKey('ReadyForDeletion')) -and
                        ($person.IsReadyForDeletion -ne $ReadyForDeletion.ToBool())) {
                            $isPersonFiltered = $true;
                    }

                    if (-not $isPersonFiltered) {
                        Write-Output -InputObject $person;
                    }

                }
                catch {

                    throw;
                }

            }
        } #end foreach person id

    } #end process
} #end function
