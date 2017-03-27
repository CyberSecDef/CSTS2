[CmdletBinding()]param()
begin{
	Class Model_XAssetsScans : Model_Table{
		static $tableName = "XAssetsScans"
		static $ddl = "CREATE TABLE xAssetsScans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanDate DATE, credentialed BOOLEAN, score DOUBLE, filename VARCHAR (256), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
		static [Model_XAssetsScans] $model = $null
		static $columns = @()

		[Model_XAssetsScans] static Get( ){
			if( [Model_XAssetsScans]::model -eq $null){
				[Model_XAssetsScans]::model = [Model_XAssetsScans]::new( );
			}
			return [Model_XAssetsScans]::model
		}

	}
}
Process{

}
End{

}
