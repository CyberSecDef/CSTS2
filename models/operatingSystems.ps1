[CmdletBinding()]param()
begin{
	Class Model_OperatingSystems : Model_Table{
		static $tableName = "operatingSystems"
		static $ddl = "CREATE TABLE operatingSystems (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32), vendorId VARCHAR (36) REFERENCES vendors (id) NOT NULL);";
		static [Model_OperatingSystems]$model = $null;
		static $columns = @()
		
		[Model_OperatingSystems] static Get(  ){
			if( [Model_OperatingSystems]::model -eq $null){
				[Model_OperatingSystems]::model = [Model_OperatingSystems]::new( );
			}
			
			return [Model_OperatingSystems]::model
		}
				
	}
}
Process{
	
}
End{
	
}