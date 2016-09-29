function Disable-ROSSServiceWorkflowAction {
<#
    .SYNOPSIS
        Disables RES ONE Service Store service workflow actions.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'DeliveryName')]
    param (
        # RES ONE Service Store session connection.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [System.Collections.Hashtable] $Session = $Script:_RESONEServiceStoreSession,

        # Specifies to disable the workflow action in the delivery workflow
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [System.Management.Automation.SwitchParameter] $Delivery,

        # Specifies to disable the workflow action in the return workflow
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [System.Management.Automation.SwitchParameter] $Return,

        # Specifies the RES ONE Service Store service(s) to disable by name.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $ServiceName,

        # Specifies the RES ONE Service Store service(s) to disable by reference.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [ValidateNotNull()]
        [PSCustomObject[]] $InputObject,

        # Specifies the RES ONE Service Store service workflow action name(s) to disable.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        # Specifies matching of the workflow action name should not be performed on the custom/friendly name.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [System.Management.Automation.SwitchParameter] $ExcludeFriendlyName,

        # Returns the updated RES ONE Service Store service object to the pipeline.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [System.Management.Automation.SwitchParameter] $PassThru,

        # Specifies any comfirmation prompts should be suppressed.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'DeliveryInputObject')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnName')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ReturnInputObject')]
        [System.Management.Automation.SwitchParameter] $Force
    )
    begin {

        Assert-ROSSSession -Session $Session;
    }
    process {

        if ($PSBoundParameters.ContainsKey('ServiceName')) {
            $InputObject = Get-ROSSService -Session $Session -ServiceName $ServiceName;
        }

        try {

            foreach ($service in $InputObject) {

                if ($Delivery) {
                    $serviceWorkflowActions = $service.Workflow.Delivery.Actions;
                }
                elseif ($Return) {
                    $serviceWorkflowActions = $service.Workflow.Return.Actions;
                }

                ## Find all matching workflow action namess
                $matchingWorkflowActions = @();
                foreach ($workflowActionName in $Name) {
                    if ($ExcludeFriendlyName) {

                        $matchingWorkflowActions += $serviceWorkflowActions |
                            Where-Object { $_.Name -match $workflowActionName }
                    }
                    else {

                        $matchingWorkflowActions += $serviceWorkflowActions |
                            Where-Object { $_.Name -match $workflowActionName -or
                                $_.ActionFriendlyName -match $workflowActionName }
                    }
                }

                ## Only confirm/process if we have matching action name(s)
                if ($matchingWorkflowActions.Count -gt 0) {

                    if ($Force -or ($PSCmdlet.ShouldProcess($service.Name, $localizedData.ShouldProcessDisable))) {

                        ## Now disable all matching workflow actions
                        foreach ($workflowAction in $matchingWorkflowActions) {
                            $workflowAction.Enabled = $false;
                        }
                        $setROSSServiceParams = @{
                            Session = $Session;
                            InputObject = $service;
                            Force = $true;
                            PassThru = $PassThru;
                        }
                        Set-ROSSService @setROSSServiceParams;
                    }
                }
                else {

                    ## We have no matching workflow action
                    Write-Warning -Message ($localizedData.NoMatchingWorkflowActionsFound -f $service.Name);

                }
            } #end foreach service
        }
        catch {

            throw $_;
        }

    } #end process
} #end function Disable-ROSSServiceWorkflowAction
