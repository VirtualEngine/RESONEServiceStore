data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        StartingProcess                 = Starting process '{0}' with parameters '{1}'.
        StartingProcessAs               = Starting process as user '{0}'.
        ProcessLaunched                 = Process id '{0}' successfully started.
        WaitingForProcessToExit         = Waiting for process id '{0}' to exit.
        ProcessExited                   = Process id '{0}' exited with code '{1}'.
        OpeningMSIDatabase              = Opening MSI database '{0}'.
        SearchFilePatternMatch          = Searching for files matching pattern '{0}'.
        LocatedPackagePath              = Located package '{0}'.

        VersionNumberRequiredError      = Version number is required when not using a literal path.
        SpecifedPathTypeError           = Specified path '{0}' does not point to a '{1}' file.
        InvalidVersionNumberFormatError = The specified version '{0}' does not match '1.2', '1.2.3' or '1.2.3.4' format.
        UnsupportedVersionError         = Version '{0}' is not supported/untested :(
        UnableToLocatePackageError      = Unable to locate '{0}' package.
        InvalidComponentVersionError    = Component '{0}' is not supported in this version. Version {1} is required.
        MissingRequiredParametersError  = Missing required parameter(s) '{0}'.
        InvalidParametersSpecifiedError = Invalid parameter(s) specified '{0}'.
'@
}


$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }


Export-ModuleMember -Function *;
