[CmdletBinding()]param()
begin{
	Class ViewModel_PackageManager{
	
		static $name = "ViewModel_PackageManager"
		static $desc = "Verifies package compliance"
		
		$data = @()
		$dataComp = @()
		$isChanged = $false
		
		$tables = @{
			"deviceTypes"            = "CREATE TABLE deviceTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"resources"              = "CREATE TABLE resources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"scanTypes"              = "CREATE TABLE scanTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"statuses"               = "CREATE TABLE statuses (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"vendors"                = "CREATE TABLE vendors (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE);";
			"contacts"               = "CREATE TABLE contacts (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), organization VARCHAR (256) NOT NULL, firstName VARCHAR (64) NOT NULL, lastName VARCHAR (64) NOT NULL, phone VARCHAR (32) NOT NULL, email VARCHAR (256) NOT NULL);";
			"packages"               = "CREATE TABLE packages (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) NOT NULL, acronym VARCHAR (32) NOT NULL);";
			"applications"           = "CREATE TABLE applications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
			"assets"                 = "CREATE TABLE assets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), model VARCHAR (64), firmware VARCHAR (64), hostname VARCHAR (64), ip VARCHAR (16), description BLOB, osKey VARCHAR (256), location VARCHAR (256), operatingSystemId VARCHAR (36) REFERENCES operatingSystems (id), deviceTypeId VARCHAR (36) REFERENCES deviceTypes (id), vendorId VARCHAR (36) REFERENCES vendors (id));";
			"findings"               = "CREATE TABLE findings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), iaControl VARCHAR (16), grpId VARCHAR (128), vulnId VARCHAR (64), ruleId VARCHAR (64), pluginId VRCHAR (32), impact VARCHAR (16), likelihood VARCHAR (16), rawRisk INT, description BLOB, correctiveAction BLOB, riskStatement BLOB, findingTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL);";
			"milestones"             = "CREATE TABLE milestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (128), scd DATE, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL);"
			"mitigations"            = "CREATE TABLE mitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), residualRisk INT, remediated BOOLEAN, mitigation BLOB, comments BLOB);"
			"operatingSystems"       = "CREATE TABLE operatingSystems (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
			"scans"                  = "CREATE TABLE scans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), filename VARCHAR (256));";
			"requirements"           = "CREATE TABLE requirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), credentialed BOOLEAN, requirementTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetsFindings"        = "CREATE TABLE xAssetsFindings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), comments BLOB, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetRequirements"     = "CREATE TABLE xAssetRequirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, requirementId VARCHAR (36) REFERENCES requirements (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetsScans"           = "CREATE TABLE xAssetsScans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanDate DATE, credentialed BOOLEAN, score DOUBLE, filename VARCHAR (256), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xAssetsApplications"    = "CREATE TABLE xAssetsApplications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), installDate DATE, applicationId VARCHAR (36) REFERENCES applications (id) NOT NULL, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xFindingsMitigations"   = "CREATE TABLE xFindingsMitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);"
			"xFindingsResources"     = "CREATE TABLE xFindingsResources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, resourceId VARCHAR (36) REFERENCES resources (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
			"xMitigationsMilestones" = "CREATE TABLE xMitigationsMilestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, milestoneId VARCHAR (36) REFERENCES milestones (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);"
			"xPackageContacts"       = "CREATE TABLE xPackageContacts (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, contactId VARCHAR (36) REFERENCES contacts (id) NOT NULL);";
			"xPackagesAssets"         = "CREATE TABLE xPackagesAssets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL);"
		}
		
		$defaults = @{
			'statuses' = @('Ongoing', 'Completed', 'False Positive', 'Not Applicable', 'Error','Not Reviewed');
			'deviceTypes' = @('Printer', 'Server', 'Workstation', 'Router', 'Switch');
			'resources' = @('ISSO', 'System Administator', 'Database Administrator');
			'scanTypes' = @('ACAS', 'CKL', 'SCAP');
			'vendors' = @('Microsoft', 'Oracle', 'HP', 'Dell');
		}
		
		[void] addPackage($name, $acronym){
			$params = @{
				'@Name' = $name.ToUpper()
				'@Acronym' = $acronym.ToUpper()
			}
			if([Utils]::IsBlank( $params.'@Name') -eq $false -and [Utils]::IsBlank( $params.'@Acronym') -eq $false  ){
				$query = "Insert into packages (name, acronym) values (@Name, @Acronym);"
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery()	
			}
		}
		
		ViewModel_PackageManager(){
			$global:csts.activeModule = $this
		}
		
		[void] pollEvents(){
			if((compare-object -referenceObject ($this.data) -differenceObject ($this.dataComp) ) -ne $null ){
				$this.dataComp = $this.data
				$this.isChanged = $true
			}else{
				$this.isChanged = $false
			}
		}
		
		[void] ExportData($exportType){
			switch( "$([CSTS_Export]::$($exportType))" ){
				{ "$([CSTS_Export]::XLSX)" } {
					$filename = "$($global:csts.execPath)\results\PackageManager_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Prevent Sleep')
				}
			}
		}
		
		[void] Initialize(){
			$this.verifyDatabase();
		}
		
		[object[]] getPackageInfo(){
			$query = @"
Select 
    p.id, 
    p.name, 
    p.acronym,
    (select count(*) from xPackagesAssets xpa where xpa.packageId = p.id) as Hardware,
    (select count(*) from xAssetsApplications xaa where xaa.packageId = p.id) as Software,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'ACAS' )) ) as ACAS,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'CKL' )) ) as CKL,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'SCAP' )) ) as SCAP,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Open' or name='Error') )) as Open,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Reviewed') )) as NotReviewed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Completed' or name = 'False Positive') )) as Completed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Applicable') )) as NotApplicable
