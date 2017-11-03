function Resolve-ROSSPackagePath {
<#
    .SYNOPSIS
        Resolves the latest RES ONE Identity Director/Service Store/IT Store installation package.
#>
    [CmdletBinding()]
    param (
        ## The literal file path or root search path
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        ## Required RES ONE Service Store component
        ## MobileGateway added/separated from the WebPortal in v10 onwards
        [Parameter(Mandatory)]
        [ValidateSet('Console','CatalogServices','TransactionEngine','ManagementPortal','WebPortal','Client','MobileGateway')]
        [System.String] $Component,

        ## RES ONE Service Store component version to be installed, i.e. 9, 8.2 or 8.2.2.0
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version,

        ## The specified Path is a literal file reference (bypasses the Version check).
        [Parameter()]
        [System.Boolean] $IsLiteralPath
    )

    if (([System.String]::IsNullOrWhitespace($Version)) -and (-not $IsLiteralPath)) {

        throw ($localizedData.VersionNumberRequiredError);
    }
    elseif ($IsLiteralPath) {

        if ($Path -notmatch '\.msi$') {

            throw ($localizedData.SpecifedPathTypeError -f $Path, 'MSI');
        }
    }
    elseif ($Version -notmatch '^\d\d?(\.\d\d?|\.\d\d?\.\d\d?|\.\d\d?\.\d\d?\.\d\d?)?$') {

         throw ($localizedData.InvalidVersionNumberFormatError -f $Version);
    }
    else {

        $versionMajor = $Version.Split('.')[0] -as [System.Int32];
        if (($Component -eq 'MobileGateway') -and ($versionMajor -lt 10)) {
            
            throw ($localizedData.InvalidComponentVersionError -f 'MobileGateway', 10);
        }
    }

    if ($IsLiteralPath) {

        $packagePath = $Path;
    }
    else {

        ## [System.Version] does not support just a major number and therefore, we have to roll our own..
        $versionSplit = $Version.Split('.');
        $productVersion = [PSCustomObject] @{
            Major = $versionSplit[0] -as [System.Int32];
            Minor = if ($versionSplit[1]) { $versionSplit[1] -as [System.Int32] } else { -1 }
            Build = if ($versionSplit[2]) { $versionSplit[2] -as [System.Int32] } else { -1 }
            Revision = if ($versionSplit[3]) { $versionSplit[3] -as [System.Int32] } else { -1 }
        }

        switch ($productVersion.Major) {

            7 {
                $packageName = 'RES-ITS';
                $webPortalPackageName = 'Web-Portal';
                $consolePackageName = 'Console'
            }

            8 {
                $packageName = 'RES-ONE-ServiceStore-2015';
                $webPortalPackageName = 'WebPortal-MobileGateway';
                $consolePackageName = 'Setup-Sync-Tool';
            }

            9 {
                $packageName = 'RES-ONE-ServiceStore-2016';
                $webPortalPackageName = 'WebPortal-MobileGateway';
                $consolePackageName = 'Setup-Sync-Tool';
            }

            10 {
                
                $packageName = 'RES ONE Identity Director';
                $webPortalPackageName = 'Web Portal';
                $mobileGatewayPackageName = 'Mobile Gateway';
                $consolePackageName = 'Setup Sync Tool';
            }

            Default {

                throw ($localizedData.UnsupportedVersionError -f $productVersion.ToString());
            }

        } #end switch version major

        ## Calculate the version search Regex
        if (($productVersion.Minor -eq -1) -and
            ($productVersion.Build -eq -1) -and
            ($productVersion.Revision -eq -1)) {

            ## We only have 'Major'
            $versionRegex = '{0}.\S+' -f $productVersion.Major;
        }
        elseif (($productVersion.Build -eq -1) -and
                ($productVersion.Revision -eq -1)) {

            ## We only have 'Major.Minor'
            $versionRegex = '{0}.{1}.\S+' -f $productVersion.Major, $productVersion.Minor;
        }
        elseif ($productVersion.Revision -eq -1) {

            ## We have 'Major.Minor.Build'
            $versionRegex = '{0}.{1}.{2}.\S+' -f $productVersion.Major, $productVersion.Minor, $productVersion.Build;
        }
        else {

            ## We have explicit version.
            $versionRegex = '{0}.{1}.{2}.{3}' -f $productVersion.Major, $productVersion.Minor, $productVersion.Build, $productVersion.Revision;
        }

        $systemArchitecture = 'x86';
        if ([System.Environment]::Is64BitOperatingSystem) {

            $systemArchitecture = 'x64';
        }

        switch ($Component) {

            'TransactionEngine' {

                ## RES-ITS-Transaction-Engine(x64)-7.3.0.0.msi
                ## RES-ONE-ServiceStore-2015-Transaction-Engine(x64)-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2016-Transaction-Engine(x64)-9.0.1.0.msi
                ## RES ONE Identity Director Transaction Engine (x64) 10.0.0.0.msi
                $regex = '{0}-Transaction-Engine\({1}\)-{2}.msi' -f $packageName, $systemArchitecture, $versionRegex;
            }

            'CatalogServices' {

                ## RES-ITS-Catalog-Services(x64)-7.3.0.0.msi
                ## RES-ONE-ServiceStore-2015-Catalog-Services(x64)-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2015-Catalog-Services(x64)-9.0.1.0.msi
                ## RES ONE Identity Director Catalog Services (x64) 10.0.0.0.msi
                $regex = '{0}-Catalog-Services\({1}\)-{2}.msi' -f $packageName, $systemArchitecture, $versionRegex;
            }

            'ManagementPortal' {

                ## Not applicable to IT Store 2014
                ## RES-ONE-ServiceStore-2015-Management-Portal-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2016-Management-Portal-9.0.1.0.msi
                ## RES ONE Identity Director Management Portal 10.0.0.0.msi
                $regex = '{0}-Management-Portal-{1}.msi' -f $packageName, $versionRegex;
            }

            'WebPortal' {

                ## RES-ITS-Web-Portal-7.3.0.0.msi
                ## RES-ONE-ServiceStore-2015-WebPortal-MobileGateway-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2016-WebPortal-MobileGateway-9.0.1.0.msi
                $regex = '{0}-{1}-{2}.msi' -f $packageName, $webPortalPackageName, $versionRegex;
            }

            'Client' {

                ## RES-ITS-Client(x64)-7.3.0.0.msi
                ## RES-ONE-ServiceStore-2015-Client(x64)-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2016-Client(x64)-9.0.1.0.msi
                ## RES ONE Identity Director Client (x86) 10.0.0.0.msi
                $regex = '{0}-Client\({1}\)-{2}.msi' -f $packageName, $systemArchitecture, $versionRegex;
            }

            'MobileGateway' {
                
                ## Version 10 only!
                ## RES ONE Identity Director Mobile Gateway 10.0.0.0.msi
                $regex = '{0} {1} {2}' -f $packageName, $mobileGatewayPackageName, $versionRegex;
            }

            Default {

                ## RES-ITS-Console(x64)-7.3.0.0.msi
                ## RES-ONE-ServiceStore-2015-Setup-Sync-Tool(x64)-8.2.2.0.msi
                ## RES-ONE-ServiceStore-2016-Setup-Sync-Tool(x64)-9.0.1.0.msi
                ## RES ONE Identity Director Setup Sync Tool (x64) 10.0.0.0.msi
                $regex = '{0}-{1}\({2}\)-{3}.msi' -f $packageName, $consolePackageName, $systemArchitecture, $versionRegex;
            }

        } #end switch component

        if ($productVersion.Major -ge 10) {

            ## Version 10 products have no hypens, only spaces..
            ## Version 10 products have a space before the architecture..
            $regex = $regex.Replace('-',' ').Replace('\(', ' \(');

            ## Identity Director 10.2.0.0 dropped the 'RES ONE' prefix so make it optional
            $regex = $regex.Replace('RES ONE ','(RES ONE )?');
        }

        Write-Verbose -Message ($localizedData.SearchFilePatternMatch -f $regex);

        $packagePath = Get-ChildItem -Path $Path -Recurse |
            Where-Object { $_.Name -imatch $regex } |
                Sort-Object -Property Name -Descending |
                    Select-Object -ExpandProperty FullName -First 1;

        if ((-not $IsLiteralPath) -and (-not [System.String]::IsNullOrEmpty($packagePath))) {

            Write-Verbose ($localizedData.LocatedPackagePath -f $packagePath);
            return $packagePath;
        }
        elseif ([System.String]::IsNullOrEmpty($packagePath)) {

            throw  ($localizedData.UnableToLocatePackageError -f $Component);
        }

    } #end if

} #end function Resolve-ROSSPackagePath
