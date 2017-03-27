[CmdletBinding()]param()
begin{
	Class Model_Contacts : Model_Table{
		static $tableName = "contacts"
		static $ddl = "CREATE TABLE contacts (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), organization VARCHAR (256) NOT NULL, firstName VARCHAR (64) NOT NULL, lastName VARCHAR (64) NOT NULL, phone VARCHAR (32) NOT NULL, email VARCHAR (256) NOT NULL);";
		static [Model_Contacts] $model = $null
		static $columns = @()
		
		[Model_Contacts] static Get( ){
			if( [Model_Contacts]::model -eq $null){
				[Model_Contacts]::model = [Model_Contacts]::new( );
			}			
			return [Model_Contacts]::model
		}

	}
}
Process{
	
}
End{
	
}