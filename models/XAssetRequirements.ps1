[CmdletBinding()]param()
begin{
	Class Model_XAssetRequirements : Model_Table{
		static $tableName = "XAssetRequirements"
		static $ddl = "CREATE TABLE xAssetRequirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), assetId VARCHAR (36) REFERENCES assets (id) NOT NULL, requirementId VARCHAR (36) REFERENCES requirements (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
		static [Model_XAssetRequirements] $model = $null
		static $columns = @()

		[Model_XAssetRequirements] static Get( ){
			if( [Model_XAssetRequirements]::model -eq $null){
				[Model_XAssetRequirements]::model = [Model_XAssetRequirements]::new( );
			}
			return [Model_XAssetRequirements]::model
		}

	}
}
Process{

}
End{

}
