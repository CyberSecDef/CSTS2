[CmdletBinding()]param()
begin{
	Class Model_Mitigations : Model_Table{
		static $tableName = "Mitigations"
		static $ddl = "CREATE TABLE mitigations (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), residualRisk INT, remediated BOOLEAN, mitigation BLOB, comments BLOB);";
		static [Model_Mitigations] $model = $null
		static $columns = @()

		[Model_Mitigations] static Get( ){
			if( [Model_Mitigations]::model -eq $null){
				[Model_Mitigations]::model = [Model_Mitigations]::new( );
			}
			return [Model_Mitigations]::model
		}

	}
}
Process{

}
End{

}
