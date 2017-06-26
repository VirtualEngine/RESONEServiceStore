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
* **ROSSManagementPortalConfig**: Deploys a RES ONE Service Store IIS management portal configuration file (v10 and later)
* **ROSSMobileGateway**: Installs the RES ONE Identity Directory (v10 and later) mobile gateway component
* **ROSSMobileGatewayConfig**: Deploys a RES ONE Service Store IIS mobile gateway configuration file (v10 and later)
* **ROSSTransactionEngine**: Installs the RES ONE Service Store Transaction Engine component
* **ROSSWebPortal**: Installs the RES ONE Service Store Web Portal component
* **ROSSWebPortalConfig**: Deploys a RES ONE Service Store IIS web portal configuration file (v10 and later)
* **ROIDLab (Composite)**: Deploys a single-node RES ONE Identity Director lab server environment

## Required Resources

* **xNetworking**: ROSSLab, ROSSLabHttps and ROIDLab require https://github.com/PowerShell/xNetworking to create firewall rules
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
    [ CatalogServicesHost = [String] ]
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
    [ CatalogServicesHost = [String] ]
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
    [ CertificateThmubprint = [String] ]
    [ DefaultDomain = [String] ]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

### Properties

* **HostHeader**: IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
* **Path**: File path containing the RES ONE Service Store MSIs or the literal path to the installer.
* **CertificateThmubprint**: Installed certificate thumbprint to bind to the IIS site (v10 and later).
* **DefaultDomain**: RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier)
* **Port**: IIS website port binding.
* **Version**: RES ONE Service Store component version to be installed, i.e. 8.0.3.0.
* **IsLiteralPath**: Specified path is a literal file reference.
* **Ensure**: Whether the role is to be installed or not. Supported values are Present or Absent. If not specified, it defaults to Present.

ROSSManagementPortalConfig
==========================

Deploys a RES ONE Service Store IIS configuration management portal file.

### Syntax

```
ROSSManagementPortalConfig [String] #ResourceName
{
    DatabaseName = [String]
    DatabaseServer = [String]
    Path = [String]
    [Credential = [PSCredential] ]
    [IdentityBrokerUrl = [String] ]
    [ApplicationUrl = [String] ]
    [ClientId = [String] ]
    [ClientSecret = [PSCredential] ]
    [Ensure = [String] { Absent | Present } ]
}
```

### Properties

* **DatabaseServer**: RES ONE Service Store database server/instance name.
* **DatabaseName**: RES ONE Service Store database name.
* **Path**: RES ONE Service Store web management portal configuration file path.
* **Credential**: RES ONE Service Store database Microsoft SQL username/password.
* **IdentityBrokerUrl**: RES ONE Identity Broker Uri.
* **ApplicationUrl**: RES ONE Identity Director Management Portal Application/Callback Uri.
* **ClientId**: RES ONE Identity Broker Client ID.
* **ClientSecret**: "RES ONE Identity Broker Client shared secret.
* **Ensure**: Whether the configuration file is created or not. Supported values are Present or Absent. If not specified, it defaults to Present.

ROSSMobileGateway
=================

Installs the RES ONE Identity Director (v10 and later) mobile gateway portal component.

### Syntax

```
ROSSMobileGateway [String] #ResourceName
{
    HostHeader = [String]
    Path = [String]
    CertificateThumbprint = [String]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present }]
}
```

### Properties

* **HostHeader**: IIS website host header/hostname.
* **Path**: File path containing the RES ONE Automation MSIs or the literal path to the installer.
* **CertificateThumbprint**: TLS/SSL certificate thumbprint.
* **Port**: IIS website port binding.
* **Version**: RES ONE Automation component version to be installed, i.e. 8.0.3.0.
* **IsLiteralPath**: Specified path is a literal file reference.
* **Ensure**: Whether the configuration file is created or not. Supported values are Present or Absent. If not specified, it defaults to Present.

ROSSMobileGatewayConfig
=======================

Deploys a RES ONE Service Store IIS mobile gateway configuration file (v10 and later).

### Syntax

```
ROSSMobileGatewayConfig [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Path = [String]
    [Credential = [PSCredential] ]
    [Ensure = [String] { Absent | Present } ]
}
```