from 
	packages p
order by 
	p.acronym
"@
			return [SQL]::Get('packages.dat').query($query).execAssoc()
		}
		
		[void] createTable ( $table ){
			[SQL]::Get( 'packages.dat' ).query( $this.tables[$table] ).execNonQuery()
		}

		[bool] verifyTableExists( $table ){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$table' COLLATE NOCASE;"
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyTablePopulated( $table ){
			$query = "SELECT count(*) as ct FROM $table;"
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[void] populateTable( $table ){
			if($this.defaults.$table -ne $null){
				$this.defaults.$table | %{
					[SQL]::Get( 'packages.dat' ).query( "insert into $($table) (name) values ('$($_)');" ).execNonQuery()	
				}
			}
		}

		[void] deletePkg($packageId){
			$params = @{
				'@packageId' = $packageId;
			}
			$query = "delete from {{{table}}} where packageId = @packageId"
			@('requirements', 'xPackageContacts', 'xFindingsResources', 'xFindingsMitigations', 'xMitigationsMilestones', 'xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
				[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
			}

			[SQL]::Get( 'packages.dat' ).query( "delete from packages where id = @packageId" , $params ).execNonQuery()
			$global:csts.controllers.PackageManager.showPkgMgrDashBoard()
		}
		
		[Object[]] getHostInfo($packageId, $assetId){
			$query = @"
Select 
	a.id, 
	a.model, 
	a.firmware, 
	a.hostname, 
	a.ip, 
	a.description, 
	a.osKey, 
	a.location, 
	a.operatingSystemId, 
	a.deviceTypeId,
	a.vendorId,
	(select name from operatingSystems where id = a.operatingSystemId) as operatingSystem,
	(select name from deviceTypes where id = a.deviceTypeId) as deviceType,
	(select name from vendors where id = a.vendorId) as Vendor
from 
	assets a
where 
	a.id = @assetId
	and a.id in (select assetId from xPackagesAssets where packageId = @packageId)
"@
				$params = @{
					"@assetId" = $assetId
					"@packageId" = $packageId
				}
							
				return ( [SQL]::Get( 'packages.dat' ).query( $query, $params ).execSingle() )
		}
		
		
		[void] removeHost($packageId, $assetId){
			$params = @{
				'@assetId' = $assetId;
				'@packageId' = $packageId;
			}
			

			$query = "delete from {{{table}}} where packageId = @packageId and assetId = @assetId"
			@('xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
				[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
			}

			$params = @{
				'@assetId' = $_.Id;
			}
			[SQL]::Get( 'packages.dat' ).query( "delete from assets where id = @assetId" , $params ).execNonQuery()

		}
		
		[void] removeHosts($hosts){
			$hosts | % {
				$this.removeHost($global:csts.controllers.PackageManager.dataContext.pkgSelItem, $_.Id)
			}

			$global:csts.controllers.PackageManager.showHardware()
		}
		
		[Object[]] getMetadata($h){
			$hostData = [psCustomObject]@{
				'@ip' = [Net]::getIp($h)
				'@hostname' = [Net]::getHostName($h);
				'@operatingSystemId' = "";
				'@osKey' = "";
				'@deviceTypeId' = "";
				'@vendorId' = "";
				'@model' = "";
				'@firmware' = "";
				'@location' = "";
				'@description' = "";
			}
			
			$ping = [Net]::Ping($h)
			if( ($ping.StatusCode -eq 0 -or $ping.StatusCode -eq $null ) -and [Utils]::isBlank($ping.IPV4Address) -eq $false ) {
				try{
					$os = gwmi win32_operatingSystem -computer $h
				}catch{
					$os = [psCustomObject]@{Caption = 'UNKNOWN'; OSArchitecture = 'UNKNOWN'; }
				}
				
				try{
					$hostData.'@firmware' = (gwmi win32_bios -computer $h).version
				}catch{
					$hostData.'@firmware' = ""
				}
				
				try{
					$hostData.'@model' = (gwmi win32_computerSystem -computer $h).model
				}catch{
					$hostData.'@model' = ""
				}
				
				$params = @{"@Name" = $os.Caption; "@Version" = $os.Version}				
				
				$query = "select id from operatingSystems where name = @Name"
				$hostData.'@operatingSystemId' = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
				
				if( [Utils]::IsBlank($hostData.'@operatingSystemId') ){
					$query = "select id from vendors where name = 'Microsoft';"
					$osVendor = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()
					
					$params = @{ '@Name' = $os.Caption; '@Version' = $os.Version; '@Vendor' = $osVendor; } 					
					$query = "insert into operatingSystems (Name, Version, VendorId) values (@Name, @Version, @Vendor)"
					[SQL]::Get( 'packages.dat' ).query( $query,$params ).execNonQuery()

					$params = @{ "@Name" = $os.Caption; "@Version" = $os.Version; }						
					$query = "select id from operatingSystems where name = @Name and version = @version;"
					$hostData.'@operatingSystemId' = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()						
				}
				
				if($os.caption -like '*server*'){
					$query = "select id from deviceTypes where name = 'Server';"
					$hostData.'@deviceTypeId' = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()	
				}else{
					$query = "select id from deviceTypes where name = 'Workstation';"
					$hostData.'@deviceTypeId' = [SQL]::Get( 'packages.dat' ).query( $query ).execOne()	
				}
				
				$compSys = gwmi Win32_ComputerSystem -computer $h
				$vendor = $compSys.Manufacturer
				$params = @{ '@Vendor' = $vendor; }
				$query = "select id from vendors where name = @Vendor;"
				$vid = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
				
				if( [Utils]::IsBlank($vid) ){
					$query = "insert into vendors (name) Values (@Vendor)"
					[SQL]::Get( 'packages.dat' ).query( $query,$params ).execNonQuery()
					$query = "select id from vendors where name = @Vendor;"
					$vid = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
				}
				$hostdata.'@vendorId' = $vid
				
				try{
				
				$remoteReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$h)
					If ($OS.OSArchitecture -eq '64-bit') {
						$value = $remoteReg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DigitalProductId4')
						$hostData.'@osKey' = [Utils]::decodeProductKey($value)
					} ElseIf($OS.OSArchitecture -eq '32-bit') {                        
						$value = $remoteReg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('DigitalProductId')
						$hostData.'@osKey' = [Utils]::decodeProductKey($value)
					}else{
						$hostData.'@osKey' = ""
					}
				}catch{
					$hostData.'@osKey' = ""
				}
			}
			
			return ,$hostData
		}

		[void] reloadMetadata($items){
			$items | % {
			
				$ping = [Net]::Ping($_.hostname)
				if( ($ping.StatusCode -eq 0 -or $ping.StatusCode -eq $null ) -and [Utils]::isBlank($ping.IPV4Address) -eq $false ) {			
					$assetId = $_.Id
					$metaData = $this.getMetaData($_.hostname)
					
					$query = @"
update 
		assets 
	set 
		hostname = @hostname, 
		ip = @ip, 
		model = @model, 
		firmware = @firmWare, 
		osKey = @osKey, 
		description = @description, 
		location = @location, 
		operatingSystemId = @operatingSystemId, 
		deviceTypeId = @deviceTypeId, 
		vendorId = @vendorId
	where
		id = @assetId
"@
					$params = @{
						'@ip' = $metaData.'@ip';
						'@hostname' = $metaData.'@hostname';
						'@model' = $metaData.'@model';
						'@firmware' = $metaData.'@firmware';
						'@osKey' = $metaData.'@osKey';
						'@description' = $metaData.'@description';
						'@location' = $metaData.'@location';
						'@operatingSystemId' = $metaData.'@operatingSystemId';
						'@deviceTypeId' = $metaData.'@deviceTypeId';
						'@vendorId' = $metaData.'@vendorId';
						'@assetId' = $assetId;
					}

					[SQL]::Get( 'packages.dat' ).query( $query, $params).execNonQuery()				
				}
			}
			
			$global:csts.controllers.PackageManager.showHardware()
				
		}
		
		[void] importHosts(){
			$packageId = $global:csts.controllers.PackageManager.dataContext.pkgSelItem
			$hosts = $global:csts.libs.hosts.Get()
			$hosts.keys | sort | % {
				$ip = [Net]::getIp($_)
				$hostname = [Net]::getHostName($_)
				$ping = [Net]::Ping($hostname)
				
				$query = "select id from xPackagesAssets where packageId = @packageId and assetId in (select id from assets where hostname = @hostname) "
				$params = @{
					'@packageId' = $packageId;
					'@hostname' = $hostname;
				}
				
				$exists = [SQL]::Get( 'packages.dat').query( $query, $params).ExecOne()
				
				if($exists.length -eq 0){
					
					$metaData = $this.getMetaData($hostname)
					$query = "insert into assets (hostname, ip, model, firmware, osKey, description, location, operatingSystemId, deviceTypeId, vendorId) values ( @hostname, @ip, @model, @firmware, @osKey, @description, @location, @operatingSystemId, @deviceTypeId, @vendorId)"

					$params = @{
						'@ip' = $ip;
						'@hostname' = $hostname;
						'@model' = $metaData.'@model';
						'@firmware' = $metaData.'@firmware';
						'@osKey' = $metaData.'@osKey';
						'@description' = $metaData.'@description';
						'@location' = $metaData.'@location';
						'@operatingSystemId' = $metaData.'@operatingSystemId';
						'@deviceTypeId' = $metaData.'@deviceTypeId';
						'@vendorId' = $metaData.'@vendorId';
					}

					$assetRowid = [SQL]::Get( 'packages.dat' ).query( $query, $params).execNonQuery()
					
					$params=@{'@rowid' = $assetRowid}
					$assetGuid = [SQL]::Get( 'packages.dat').query( 'select id from assets where rowid = @rowid', $params).ExecOne()
					
					
					$params = @{'@packageId' = $packageId; '@assetId' = $assetGuid;}
					$query = "insert into xPackagesAssets (packageId, assetId) values (@packageId,@assetId)"
					[SQL]::Get( 'packages.dat').query( $query, $params).ExecNonQuery()
				}
			}
			
			$global:csts.controllers.PackageManager.showHardware()
		}

		[Object[]] getPackageSoftware($packageId){
			if(![Utils]::IsBlank($packageId)){
				$query = @"
					select 
						a.id, 
						a.name, 
						a.version, 
						a.vendorId, 
						(select name from vendors where id = a.vendorId) as Vendor
					from 
						applications a
					where
						a.id in (select applicationId from xAssetsApplications where packageId = @PackageId)
					order by 
						trim(lower(a.name))
"@
				$params = @{
					"@PackageId" = $packageId
				}
				return ([SQL]::Get( 'packages.dat' ).query( $query, $params ).execAssoc())
			}else{
				return @()
			}
		}
		
		
		[Object[]] getPackageHardware($packageId){
			if(![Utils]::IsBlank($packageId)){
				$query = @"
					select 
						a.id, 
						a.model, 
						a.firmware, 
						a.hostname, 
						a.ip, 
						a.description, 
						a.osKey, 
						a.location, 
						(select name from operatingSystems where id = a.operatingSystemId) as operatingSystem,
						(select name from deviceTypes where id = a.deviceTypeId) as deviceType,
						(select name from vendors where id = a.vendorId) as Vendor
					from 
						assets a
					where
						a.id in (select assetId from xPackagesAssets where packageId = @PackageId)
					order by 
						trim(lower(a.hostname))
"@
				$params = @{
					"@PackageId" = $packageId
				}
				return ([SQL]::Get( 'packages.dat' ).query( $query, $params ).execAssoc())
			}else{
				return @()
			}
		}
		
		
		[void] verifyDatabase(){
			[Model_DeviceTypes]::Get()
		
			$this.tables.keys | % {
				if(!$this.verifyTableExists($_)){
					
					$this.createTable($_)
				}
				if(!$this.verifyTablePopulated($_) -and $this.defaults.$($_) -ne $null){
					$this.populateTable($_)
				}
			}
		}
		
		[void] updateAssetData($children){
			#if deviceTypeTag is blank...that means a new one was added....add it to the db
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'deviceType').Tag) -eq $true){
				$query = "insert into deviceTypes (name) values (@name);"
				$params = @{ "@name" = [Utils]::ObjHash($children,'deviceType').Text }
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery() 
				
				$query = "select id from deviceTypes where name = @name"
				$params = @{ "@name" = [Utils]::ObjHash($children,'deviceType').Text}
				[Utils]::ObjHash($children,'deviceType').Tag = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
			}
			
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'Manufacturer').Tag) -eq $true){
				$query = "insert into vendors (name) values (@name);"
				$params = @{ "@name" = [Utils]::ObjHash($children,'Manufacturer').Text }
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery() 
				
				$query = "select id from vendors where name = @name"
				$params = @{ "@name" = [Utils]::ObjHash($children,'Manufacturer').Text}
				[Utils]::ObjHash($children,'Manufacturer').Tag = [SQL]::Get( 'packages.dat' ).query( $query, $params ).execOne()
			}
			
			$query = " update assets set model = @model, firmware = @firmware, hostname = @hostname, ip = @ip, description = @description, osKey = @osKey, location = @location, operatingSystemId = @operatingSystemId, deviceTypeId = @deviceTypeId, vendorId = @vendorId where id = @assetId "
 			$params = @{
				"@model" = ([Utils]::ObjHash($children,'Model').Text);
				"@firmware" = ([Utils]::ObjHash($children,'Firmware').Text);
				"@hostname" = ([Utils]::ObjHash($children,'Hostname').Text);
				"@ip" = ([Utils]::ObjHash($children,'IP').Text);
				"@description" = ([Utils]::ObjHash($children,'Description').Text);
				"@osKey" = ([Utils]::ObjHash($children,'osKey').Text);
				"@location" = ([Utils]::ObjHash($children,'Location').Text);
				"@operatingSystemId" = ([Utils]::ObjHash($children,'OS').Tag);
				"@deviceTypeId" = ([Utils]::ObjHash($children,'deviceType').Tag);
				"@vendorId" = ([Utils]::ObjHash($children,'Manufacturer').Tag);
				"@assetId" = $global:csts.controllers.PackageManager.dataContext.assetSelItem.Id;
			}
			
			if([Utils]::IsBlank($global:csts.controllers.PackageManager.dataContext.assetSelItem.Id) -ne $true){
				[SQL]::Get( 'packages.dat' ).query( $query, $params ).execNonQuery()
			}	
		}
		
		[void] getHostSoftware($packageId, $assetId){
			$regPaths = @(
				'Software\Microsoft\Windows\CurrentVersion\Uninstall'
				'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
			)
			$query = "Select id, hostname from assets where id = @assetId and id in (select assetId from xPackagesAssets where packageId = @packageId)"
			$params = @{
				"@assetId" = $assetId;
				"@packageId" = $packageId;
			}
			$asset = [SQL]::Get( 'packages.dat' ).query( $query, $params ).ExecAssoc()
			
			$ping = [Net]::Ping($asset.hostname)
			if( ($ping.StatusCode -eq 0 -or $ping.StatusCode -eq $null ) -and [Utils]::isBlank($ping.IPV4Address) -eq $false ) {
				try{
					$remoteRegistry = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',"$($asset.hostname)")
					$apps = @()

					#delete all applications currently associated with 'this' host
					[Model_XAssetsApplications]::Get().FindBy('assetId', @($assetId)) | % {
						[Model_XAssetsApplications]::Get().Remove($_.id)
					}

					foreach($regPath in $regPaths){
						[System.Windows.Forms.Application]::DoEvents()
						$remoteRegistryKey = $remoteRegistry.OpenSubKey($regPath)
						
						if($remoteRegistryKey -ne $null){
							$remoteSubKeys = $remoteRegistryKey.GetSubKeyNames()
							$remoteSubKeys | % {

								[System.Windows.Forms.Application]::DoEvents()
								$remoteSoftwareKey = $remoteRegistry.OpenSubKey("$regPath\\$_")
								if( $remoteSoftwareKey.GetValue("DisplayName") -and $remoteSoftwareKey.GetValue("UninstallString") ){
									$remReg = @{
										"Name"  		= $remoteSoftwareKey.GetValue("DisplayName") -replace '[^a-zA-Z0-9\- \.]','';
										"Vendor" 		= $remoteSoftwareKey.GetValue("Publisher") ;
										"InstallDate" 	= $remoteSoftwareKey.GetValue("InstallDate") -replace '[^a-zA-Z0-9\- \.]','';
										"Version" 		= $remoteSoftwareKey.GetValue("DisplayVersion") -replace '[^a-zA-Z0-9\- \.]','';
									}
									if( $remReg.name -notlike '*gdr*' -and $remReg.name -notlike '*security*' -and $remReg.name -notlike '*update*' -and $remReg.name -notlike '*driver*' -and $remReg.name -notlike '*runtime*' -and $remReg.name -notlike '*redistributable*' -and $remReg.name -notlike '*framework*'-and $remReg.name -notlike '*hotfix*'  -and $remReg.name -notlike '*plugin*' -and $remReg.name -notlike '*plug-in*' -and $remReg.name -notlike '*debug*' -and $remReg.name -notlike '*addin*' -and $remReg.name -notlike '*add-in*' -and $remReg.name -notlike '*library*' -and $remReg.name -notlike '*add-on*' -and $remReg.name -notlike '*extension*' -and $remReg.name -notlike '*setup*' -and $remReg.name -notlike '*installer*'){
										$apps += $remReg
									}
								}
							}
						}
					}
					
					
					#check for IE
					$remoteRegistryKey = $remoteRegistry.OpenSubKey("SOFTWARE\\Microsoft\\Internet Explorer")
					if($remoteRegistryKey -ne $null){
						$apps += @{
							"Name"  = "Internet Explorer"
							"Vendor" = "Microsoft"
							"InstallDate" = ""
							"Version" = @( $remoteRegistryKey.getValue("svcVersion"),  $remoteRegistryKey.getValue("version") )[ ( $remoteRegistryKey.getValue("version").toString().subString(0,1) -lt 10 ) ]
						}
					}
					
					#check for java
					if( ( test-path "\\$($asset.hostname.Trim())\c`$\Program Files (x86)\Java") -eq $true){
						gci "\\$($asset.hostname.Trim())\c`$\Program Files (x86)\Java" -recurse -include "java.exe" -errorAction silentlyContinue| % {
							$apps += @{
								"Name"  = "Java - 32 Bit"
								"Vendor" = "Oracle"
								"InstallDate" = ""
								"Version" = [system.diagnostics.fileversioninfo]::GetVersionInfo( $_.FullName  ).FileVersion
							}
						}
					}
					#check for java
					if( ( test-path "\\$($asset.hostname.Trim())\c`$\Program Files\Java") -eq $true){
						gci "\\$($asset.hostname.trim())\c`$\Program Files\Java" -recurse -include "java.exe" -errorAction silentlyContinue | % {
							$apps += @{
								"Name"  = "Java - 64 Bit"
								"Vendor" = "Oracle"
								"InstallDate" = ""
								"Version" = [system.diagnostics.fileversioninfo]::GetVersionInfo( $_.FullName  ).FileVersion
							}
						}
					}
					
					
					$apps | % {
						$app = [Model_Applications]::Get().FindBy('NameAndVersion',@( $_.Name, $_.Version ) )
						if([Utils]::IsBlank($app)){
							$query = "select id from vendors where name = @Vendor;"
							$params = @{ '@Vendor' = $_.vendor; }
							$vendorId = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
							if( [Utils]::IsBlank($vendorId) ){
								$query = "insert into vendors (name) Values (@Vendor)"
								[SQL]::Get( 'packages.dat' ).query( $query,$params ).execNonQuery()
								$query = "select id from vendors where name = @Vendor;"
								$vendorId = [SQL]::Get( 'packages.dat' ).query( $query,$params ).execOne()
							}

							$app = [Model_Applications]::Get().create( $_.name, $_.version, $vendorId)
						}
						if(($_.installDate -match "^[1-2][0-9]{3}[0-3][0-9][0-1][0-9]$" )){
							try{
								$installDate = [datetime]::ParseExact($_.InstallDate,"yyyyMMdd",$null)
							}catch{
								$installDate = $null
							}
						}else{
							$installDate = $null
						}
						$install = [Model_XAssetsApplications]::Get().FindBy('InstallDateAndApplicationIdAndAssetIdAndPackageId', @( $InstallDate, $app.id, $assetId, $packageId ))
						if([Utils]::IsBlank($install)){
							[Model_XAssetsApplications]::Get().Create( $InstallDate, $app.id, $assetId, $packageId )
						}
					}
				}catch{
				
				}
			}
		}
	}
}
Process{
	
}
End{
	
}