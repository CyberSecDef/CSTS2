[CmdletBinding()]param()
begin{
	Class Model_Resources : Model_Table{
		static $tableName = "resources"
		static $ddl = "CREATE TABLE resources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
		static [Model_Resources] $model = $null
		static $columns = @()
		
		[Model_Resources] static Get( ){
			if( [Model_Resources]::model -eq $null){
				[Model_Resources]::model = [Model_Resources]::new( );
			}			
			return [Model_Resources]::model
		}

	}
}
Process{
	
}
End{
	
}