### Properties

* **DatabaseServer**: RES ONE Service Store database server/instance name.
* **DatabaseName**: RES ONE Service Store database name.
* **Path**: RES ONE Service Store web portal configuration file path.
* **Credential**: RES ONE Service Store database Microsoft SQL username/password.
* **Ensure**: Whether the configuration file is created or not. Supported values are Present or Absent. If not specified, it defaults to Present.


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
    Path = [String]
    HostHeader = [String]
    [ CertificateThmubprint = [String] ]
    [ DefaultDomain = [String] ]
    [ CatalogServicesCredential = [PSCredential] ]
    [ CatalogServicesHost = [String] ]
    [ Port = [UInt16] ]
    [ Version = [String] ]
    [ IsLiteralPath = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

### Properties

* **Path**: File path containing the RES ONE Service Store MSIs or the literal path to the installer.
* **HostHeader**: IIS website host header, i.e. http://itstore.lab.local (v9.1 and ealier) or res.lab.local (v10 and later).
* **CertificateThmubprint**: Installed certificate thumbprint to bind to the IIS site (v10 and later).
* **DefaultDomain**: RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier.
* **DefaultDomainName**: RES ONE Service Store default (NetBIOS) domain name (v9.1 and earlier)
* **Port**: IIS website port binding.
* **Version**: RES ONE Service Store component version to be installed, i.e. 8.0.3.0.
* **IsLiteralPath**: Specified path is a literal file reference.
* **Ensure**: Whether the role is to be installed or not. Supported values are Present or Absent. If not specified, it defaults to Present.

ROSSWebPortalConfig
===================

Deploys a RES ONE Service Store IIS web portal configuration file (v10 and later).

### Syntax

```
ROSSWebPortalConfig [String] #ResourceName
{
    DatabaseServer = [String]
    DatabaseName = [String]
    Path = [String]
    [Credential = [PSCredential] ]
    [IdentityBrokerUrl = [String] ]
    [ApplicationUrl = [String] ]
    [ClientId = [String] ]
    [ClientSecret = [PSCredential] ]
    [Ensure = [String] { Absent | Present } ]
}
```

### Properties

* **DatabaseServer**: RES ONE Service Store database server/instance name.
* **DatabaseName**: RES ONE Service Store database name.
* **Path**: RES ONE Service Store web portal configuration file path.
* **Credential**: RES ONE Service Store database Microsoft SQL username/password.
* **IdentityBrokerUrl**: RES ONE Identity Broker Uri.
* **ApplicationUrl**: RES ONE Identity Director Management Portal Application/Callback Uri.
* **ClientId**: RES ONE Identity Broker Client ID.
* **ClientSecret**: "RES ONE Identity Broker Client shared secret.
* **Ensure**: Whether the configuration file is created or not. Supported values are Present or Absent. If not specified, it defaults to Present.

ROIDLab
============

Deploys a single-node RES ONE Identity Director lab server environment with HTTPS.

### Syntax

```
ROIDLab [String] #ResourceName
{
    DatabaseServer = [String]
    Credential = [PSCredential]
    SQLCredential = [PSCredential]
    CatalogServicesCredential = [PSCredential]
    Path = [String]
    Version = [String]
    HostHeader = [String]
    CertificateThumbprint = [String]
    [ DatabaseName = [String] ]
    [ LicensePath = [String] ]
    [ BuildingBlockPath = [String] ]
    [ BuildingBlockCredential = [PSCredential] ]
    [ DeleteBuildingBlock = [Boolean] ]
    [ Ensure = [String] { Absent | Present } ]
}
```

# Versions

## 3.0.0

* Adds v10 support
* Removes mandatory DefaultDomain, CatalogServicesCredential and CatalogServicesHost parametmeters from *ROSSWebPortal* for v9 and v10 cross compatibility.
* Adds CertificateThumbprint parameter to *ROSSManagementPortal* and *ROSSWebPortal* for v9 and v10 cross compatibility.
* Adds *ROSSMobileGateway* resource.
* Adds *ROSSManagementPortalConfig* resource.
