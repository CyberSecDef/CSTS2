[CmdletBinding()]param()
begin{
	Class Model_Requirements : Model_Table{
		static $tableName = "Requirements"
		static $ddl = "CREATE TABLE requirements (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), credentialed BOOLEAN, requirementTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
		static [Model_Requirements] $model = $null
		static $columns = @()

		[Model_Requirements] static Get( ){
			if( [Model_Requirements]::model -eq $null){
				[Model_Requirements]::model = [Model_Requirements]::new( );
			}
			return [Model_Requirements]::model
		}

	}
}
Process{

}
End{

}
