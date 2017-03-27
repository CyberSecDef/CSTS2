[CmdletBinding()]param()
begin{
	Class Model_Vendors : Model_Table{
		static $tableName = "vendors"
		static $ddl = "CREATE TABLE vendors (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE);";
		static [Model_Vendors] $model = $null
		static $columns = @()
		
		[Model_Vendors] static Get( ){
			if( [Model_Vendors]::model -eq $null){
				[Model_Vendors]::model = [Model_Vendors]::new( );
			}			
			return [Model_Vendors]::model
		}

	}
}
Process{
	
}
End{
	
}