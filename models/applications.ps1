[CmdletBinding()]param()
begin{
	Class Model_Applications : Model_Table{
		static $tableName = "applications"
		static $ddl = "CREATE TABLE applications (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256), version VARCHAR (32) NOT NULL, vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
		static [Model_Applications] $model = $null
		static $columns = @()
		
		[Model_Applications] static Get(  ){
			if( [Model_Applications]::model -eq $null){
				[Model_Applications]::model = [Model_Applications]::new( );
			}
			
			return [Model_Applications]::model
		}
		
	}
}
Process{
	
}
End{
	
}