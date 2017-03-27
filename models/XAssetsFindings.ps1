[CmdletBinding()]param()
begin{
	Class Model_XAssetsFindings : Model_Table{
		static $tableName = "XAssetsFindings"
		static $ddl = "CREATE TABLE xAssetsFindings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), comments BLOB, assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, scanId VARCHAR (36) REFERENCES scans (id) NOT NULL, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
		static [Model_XAssetsFindings] $model = $null
		static $columns = @()

		[Model_XAssetsFindings] static Get( ){
			if( [Model_XAssetsFindings]::model -eq $null){
				[Model_XAssetsFindings]::model = [Model_XAssetsFindings]::new( );
			}
			return [Model_XAssetsFindings]::model
		}

	}
}
Process{

}
End{

}
