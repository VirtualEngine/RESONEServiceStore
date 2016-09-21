RES ONE Service Store DSC Resources
===================================
## Included Resources
* **ROSSBuildingBlock**: Imports a RES ONE Service Store building block
* **ROSSCatalogServices**: Installs the RES ONE Service Store Catalog Services component
* **ROSSClient**: Installs the RES ONE Service Store Windows client component
* **ROSSConsole**: Installs the RES ONE Service Store Setup and Sync tool
* **ROSSDatabase**: Installs the RES ONE Service Store Setup and Sync tool and creates the RES ONE Service Store database
* **ROSSLab (Composite)**: Deploys a single-node RES ONE Service Store lab server environment
* **ROSSLabHttps (Composite)**: Deploys a single-node RES ONE Service Store lab server environment with HTTPS bindings
* **ROSSManagementPortal**: Installs the RES ONE Service Store management portal component
* **ROSSTransactionEngine**: Installs the RES ONE Service Store Transaction Engine component
* **ROSSWebPortal**: Installs the RES ONE Service Store Web Portal component

## Required Resources
* **xNetworking**: ROSSLab and ROSSLabHttps require https://github.com/PowerShell/xNetworking to create firewall rules
* **xWebAdministration**: ROSSLabHttps requires https://github.com/PowerShell/xWebAdministration to create the HTTPS binding

ROSSBuildingBlock
==================
Imports a RES ONE Service Store building block.
### Syntax
```
ROSSBuildingBlock [String] #ResourceName
{
    Path = [String]
    Server = [String]
    Credential = [PSCredential]
    [ UseHttps = [Boolean] ]
    [ EnableTransactions = [Boolean] ]
    [ NoClobber = [Boolean] ]
    [ DeleteFromDisk = [Boolean] ]
}
```

ROSSCatalogServices
===================
Installs the RES ONE Service Store Catalog Services component.
### Syntax
```
ROSSCatalogServices [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSClient
==========
Installs the RES ONE Service Store Windows client component.
### Syntax
```
ROSSClient [String] #ResourceName
{
    CatalogServicesCredential = [PSCredential]
    CatalogServicesHost = [String]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSConsole
===========
Installs the RES ONE Service Store Setup and Sync tool.
### Syntax
```
ROSSConsole [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    CatalogServicesCredential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSDatabase
============
Installs the RES ONE Service Store Setup and Sync tool and creates the RES ONE Service Store database.
### Syntax
```
ROSSDatabase [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    CatalogServicesCredential = [PSCredential]
    Path = [String]
    [ LicensePath = [String] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSLab
=======
Deploys a single-node RES ONE Service Store lab server environment.
### Syntax
```
ROSSLab [String] #ResourceName
{
    DatabaseServer = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    CatalogServicesCredential = [PSCredential]
    Path = [String]
    Version = [String]
    HostHeader = [String]
    DefaultDomain = [String]
    [ DatabaseName = [String] ]
    [ Port = [UInt16] ]
    [ BuildingBlockPath = [String] ]
    [ BuildingBlockCredential = [PSCredential] ]
    [ DeleteBuildingBlock = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSLabHttps
============
Deploys a single-node RES ONE Service Store lab server environment with HTTPS bindings.
### Syntax
```
ROSSLabHttps [String] #ResourceName
{
    DatabaseServer = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    CatalogServicesCredential = [PSCredential]
    Path = [String]
    Version = [String]
    HostHeader = [String]
    DefaultDomain = [String]
    PfxCertificateThumbprint = [String]
    [ DatabaseName = [String] ]
    [ Port = [UInt16] ]
    [ BuildingBlockPath = [String] ]
    [ BuildingBlockCredential = [PSCredential] ]
    [ DeleteBuildingBlock = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSManagementPortal
====================
Installs the RES ONE Service Store management portal component.
### Syntax
```
ROSSManagementPortal [String] #ResourceName
{
    HostHeader = [String]
    Path = [String]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSTransactionEngine
=====================
Installs the RES ONE Service Store Transaction Engine component.
### Syntax
```
ROSSTransactionEngine [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Credential = [PSCredential]
    Path = [String]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

ROSSWebPortal
=============
Installs the RES ONE Service Store Web Portal component.
### Syntax
```
ROSSWebPortal [String] #ResourceName
{
    DefaultDomain = [String]
    HostHeader = [String]
    CatalogServicesCredential = [PSCredential]
    CatalogServicesHost = [String]
    Path = [String]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```
