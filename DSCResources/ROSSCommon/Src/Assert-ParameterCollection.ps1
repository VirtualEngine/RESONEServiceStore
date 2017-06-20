function Assert-ParameterCollection {
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

        ## Specifies a list of parameter names that are not permitted to be in the collection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyCollection()]
        [System.String[]] $InvalidParameterName,

        ## Specifies a list of parameter names that are required to be in the collection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [AllowEmptyCollection()]
        [System.String[]] $RequiredParameterName,

        ## Multiple parameter sets (keys) where any specified string[] is present, all must be present.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable] $ParameterSetName,

        ## Version/verbose information string appended to the end of generated error messages.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $AppendString
    )
    process {

        if ($PSBoundParameters.ContainsKey('InvalidParameterName')) {

            $testParameterCollectionParams = @{
                ParameterCollection = $ParameterCollection;
                ParameterName = $InvalidParameterName;
            } 
            $hasInvalidParameter = Test-ParameterCollection @testParameterCollectionParams;

            if ($hasInvalidParameter) {
                
                $invalidParametersString = $InvalidParameterName -join "', '";
                $invalidParametersErrorString = $localizedData.InvalidParametersSpecifiedError -f $invalidParametersString;

                if ($PSBoundParameters.ContainsKey('AppendString')) {

                    $invalidParametersErrorString = $invalidParametersErrorString.Trim('.');
                    $invalidParametersErrorString = '{0} {1}.' -f $invalidParametersErrorString, $AppendString;

                }
                        
                throw $invalidParametersErrorString;
                
            } #end if invalid parameter
        }

        if ($PSBoundParameters.ContainsKey('RequiredParameterName')) {

            $assertRequiredParameterCollectionParams = @{
                ParameterCollection = $ParameterCollection;
                RequiredParameterName = $RequiredParameterName;
            }
            if ($PSBoundParameters.ContainsKey('AppendString')) {

                $assertRequiredParameterCollectionParams['AppendString'] = $AppendString;
            }
            Assert-RequiredParameterCollection @assertRequiredParameterCollectionParams;

        }

        if ($PSBoundParameters.ContainsKey('ParameterSetName')) {

            foreach ($parameterSet in $ParameterSetName.GetEnumerator()) {

                $testParameterCollectionParams = @{
                    ParameterCollection = $ParameterCollection;
                    ParameterName = $parameterSet.Value;
                } 
                
                $hasParameterSet = Test-ParameterCollection @testParameterCollectionParams;

                if ($hasParameterSet) {

                    $assertRequiredParameterCollectionParams = @{
                        ParameterCollection = $ParameterCollection;
                        RequiredParameterName = $parameterSet.Value;
                    }
                    if ($PSBoundParameters.ContainsKey('AppendString')) {

                        $assertRequiredParameterCollectionParams['AppendString'] = $AppendString;
                    }
                    Assert-RequiredParameterCollection @assertRequiredParameterCollectionParams;

                } #end if has parameter set

            } #end forach parameter set
        } #end if parameter set

    } #end process
} #end function
