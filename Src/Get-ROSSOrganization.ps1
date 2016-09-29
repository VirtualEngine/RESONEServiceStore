function Get-ROSSOrganization {
<#
    .SYNOPSIS
        Returns a RES ONE Service organizational context reference.
#>
    [CmdletBinding(DefaultParameterSetName = 'OrganizationName')]
    [Alias('Get-ROSSOrganisation')]
    [OutputType('VirtualEngine.ROSS.Organization')]
    param (
        # RES ONE Service Store session connection.
        [Parameter()]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies RES ONE Service Store organization context by name. Supports wildcard characters.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'OrganizationName')]
        [System.String[]] $OrganizationName,

        # Specifies RES ONE Service Store organization context by path. Supports wildcard characters.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [System.String[]] $Path,

        # Specifies RES ONE Service Store organization context by Id.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'OrganizationId')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'OrganizationName')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [System.String[]] $Id,

        # Perform a regular expression match on name or path parameter.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'OrganzationName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path')]
        [System.Management.Automation.SwitchParameter] $Match
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        $typeName = 'VirtualEngine.ROSS.Organization';
        $organizations = @();

        if ($PSBoundParameters.ContainsKey('Id')) {

            $rossOrganizationEndpointUri = Get-ROSSResourceUri -Session $Session -Organization;
            $invokeROSSRestMethodParams = @{
                Session = $Session;
                Method = 'Get';
                TypeName = $typeName;
            }

            foreach ($organizationId in $Id) {

                $invokeROSSRestMethodParams['Uri'] = '{0}/{1}' -f $rossOrganizationEndpointUri, $organizationId;
                $organizations += Invoke-ROSSRestMethod @invokeROSSRestMethodParams;
            }

        }
        else {

            ## Retrieve the root organizational contexts
            $invokeROSSRestMethodParams = @{
                Session = $Session;
                Uri = Get-ROSSResourceUri -Session $Session -Organization -List;
                Method = 'Get';
                TypeName = $typeName;
                ExpandProperty = 'Children';
            }
            $organizations = Invoke-ROSSRestMethod @invokeROSSRestMethodParams;

        }

        foreach ($organization in $organizations) {

            $getChildROSSOrganizationParams = @{
                Session = $Session;
                Id = $organization.Children.Id;
                Match = $Match.ToBool();
            }

            if ($PSBoundParameters.ContainsKey('OrganizationName')) {

                foreach ($name in $OrganizationName) {

                    $isLikeExpression = $false;
                    if ($name.Contains('*')) {
                        $isLikeExpression = $true;
                    }

                    if (($Match -and ($organization.Name -match $name)) -or
                        ($isLikeExpression -and (-not $Match) -and ($organization.Name -like $name)) -or
                        ((-not $Match) -and (-not $isLikeExpression) -and ($organization.Name -eq $name))) {

                        Write-Output -InputObject $organization;
                    }
                }

                $getChildROSSOrganizationParams['OrganizationName'] = $name;

            }
            elseif ($PSBoundParameters.ContainsKey('Path')) {

                foreach ($organizationPath in $Path) {

                    $isLikeExpression = $false;
                    if ($organizationPath.Contains('*')) {
                        $isLikeExpression = $true;
                    }
                    if (($Match -and ($organization.Path -match $organizationPath)) -or
                        ($isLikeExpression -and (-not $Match) -and  ($organization.Path -like $organizationPath)) -or
                        ((-not $Match) -and (-not $isLikeExpression) -and ($organization.Path -eq $organizationPath))) {

                        Write-Output -InputObject $organization;
                    }
                }

                $getChildROSSOrganizationParams['Path'] = $Path;

            }
            else {

                Write-Output -InputObject $organization;
            }

            ## Recursively search child organizational contexts
            if ($organization.Children) {

                Get-ROSSOrganization @getChildROSSOrganizationParams;
            }

        } #end foreach organization context

    } #end process
} #end function Get-ROSSOrganization
