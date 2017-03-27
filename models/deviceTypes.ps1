[CmdletBinding()]param()
begin{
	Class Model_DeviceTypes : Model_Table {
		static $tableName = "deviceTypes"
		static $ddl = "CREATE TABLE deviceTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
		static [Model_DeviceTypes] $model = $null
		static $columns = @()
		
		[Model_DeviceTypes] static Get(  ){
			if( [Model_DeviceTypes]::model -eq $null){
				[Model_DeviceTypes]::model = [Model_DeviceTypes]::new( );
			}
			
			return [Model_DeviceTypes]::model
		}

	}
}
Process{
	
}
End{
	
}