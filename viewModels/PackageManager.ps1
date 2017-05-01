[CmdletBinding()]param()
begin{
	Class ViewModel_PackageManager{
		static $name = "ViewModel_PackageManager"
		static $desc = "Verifies package compliance"
		
		$data = @()
		$dataComp = @()
		$isChanged = $false
		
		[void] Initialize(){

		}
		
		ViewModel_PackageManager(){
			$global:csts.activeModule = $this
		}
		
		[void] addPackage($name, $acronym){
			$params = @{
				'@Name' = $name.ToUpper()
				'@Acronym' = $acronym.ToUpper()
			}
			if([Utils]::IsBlank( $params.'@Name') -eq $false -and [Utils]::IsBlank( $params.'@Acronym') -eq $false  ){
				[Model_Packages]::Get().create( @{ "name" = $name.ToUpper(); "Acronym" = $acronym.ToUpper() } )	
			}
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
		
		[object[]] getPackageInfo(){
			return [Model_Packages]::Get().PackageInfo()
		}
		
		
		[void] deletePkg($packageId){
			[Model_Packages]::Get().Delete($packageId);
			$global:csts.controllers.PackageManager.showPkgMgrDashBoard()
		}
		
		[Object[]] getHostInfo($packageId, $assetId){
			return [Model_Assets]::Get().Info($packageId,$assetId)
		}
		
		
		[void] removeHost($packageId, $assetId){
			[Model_Assets]::Get().Delete($packageId, $assetId)
		}
		
		[void] removeHosts($hosts){
			$hosts | % {
				$this.removeHost($global:csts.controllers.PackageManager.dataContext.pkgSelItem, $_.Id)
			}
			$global:csts.controllers.PackageManager.showHardware()
		}
		
		[void] removeApp($packageId, $applicationId){
			[Model_XAssetsApplications]::Get().removeApp($packageId, $applicationId)
		}

		[void] removeSoftware($packageId, $applications){
			$applications | % {
				$this.removeApp($packageId, $_.Id)
			}
			$global:csts.controllers.PackageManager.ShowSoftware()
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
				
				$osCaption = ( [Model_OperatingSystems]::Get().FindBy(@{"Name" = $os.Caption}) )
				if( [Utils]::IsBlank( $osCaption ) ){
					$osVendor = [Model_Vendors]::Get().findBy(@{ "name" = "Microsoft";} )
					$hostData.'@operatingSystemId' = [Model_OperatingSystems]::Get().create( @{ "name" = $os.caption; "version" = $os.version; "vendorId" = $osVendor } )[0].id					
				}else{
					$hostData.'@operatingSystemId' = [Model_OperatingSystems]::Get().FindBy(@{"Name" = $os.Caption})[0].id
				}
				
				if($os.caption -like '*server*'){
					$hostData.'@deviceTypeId' = [Model_DeviceTypes]::Get().findBy( @{"name" = "Server";} )[0].id
				}else{
					$hostData.'@deviceTypeId' = [Model_DeviceTypes]::Get().findBy( @{"name" = "Workstation";} )[0].id
				}
				
				$compSys = gwmi Win32_ComputerSystem -computer $h
				$vendor = $compSys.Manufacturer
				
				$vid = [Model_Vendors]::Get().FindBy( @{ "name" = $vendor } )
				if( $vid.count -eq 0 ){
					[Model_Vendors]::Get().create( @{ "name" = $vendor } )
					$vid = [Model_Vendors]::Get().FindBy( @{ "name" = $vendor } )
				}
				$hostdata.'@vendorId' = $vid[0].id
				
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
					$asset = [Model_Assets]::Get().create(
						@{
							'ip' = $ip;
							'hostname' = $hostname;
							'model' = $metaData.'@model';
							'firmware' = $metaData.'@firmware';
							'osKey' = $metaData.'@osKey';
							'description' = $metaData.'@description';
							'location' = $metaData.'@location';
							'operatingSystemId' = $metaData.'@operatingSystemId';
							'deviceTypeId' = $metaData.'@deviceTypeId';
							'vendorId' = $metaData.'@vendorId';
						}
					)
					
					[Model_XPackagesAssets]::Get().create( @{ "packageId" = $packageId; "assetId" = $asset.id } )
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
		
		[void] updateAssetData($children){
			#if deviceTypeTag is blank...that means a new one was added....add it to the db
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'deviceType').Tag) -eq $true){
				[Utils]::ObjHash($children,'deviceType').Tag = [Model_DeviceTypes]::Get().Create( @{ "name" = [Utils]::ObjHash($children,'deviceType').Text } )[0].id
			}
			
			if( [Utils]::IsBlank([Utils]::ObjHash($children,'Manufacturer').Tag) -eq $true){
				$vendor = [Model_Vendors]::Get().findBy( @{ "name" = [Utils]::ObjHash($children,'Manufacturer').Text } )
				if($vendor.ct -eq 0){
					$vendor = [Model_Vendors]::Get().create( @{ "name" = [Utils]::ObjHash($children,'Manufacturer').Text } )
				}
				[Utils]::ObjHash($children,'Manufacturer').Tag = $vendor[0].name
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

					$existing = [Model_XAssetsApplications]::Get().FindBy( @{'assetId' = $assetId } )
					#delete all applications currently associated with 'this' host
					$i = 0
					$total = $existing.total + 1

					$existing | % {
						$i++
						[GUI]::Get().showModal( @( [pscustomobject]@{ Type="Progress"; Text = "Deleting Existing Software on $($asset.hostname.trim())"; Progress = $($i/$total*33) } ), "Deleting Software" )
						[Model_XAssetsApplications]::Get().Delete($_.id)
					}
	
					$i = 0
					$total = $regPaths.count+1
					foreach($regPath in $regPaths){
						$i++
						[GUI]::Get().showModal( @( [pscustomobject]@{ Type="Progress"; Text = "Retrieving Software on $($asset.hostname.trim())"; Progress = $($i/$total*33 + 33) } ), "Retrieving Software" )
					
						[System.Windows.Forms.Application]::DoEvents()
						$remoteRegistryKey = $remoteRegistry.OpenSubKey($regPath)
						
						if($remoteRegistryKey -ne $null){
							$remoteSubKeys = $remoteRegistryKey.GetSubKeyNames()
							$remoteSubKeys | % {

								[System.Windows.Forms.Application]::DoEvents()
								$remoteSoftwareKey = $remoteRegistry.OpenSubKey("$regPath\\$_")
								if( $remoteSoftwareKey.GetValue("DisplayName") -and $remoteSoftwareKey.GetValue("UninstallString") ){
									$_ = @{
										"Name"  		= $remoteSoftwareKey.GetValue("DisplayName") -replace '[^a-zA-Z0-9\- \.]','';
										"Vendor" 		= $remoteSoftwareKey.GetValue("Publisher") ;
										"InstallDate" 	= $remoteSoftwareKey.GetValue("InstallDate") -replace '[^a-zA-Z0-9\- \.]','';
										"Version" 		= $remoteSoftwareKey.GetValue("DisplayVersion") -replace '[^a-zA-Z0-9\- \.]','';
									}
									if( $_.name -notlike '*gdr*' -and $_.name -notlike '*compiler*' -and $_.name -notlike '*tool*' -and $_.name -notlike '*sdk*' -and $_.name -notlike '*security*' -and $_.name -notlike '*update*' -and $_.name -notlike '*driver*' -and $_.name -notlike '*runtime*' -and $_.name -notlike '*redistributable*' -and $_.name -notlike '*framework*'-and $_.name -notlike '*hotfix*'  -and $_.name -notlike '*plugin*' -and $_.name -notlike '*plug-in*' -and $_.name -notlike '*debug*' -and $_.name -notlike '*addin*' -and $_.name -notlike '*add-in*' -and $_.name -notlike '*library*' -and $_.name -notlike '*add-on*' -and $_.name -notlike '*extension*' -and $_.name -notlike '*setup*' -and $_.name -notlike '*installer*'){
										$apps += $_
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
					
					
					$i = 0
					$total = $apps.count + 1
					$apps | % {
						$i ++
						
						[GUI]::Get().showModal( @( [pscustomobject]@{ Type="Progress"; Text = "Storing Software on $($asset.hostname.trim())"; Progress = $( $i/$total*33 + 66) } ), "Storing Results" )
					
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

							$app = [Model_Applications]::Get().create( @{ "name" = $_.name; "version" = $_.version; "vendorId" = $vendorId } )
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
						$install = [Model_XAssetsApplications]::Get().FindBy( @{ "InstallDate" = $installDate; "applicationId" = $app.id; "assetId" = $assetId; "packageId" = $packageId } )
						if([Utils]::IsBlank($install)){
							[Model_XAssetsApplications]::Get().Create( @{ "InstallDate" = $InstallDate; "applicationId" = $app.id; "assetId" = $assetId; "packageId" = $packageId } )
						}

					}
					[GUI]::Get().hideModal()
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