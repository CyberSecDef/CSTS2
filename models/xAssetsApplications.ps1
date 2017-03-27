[CmdletBinding()]param()
begin{
	Class Model_XAssetsApplications : Model_Table{
		static $tableName = "xAssetsApplications"
		static $ddl = "CREATE TABLE xAssetsApplications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), installDate DATE, applicationId VARCHAR (36) REFERENCES applications (id) NOT NULL, assetId VARCHAR (36) REFERENCES operatingSystems (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));"
		
		static [Model_XAssetsApplications]$model = $null;
		static $columns = @();
		
		[Model_XAssetsApplications] static Get(  ){
			if( [Model_XAssetsApplications]::model -eq $null){
				[Model_XAssetsApplications]::model = [Model_XAssetsApplications]::new( );
			}
			
			return [Model_XAssetsApplications]::model
		}
		
		[Object[]] Hosts($packageId, $applicationId){
			$query = "SELECT a.id, a.model, a.firmware, a.hostname, a.ip, a.description, a.osKey, a.location from assets a where id in (select assetId from xAssetsApplications where applicationId = @applicationId and packageId = @packageId) order by hostname"
			$params = @{"@applicationId" = $applicationId; "@packageId" = $packageId}
			return [SQL]::Get('packages.dat').query($query,$params).execAssoc();	
		}
		
		[Object[]] Applications($packageId, $assetId){
			$query = "SELECT a.id, a.name, a.version, a.vendorId, (select name from vendors where id = a.vendorId) as vendor from applications a where id in (select applicationId from xAssetsApplications where assetId = @assetId and packageId = @packageId) order by name"
			$params = @{"@assetId" = $assetId; "@packageId" = $packageId}
			return [SQL]::Get('packages.dat').query($query,$params).execAssoc();	
		}
		
	}
}
Process{
	
}
End{
	
}