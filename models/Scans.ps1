[CmdletBinding()]param()
begin{
	Class Model_Scans : Model_Table{
		static $tableName = "Scans"
		static $ddl = "CREATE TABLE scans (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), scanTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL, name VARCHAR (256) UNIQUE, version VARCHAR (16), release VARCHAR (16), filename VARCHAR (256));";
		static [Model_Scans] $model = $null
		static $columns = @()

		[Model_Scans] static Get( ){
			if( [Model_Scans]::model -eq $null){
				[Model_Scans]::model = [Model_Scans]::new( );
			}
			return [Model_Scans]::model
		}

	}
}
Process{

}
End{

}
