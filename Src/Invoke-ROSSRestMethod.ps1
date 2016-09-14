function Invoke-ROSSRestMethod {
<#
    .SYNOPSIS
        Calls a RES ONE Service Store API method.
    .NOTES
        This is an internal method and should not be called directly.
#>
    [CmdletBinding(DefaultParameterSetName = 'DefaultHashtable')]
    param (
        # Specifies the RES ONE Service Store API endpoint and action to call
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultObject')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultHashtable')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginObject')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginHashtable')]
        [System.Uri] $Uri,

        # RES ONE Service Store session connection
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultHashtable')]
        [System.Collections.Hashtable] $Session = $script:_RESONEServiceStoreSession,

        # Specifies the HTTP action to perform
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultObject')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultHashtable')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginObject')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginHashtable')]
        [ValidateSet('Get','Post','Put','Delete')]
        [System.String] $Method,

        # Specifies that no authorisation header should be added to the request
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginObject')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LoginHashtable')]
        [Alias('NoAuthorisation')]
        [System.Management.Automation.SwitchParameter] $NoAuthorization,

        # Specifies the body of the HTTP request
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LoginObject')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject] $InputObject,

        # Specifies the body of the HTTP request
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultHashtable')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LoginHashtable')]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Body,

        # Specifies the property to expand from the API response
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DefaultHashtable')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LoginObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'LoginHashtable')]
        [ValidateNotNullOrEmpty()]
        [System.String] $ExpandProperty
    )
    begin {

        if ($PSCmdlet.ParameterSetName -in 'DefaultObject','DefaultHashtable') {

            Assert-ROSSSession -Session $Session;;
        }
    }
    process {

        $invokeRestMethodParams = @{
            Uri = $Uri;
        }

        if ($PSBoundParameters.ContainsKey('InputObject')) {

            $invokeRestMethodParams['Body'] = ConvertTo-Json -InputObject $InputObject -Depth 100 -Compress;
        }
        elseif ($PSBoundParameters.ContainsKey('Body')) {

            $invokeRestMethodParams['Body'] = ConvertTo-Json -InputObject $Body -Depth 100 -Compress;
        }

        if ($Method -ne 'Get') {

            $invokeRestMethodParams['Method'] = $Method;
            $invokeRestMethodParams['ContentType'] = 'application/json';
        }

        if ($PSCmdlet.ParameterSetName -in 'DefaultObject','DefaultHashtable') {

            ## Build header that contains authentication key
            $headers = New-Object -TypeName 'System.Collections.Generic.Dictionary[[String],[String]]';
            [ref] $null = $headers.Add('Auth-Token', $Session.AuthorizationToken);
            $invokeRestMethodParams['Headers'] = $headers;
        }

        $response = Invoke-RestMethod @invokeRestMethodParams;

        if ($PSBoundParameters.ContainsKey('ExpandProperty')) {
            return $response.$ExpandProperty;
        }
        else {
            return $response;
        }

    } #end process
} #end function Invoke-ROSSRestMethod
