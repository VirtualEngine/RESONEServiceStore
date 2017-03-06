data localizedData {
    # Localized messages; culture="en-US"
    ConvertFrom-StringData @'
        CannotFindFilePathError        = Cannot find path '{0}' because it does not exist.
        FileAlreadyExistsError         = File or directory '{0}' already exists.
        NoSessionEstablishedError      = No RES ONE Service Store session established or session has expired.
        NoApiSessionEstablishedError   = No RES ONE Service Store API session established or session has expired.
        NoDbSessionEstablishedError    = No RES ONE Service Store database session established or session has expired.
        InputObjectTypeMismatchError   = InputObject is not a '{0}' type.
        StartDateAfterEndDateError     = Start date cannot be after the end date.
        UnsupportedDbConnectionType    = Unsupported database connection type '{0}'.

        UnsupportedOperationWarning    = The '{0}' cmdlet is an unsupported operation. USE WITH EXTREME CAUTION.

        ShouldProcessImport            = Import
        ShouldProcessSet               = Set
        ShouldProcessUpdate            = Update
        ShouldProcessEnable            = Enable
        ShouldProcessDisable           = Disable
        ShouldProcessDelete            = Delete
        ShouldProcessNew               = New
        NoMatchingWorkflowActionsFound = No matching workflow actions found on service '{0}'.
        InvokingSQLQuery               = Invoking SQL query "{0}".
'@
}

$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent;
$moduleSrcPath = Join-Path -Path $moduleRoot -ChildPath 'Src';
Get-ChildItem -Path $moduleSrcPath -Include '*.ps1' -Recurse |
    ForEach-Object {
        Write-Verbose -Message ('Importing library\source file ''{0}''.' -f $_.FullName);
        . $_.FullName;
    }

$script:customProperties = @{
    ## Custom RES ONE Service Store property map

    'VirtualEngine.ROSS.DataSource' = @{
        Type = @{
            DataSourceColumn = 'SpecificFlags';
            ValueMap = @{
                1 = 'CSV';
                2 = 'ActiveDirectory';
                3 = 'ODBC';
            }
        }
    }

    'VirtualEngine.ROSS.DataConnection' = @{
        Type = @{
            DataSourceColumn = 'Type';
            ValueMap = @{
                1 = 'People';
                2 = 'Organization';
                3 = 'Classification';
                4 = 'Attribute';
            }
        }
        Errors = @{
            DataSourceColumn = 'SyncErrors';
        }
        LastSyncDate = @{
            DataSourceColumn = 'SyncEndDate';
        }
    }

    'VirtualEngine.ROSS.Organization' = @{
        OrganizationId = @{
            DataSourceColumn = 'Id'; ## for pipeline support
        }
    }

    'VirtualEngine.ROSS.Service' = @{
        ServiceId = @{
            DataSourceColumn = 'Id'; ## for pipeline support
        }
    }

    'VirtualEngine.ROSS.Transaction' = @{
        Delivery = @{
            DataSourceColumn = 'Direction';
            ValueMap = @{
                Provision = 'Deliver';
                Deprovision = 'Return';
            }
        }
    }

    'VirtualEngine.ROSS.Person' = @{
        PersonId = @{
            DataSourceColumn = 'Id'; ## for pipeline support
        }
    }

} #end customProperties

## Import the \DSCResources\ROSSCommon common library functions
Import-Module (Join-Path -Path $moduleRoot -ChildPath '\DSCResources\ROSSCommon') -Force -Verbose:$false;
