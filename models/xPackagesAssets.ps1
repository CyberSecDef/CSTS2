[CmdletBinding()]param()
begin{
	Class Model_XPackagesAssets : Model_Table{
		static $tableName = "xPackagesAssets"
		static $ddl = "CREATE TABLE xPackagesAssets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, assetId VARCHAR (36) REFERENCES operatingSystems (id) NOT NULL);"
		static [Model_XPackagesAssets]$model = $null;
		static $columns = @();
		
		[Model_XPackagesAssets] static Get(  ){
			if( [Model_XPackagesAssets]::model -eq $null){
				[Model_XPackagesAssets]::model = [Model_XPackagesAssets]::new( );
			}
			
			return [Model_XPackagesAssets]::model
		}
		
		
	}
}
Process{
	
}
End{
	
}