## Import the ROSSCommon module
$moduleRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\DSCResources\ROSSCommon\ROSSCommon.psd1").Path;
Import-Module $moduleRoot -Force;

Describe 'RESONEServiceStore\ROSSCommon\Resolve-ROSSPackagePath' {

    $architecture = 'x86';
    if ([System.Environment]::Is64BitOperatingSystem) {
        $architecture = 'x64';
    }

    It 'Should resolve v9.1 Setup/Sync Tool' {
        
        $v91SetupMsi = "RES-ONE-ServiceStore-2016-Setup-Sync-Tool($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91SetupMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component Console -Version 9.1;

        $result.EndsWith($v91SetupMsi) | Should Be $true;
    }

    It 'Should resolve v9.1 Transaction Engine' {
        
        $v91TransactionEngineMsi = "RES-ONE-ServiceStore-2016-Transaction-Engine($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component TransactionEngine -Version 9.1;

        $result.EndsWith($v91TransactionEngineMsi) | Should Be $true;
    }

    It 'Should resolve v9.1 Catalog Services' {
        
        $v91CatalogServicesMsi = "RES-ONE-ServiceStore-2016-Catalog-Services($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91CatalogServicesMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component CatalogServices -Version 9.1;

        $result.EndsWith($v91CatalogServicesMsi) | Should Be $true;
    }

    It 'Should resolve v9.1 Managment Portal' {
        
        $v91ManagementPortalMsi = "RES-ONE-ServiceStore-2016-Management-Portal-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91ManagementPortalMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component ManagementPortal -Version 9.1;

        $result.EndsWith($v91ManagementPortalMsi) | Should Be $true;
    }

    It 'Should resolve v9.1 Web Portal' {
        
        $v91WebPortalMsi = "RES-ONE-ServiceStore-2016-WebPortal-MobileGateway-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91WebPortalMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component WebPortal -Version 9.1;

        $result.EndsWith($v91WebPortalMsi) | Should Be $true;
    }

    It 'Should resolve v9.1 Client' {
        
        $v91ClientMsi = "RES-ONE-ServiceStore-2016-Client($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91ClientMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component Client -Version 9.1;

        $result.EndsWith($v91ClientMsi) | Should Be $true;
    }

    It 'Should resolve later v9.1.1 installer' {
        
        $v91TransactionEngineMsi = "RES-ONE-ServiceStore-2016-Transaction-Engine($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v911TransactionEngineMsi = "RES-ONE-ServiceStore-2016-Transaction-Engine($architecture)-9.1.1.0.msi";
        New-Item -Path $TestDrive -Name $v911TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component TransactionEngine -Version 9.1;

        $result.EndsWith($v911TransactionEngineMsi) | Should Be $true;
    }

    It 'Should resolve later v10.0.100.0 installer' {
        
        $v10TransactionEngineMsi = "RES ONE Identity Director Transaction Engine ($architecture) 10.0.0.0.msi";
        New-Item -Path $TestDrive -Name $v10TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v10100TransactionEngineMsi = "RES ONE Identity Director Transaction Engine ($architecture) 10.0.100.0.msi";
        New-Item -Path $TestDrive -Name $v10100TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component TransactionEngine -Version 10;

        $result.EndsWith($v10100TransactionEngineMsi) | Should Be $true;
    }

    It 'Should resolve explicit v9.1.0 installer' {
        
        $v91TransactionEngineMsi = "RES-ONE-ServiceStore-2016-Transaction-Engine($architecture)-9.1.0.0.msi";
        New-Item -Path $TestDrive -Name $v91TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;
        $v911TransactionEngineMsi = "RES-ONE-ServiceStore-2016-Transaction-Engine($architecture)-9.1.1.0.msi";
        New-Item -Path $TestDrive -Name $v911TransactionEngineMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component TransactionEngine -Version 9.1.0;

        $result.EndsWith($v91TransactionEngineMsi) | Should Be $true;
    }
    
    It 'Should resolve v10.0 Setup/Sync Tool' {

         
        $v10SetupMsi = "RES ONE Identity Director Setup Sync Tool ($architecture) 10.0.0.0.msi";
        New-Item -Path $TestDrive -Name $v10SetupMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component Console -Version 10;

        $result.EndsWith($v10SetupMsi) | Should Be $true;
    }

    It 'Should throw when "MobileGateway" component is specified on versions prior to v10' {

        { Resolve-ROSSPackagePath -Path $TestDrive -Component MobileGateway -Version 9.1 } | Should Throw 'Version 10 is required';
    }

    It 'Should resolve v10.0 Mobile Gateway' {

         
        $v10MobileGatewayMsi = "RES ONE Identity Director Mobile Gateway 10.0.0.0.msi";
        New-Item -Path $TestDrive -Name $v10MobileGatewayMsi -ItemType File -Force -ErrorAction SilentlyContinue;

        $result = Resolve-ROSSPackagePath -Path $TestDrive -Component MobileGateway -Version 10;

        $result.EndsWith($v10MobileGatewayMsi) | Should Be $true;
    }

} #end describe
