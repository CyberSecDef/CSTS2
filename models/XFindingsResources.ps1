[CmdletBinding()]param()
begin{
	Class Model_XFindingsResources : Model_Table{
		static $tableName = "XFindingsResources"
		static $ddl = "CREATE TABLE xFindingsResources (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, resourceId VARCHAR (36) REFERENCES resources (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id));";
		static [Model_XFindingsResources] $model = $null
		static $columns = @()

		[Model_XFindingsResources] static Get( ){
			if( [Model_XFindingsResources]::model -eq $null){
				[Model_XFindingsResources]::model = [Model_XFindingsResources]::new( );
			}
			return [Model_XFindingsResources]::model
		}

	}
}
Process{

}
End{

}
