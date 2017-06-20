
function Assert-RequiredParameterCollection {
<#
    .SYNOPSIS
        Asserts that a $PSBoundParameters collection does or does not contain some parameter
        names. This implements parameters set enforcement for DSC resources.
#>
    [CmdletBinding()]
    param (
        ## Specifies a PSBoundParametersDictionary collection containing the parameters to validate.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ParameterCollection,

        ## Specifies a list of parameter names that are required to be in the collection.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [AllowEmptyCollection()]
        [System.String[]] $RequiredParameterName,

        ## Version/verbose information string appended to the end of generated error messages.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $AppendString
    )
    process {

        $missingRequiredParameters = @( );
        foreach ($parameterName in $RequiredParameterName) {
 
            if (-not $ParameterCollection.ContainsKey($parameterName)) {

                $missingRequiredParameters += $parameterName;
            }
        }

        if ($missingRequiredParameters.Count -gt 0) {

            $missingParametersString = $missingRequiredParameters -join "', '";
            $missingParametersErrorString = $localizedData.MissingRequiredParametersError -f $missingParametersString;

            if ($PSBoundParameters.ContainsKey('AppendString')) {

                $missingParametersErrorString = $missingParametersErrorString.Trim('.');
                $missingParametersErrorString = '{0} {1}.' -f $missingParametersErrorString, $AppendString;

            }
                
            throw $missingParametersErrorString;             
        
        }

    } #end process
} #end function
