[CmdletBinding()]param()
begin{
	Class Model_Statuses : Model_Table{
		static $tableName = "statuses"
		static $ddl = "CREATE TABLE statuses (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
		static [Model_Statuses] $model = $null
		static $columns = @()
		
		[Model_Statuses] static Get( ){
			if( [Model_Statuses]::model -eq $null){
				[Model_Statuses]::model = [Model_Statuses]::new( );
			}			
			return [Model_Statuses]::model
		}

	}
}
Process{
	
}
End{
	
}