function Get-ROSSTransaction {
<#
    .SYNOPSIS
        Returns a RES ONE Service transaction reference.
    .EXAMPLE
        Get-ROSSTransaction

        Returns the first 50 transactions.
    .EXAMPLE
        Get-ROSSTransaction -ServiceId 'a13003e7-3c51-4c22-9c9e-0a8210813ed1'

        Returns the first 50 transactions for a service.
    .EXAMPLE
        Get-ROSSTransaction -ServiceId 'a13003e7-3c51-4c22-9c9e-0a8210813ed1' -Count

        Returns the number of transactions associated with a service.
    .EXAMPLE
        Get-ROSSTransaction -ServiceId 'a13003e7-3c51-4c22-9c9e-0a8210813ed1' -State Failed

        Returns the first 50 failed service delivery transactions for a service.
    .EXAMPLE
        Get-ROSSTransaction -PersonId 'b6af5c3a-601c-47a3-a551-075df7f96e33'

        Returns the first 50 transactions for a person.
    .EXAMPLE
        Get-ROSSTransaction -PersonId 'b6af5c3a-601c-47a3-a551-075df7f96e33' -Direction Deliver

        Returns the first 50 service delivery transactions for a person.
    .EXAMPLE
        Get-ROSSTransaction -PersonId 'b6af5c3a-601c-47a3-a551-075df7f96e33' -Count

        Returns the number of transactions associated with a person.
    .EXAMPLE
        Get-ROSSTransaction -Id 'fd86f088-5105-4aab-98ed-18e56756aef7'

        Returns the a specific RES ONE Service transaction by its Id.
    .EXAMPLE
        Get-ROSSOrganization -Path 'Departments\Sales' | Get-ROSSPerson | Get-ROSSTransaction

        Returns all transactions for people classified in the 'Departments\Sales' organizational context
#>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject], ParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject], ParameterSetName = 'Transaction')]
    [OutputType([System.Int32], ParameterSetName = 'Count')]
    param (
        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies returning transactions related to a specific RES ONE Service Store service Id.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [System.String] $ServiceId,

        # Specifies returning transactions related to a specific RES ONE Service Store person Id.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [System.String] $PersonId,

        # Specifies the RES ONE Service Store transaction Id to return.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Transaction')]
        [System.String] $Id,

        # Search transactions starting on or before the specified date/time.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [System.DateTime] $StartDate,

        # Search transactions ending on or before the specified date/time.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [System.DateTime] $EndDate,

        # Transaction type. If not specified, both delivery and return transactions are returned.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [ValidateSet('Deliver','Return')]
        [System.String] $Direction,

        # Transaction state. If not specified, both delivery and return transactions are returned.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [ValidateSet('Completed','Pending','Failed','Aborted','OnHold')]
        [System.String] $State,

        # Search page number to return. By default, search results are paginated and only the first page results are returned.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [ValidateRange(1,65535)]
        [System.Int32] $Page = 1,

        # Specifies the number of results per page. By default, search results are paginated and only the first page results are returned.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [ValidateRange(1,65535)]
        [System.Int32] $PageSize = 50,

        # Specifies returning only the number of available transactions matching the search criteria.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Count')]
        [System.Management.Automation.SwitchParameter] $Count
    )
    begin {

        Assert-ROSSSession -Session $Session;

        if (($PSBoundParameters.ContainsKey('StartDate')) -and
            ($PSBoundParameters.ContainsKey('EndDate'))) {

            if ($EndDate -lt $StartDate) {
                throw ($localizedData.StartDateAfterEndDateError);
            }
        }
    }
    process {

        Write-Verbose $PSCmdlet.ParameterSetName

        $typeName = 'VirtualEngine.ROSS.Transaction';
        $uri = Get-ROSSResourceUri -Session $Session -Transaction -Search;

        $requestBody = @{
            filters = @{};
            orderBy = @('StartDate');
        }

        if ($PSCmdlet.ParameterSetName -eq 'Default') {

            $requestBody['pageNumber'] = $Page;
            $requestBody['pageSize'] = $PageSize;
        }

        if ($PSBoundParameters.ContainsKey('PersonId')) {

            $requestBody.Filters['PersonId'] = $PersonId;
        }
        if ($PSBoundParameters.ContainsKey('PersonName')) {

            $requestBody.Filters['PersonName'] = $PersonName;
        }
        if ($PSBoundParameters.ContainsKey('ServiceId')) {

            $requestBody.Filters['ServiceId'] = $ServiceId;
        }
        if ($PSBoundParameters.ContainsKey('Direction')) {

            $requestBody.Filters['Direction'] = if ($Direction -eq 'Deliver') { 'Provision' } else { 'Deprovision' };
        }
        if ($PSBoundParameters.ContainsKey('State')) {

            $requestBody.Filters['State'] = $State;
        }
        if ($PSBoundParameters.ContainsKey('StartDate')) {

            $requestBody.Filters['StartDate'] = $StartDate.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ');
        }
        if ($PSBoundParameters.ContainsKey('EndDate')) {

            $requestBody.Filters['EndDate'] = $EndDate.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ');
        }

        $invokeROSSRestMethodParams = @{
            Session = $Session;
            Uri = $uri;
            Method = 'Post';
            Body = $requestBody;
        }

        if ($PSCmdlet.ParameterSetName -eq 'Count') {

            Write-Output -InputObject (Invoke-ROSSRestMethod @invokeROSSRestMethodParams).TotalCount;
        }
        else {

            try {

                Invoke-ROSSRestMethod @invokeROSSRestMethodParams -ExpandProperty 'Result' |
                    ForEach-Object {

                        $PSItem.PSObject.TypeNames.Insert(0, $TypeName);

                        $startDateTime = $PSItem.UtcStartDate -as [System.DateTime];
                        $endDateTime = $PSItem.UtcEndDate -as [System.DateTime];
                        $deliveryAction = if ($PSItem.Direction -eq 'Provision') { 'Deliver' } else { 'Return ' }
                        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name Action -Value $deliveryAction;
                        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name StartDate -Value $startDateTime;
                        Add-Member -InputObject $PSItem -MemberType NoteProperty -Name EndDate -Value $endDateTime;

                        Write-Output -InputObject $PSItem;
                    }
            }
            catch {

                throw;
            }
        }

    } #end process
} #end function
