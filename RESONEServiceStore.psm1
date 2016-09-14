data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        CannotFindFilePathError        = Cannot find path '{0}' because it does not exist.
        FileAlreadyExistsError         = File or directory '{0}' already exists.
        NoSessionEstablishedError      = No RES ONE Service Store session established or session has expired.

        ShouldProcessImport            = Import
        ShouldProcessSet               = Set
        ShouldProcessUpdate            = Update
        ShouldProcessEnable            = Enable
        ShouldProcessDisable           = Disable
        NoMatchingWorkflowActionsFound = No matching workflow actions found on service '{0}'.
'@
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }


## Import the \DSCResources\ROSSCommon common library functions
Import-Module (Join-Path -Path $moduleRoot -ChildPath '\DSCResources\ROSSCommon') -Force -Verbose:$false;
