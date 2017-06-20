function Test-ParameterCollection {
<#
    .SYNOPSIS
        Tests whether one of the specified parameters are present in a collection.
#>
    [CmdletBinding()]
    param (
        ## Specifies a PSBoundParametersDictionary collection containing the parameters to validate.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ParameterCollection,

        ## Specifies parameter name(s) to test for.
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyCollection()]
        [System.String[]] $ParameterName
    )
    process {

        $hasParameter = $false;
    
        foreach ($parameter in $ParameterName) {

            if ($ParameterCollection.ContainsKey($parameter)) {

                $hasParameter = $true;
            }
        }
        
        return $hasParameter;

    } #end process
} #end function
