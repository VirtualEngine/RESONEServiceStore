function Start-WaitProcess {
<#
    .SYNOPSIS
        Starts and waits for a process to exit.
    .NOTES
        This is an internal function and shouldn't be called from outside.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Int32])]
    param (
        # Path to process to start.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        # Arguments (if any) to apply to the process.
        [Parameter()]
        [AllowNull()]
        [System.String[]] $ArgumentList,

        # Credential to start the process as.
        [Parameter()]
        [AllowNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        # Working directory
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $WorkingDirectory = (Split-Path -Path $FilePath -Parent)
    )
    process {

        $startProcessParams = @{
            FilePath = $FilePath;
            WorkingDirectory = $WorkingDirectory;
            NoNewWindow = $true;
            PassThru = $true;
        };
        $displayParams = '<None>';

        if ($ArgumentList) {

            $displayParams = [System.String]::Join(' ', $ArgumentList);
            $startProcessParams['ArgumentList'] = $ArgumentList;
        }

        Write-Verbose ($localizedData.StartingProcess -f $FilePath, $displayParams);

        if ($Credential) {

            Write-Verbose ($localizedData.StartingProcessAs -f $Credential.UserName);
            $startProcessParams['Credential'] = $Credential;
        }

        if ($PSCmdlet.ShouldProcess($FilePath, 'Start Process')) {

            $process = Start-Process @startProcessParams -ErrorAction Stop;
        }

        if ($PSCmdlet.ShouldProcess($FilePath, 'Wait Process')) {

            Write-Verbose ($localizedData.ProcessLaunched -f $process.Id);
            Write-Verbose ($localizedData.WaitingForProcessToExit -f $process.Id);
            $process.WaitForExit();
            $exitCode = [System.Convert]::ToInt32($process.ExitCode);
            Write-Verbose ($localizedData.ProcessExited -f $process.Id, $exitCode);
        }

        return $exitCode;

    } #end process
} #end function Start-WaitProcess
