[CmdletBinding()]param()
begin{
	Class Model_ScanTypes : Model_Table{
		static $tableName = "scanTypes"
		static $ddl = "CREATE TABLE scanTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
		static [Model_ScanTypes] $model = $null
		static $columns = @()
		
		[Model_ScanTypes] static Get( ){
			if( [Model_ScanTypes]::model -eq $null){
				[Model_ScanTypes]::model = [Model_ScanTypes]::new( );
			}			
			return [Model_ScanTypes]::model
		}

	}
}
Process{
	
}
End{
	
}