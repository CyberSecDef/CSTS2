[CmdletBinding()]param()
begin{
	Class Model_Packages : Model_Table{
		static $tableName = "packages"
		static $ddl = "CREATE TABLE packages (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) NOT NULL, acronym VARCHAR (32) NOT NULL);";
		static [Model_Packages] $model = $null
		static $columns = @()
		
		[Model_Packages] static Get( ){
			if( [Model_Packages]::model -eq $null){
				[Model_Packages]::model = [Model_Packages]::new( );
			}			
			return [Model_Packages]::model
		}

	}
}
Process{
	
}
End{
	
}