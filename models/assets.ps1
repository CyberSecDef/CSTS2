[CmdletBinding()]param()
begin{
	Class Model_Assets : Model_Table{
		static $tableName = "assets"
		static $ddl = "CREATE TABLE assets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), model VARCHAR (64), firmware VARCHAR (64), hostname VARCHAR (64), ip VARCHAR (16), description BLOB, osKey VARCHAR (256), location VARCHAR (256), operatingSystemId VARCHAR (36) REFERENCES operatingSystems (id), deviceTypeId VARCHAR (36) REFERENCES deviceTypes (id), vendorId VARCHAR (36) REFERENCES vendors (id));";
		static [Model_Assets] $model = $null
		static $columns = @()
		
		[Model_Assets] static Get( ){
			if( [Model_Assets]::model -eq $null){
				[Model_Assets]::model = [Model_Assets]::new( );
			}			
			return [Model_Assets]::model
		}

	}
}
Process{
	
}
End{
	
}