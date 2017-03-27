[CmdletBinding()]param()
begin{
	Class Model_XFindingsMitigations : Model_Table{
		static $tableName = "XFindingsMitigations"
		static $ddl = "CREATE TABLE xFindingsMitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);";
		static [Model_XFindingsMitigations] $model = $null
		static $columns = @()

		[Model_XFindingsMitigations] static Get( ){
			if( [Model_XFindingsMitigations]::model -eq $null){
				[Model_XFindingsMitigations]::model = [Model_XFindingsMitigations]::new( );
			}
			return [Model_XFindingsMitigations]::model
		}

	}
}
Process{

}
End{

}
