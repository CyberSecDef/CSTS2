[CmdletBinding()]param()
begin{
	# =========================================================
	#	Class: PackageManager
	#		The class definition for the object that will 
	#		help manage package compliance
	# =========================================================
	Class PackageManager{
	
		# =========================================================	
		#	Properties: Static Properties
		#		name 	- The name of the class
		#		desc 	- A detailed description of the class
		# =========================================================
		static $name = "PackageManager"
		static $desc = "Verifies package compliance"
		
		# =========================================================	
		#	Properties: Public Properties
		#		data 		- The results from the applet invocation
		#		dataComp 	- Used to see if any of the data has 
		#						changed between iterations
		#		isChanged	- Has the data changed
		#		tables		- The SQL Tables this object uses
		#		deaults		- The default data loaded in certain 
		#						tables
		# =========================================================
		$data = @()
		$dataComp = @()
		$isChanged = $false
		
		$tables = @{
			"statuses" = "CREATE TABLE statuses (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"deviceTypes" = "CREATE TABLE deviceTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"resources" = "CREATE TABLE resources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"scanTypes" = "CREATE TABLE scanTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
			"contacts" = "CREATE TABLE contacts (	id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), 	organization VARCHAR (256) NOT NULL, 	firstName VARCHAR (64) NOT NULL, 	lastName VARCHAR (64) NOT NULL, 	phone VARCHAR (32) NOT NULL, 	email VARCHAR (256) NOT NULL	);";
			"packages" = "CREATE TABLE packages (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) NOT NULL, acronym VARCHAR (32) NOT NULL);";
			"vendors" = "CREATE TABLE vendors (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE);";
			"operatingSystems" = "CREATE TABLE operatingSystems ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR(32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL ); ";
			"applications" = "CREATE TABLE applications ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR(32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL );";
			"scans" = "CREATE TABLE scans ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, name VARCHAR (256) UNIQUE, version VARCHAR(16), release VARCHAR(16) );";
			"requirements" = "CREATE TABLE requirements ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), requirementTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, name VARCHAR (256) UNIQUE, version VARCHAR(16), release VARCHAR(16), credentialed BOOLEAN );";
			"findings" = "CREATE TABLE findings ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), iaControl VARCHAR(16), grpId VARCHAR(128), vulnId VARCHAR(64), ruleId VARCHAR(64), pluginId VRCHAR(32), impact VARCHAR(16), likelihood VARCHAR(16), scd VARCHAR(128), milestones VARCHAR(128), rawRisk INT, residualRisk INT, description BLOB, correctiveAction BLOB, riskStatement BLOB, mitigation BLOB, remediation BLOB, comments BLOB, findingTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, statusId VARCHAR(36) REFERENCES statuses (id) NOT NULL );	";
			"assets" = "CREATE TABLE assets ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), model VARCHAR(64), firmware VARCHAR(64), hostname VARCHAR(64), fqdn VARCHAR(256), ip VARCHAR(16), description BLOB, osKey VARCHAR(256), location VARCHAR(256), operatingSystem VARCHAR (36) REFERENCES operatingSystems (id) NOT NULL, deviceTypeId VARCHAR (36) REFERENCES deviceTypes (id) NOT NULL, vendorId VARCHAR(36) REFERENCES vendors (id) NOT NULL );";
			"xPackageContacts" = "CREATE TABLE xPackageContacts ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, contactId VARCHAR (36) REFERENCES contacts (id) NOT NULL );";
			"xAssetsFindings" = "CREATE TABLE xAssetsFindings ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), comments BLOB, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL );	";
			"xAssetRequirements" = "CREATE TABLE xAssetRequirements ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, requirementId VARCHAR (36) REFERENCES requirements (id) NOT NULL );	";
			"xAssetsScans" = "CREATE TABLE xAssetsScans ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanDate DATE, credentialed BOOLEAN, score DOUBLE, filename VARCHAR(256), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL );	";
			"xAssetsApplications" = "CREATE TABLE xAssetsApplications ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), installDate DATE, applicationId VARCHAR (36) REFERENCES applications (id) NOT NULL, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL );	";
			"xFindingsResources" = "CREATE TABLE xFindingsResources ( id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, resourceId VARCHAR (36) REFERENCES resources (id) NOT NULL );	";
		}
		
		$defaults = @{
			'statuses' = @('Ongoing', 'Completed', 'False Positive', 'Not Applicable', 'Error');
			'deviceTypes' = @('Printer', 'Server', 'Workstation', 'Router', 'Switch');
			'resources' = @('ISSO', 'System Administator', 'Database Administrator');
			'scanTypes' = @('ACAS', 'CKL', 'SCAP');
			'vendors' = @('Microsoft', 'Oracle', 'HP', 'Dell');
		}
		
		
		
		
		
		
		
		
		
		
		
		# =========================================================		
		#	Constructor: PreventSleep
		#		Creates the PreventSleep applet and updates the 
		#		active module in the CSTS
		# =========================================================
		PackageManager(){
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
		
		# =========================================================
		#	Method: ExportData
		#		Exports the Package Manager
		#
		# 	Parameters:
		# 		exportType - The type of export to perform
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<Test>
		# =========================================================
		[void] ExportData($exportType){
			switch( "$([CSTS_Export]::$($exportType))" ){
				{ "$([CSTS_Export]::XLSX)" } {
					$filename = "$($global:csts.execPath)\results\PackageManager_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Prevent Sleep')
				}
			}
		}
				
		
		
		# =========================================================
		# 	Method: Initialize
		# 		Intiailizes the package manager
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<InvokePreventSleep>
		# =========================================================
		[void] Initialize(){
			$this.verifyDatabase();
			write-host 'test'
		}
		
		
		[void] createTable ( $table ){
			[GUI]::Get().showModal("Creating table $table")
			[SQL]::Get( $global:csts.db ).query( $this.tables.$table ).execNonQuery()
		}

		[bool] verifyTableExists( $table ){
			$sql = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$table' COLLATE NOCASE;"
			$results = [SQL]::Get( $global:csts.db ).query( $sql ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyTablePopulated( $table ){
			$sql = "SELECT count(*) as ct FROM $table;"
			$results = [SQL]::Get( $global:csts.db ).query( $sql ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[void] populateTable( $table ){
			[GUI]::Get().showModal("Populating table $table")
			if($this.defaults.$table -ne $null){
				$this.defaults.$table | %{
					[SQL]::Get( $global:csts.db ).query( "insert into $($table) (name) values ('$($_)');" ).execNonQuery()	
				}
			}
		}
		
		[void] verifyDatabase(){
			$this.tables.keys | % {
				if(!$this.verifyTableExists($_)){
					[GUI]::Get().showModal('Creating Tables')
					$this.createTable($_)
				}
				if(!$this.verifyTablePopulated($_) -and $this.defaults.$($_) -ne $null){
					[GUI]::Get().showModal('Populating Tables')
					$this.populateTable($_)
				}
			}
			[GUI]::Get().hideModal()
		}
		
		
	}
}
Process{
	
}
End{
	
}