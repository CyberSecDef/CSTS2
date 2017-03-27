[CmdletBinding()]param()
begin{
	Class Model_XMitigationsMilestones : Model_Table{
		static $tableName = "XMitigationsMilestones"
		static $ddl = "CREATE TABLE xMitigationsMilestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), findingId VARCHAR (36) REFERENCES findings (id) NOT NULL, mitigationId VARCHAR (36) REFERENCES mitigations (id) NOT NULL, milestoneId VARCHAR (36) REFERENCES milestones (id) NOT NULL, packageId VARCHAR (36) REFERENCES packages (id) NOT NULL);";
		static [Model_XMitigationsMilestones] $model = $null
		static $columns = @()

		[Model_XMitigationsMilestones] static Get( ){
			if( [Model_XMitigationsMilestones]::model -eq $null){
				[Model_XMitigationsMilestones]::model = [Model_XMitigationsMilestones]::new( );
			}
			return [Model_XMitigationsMilestones]::model
		}

	}
}
Process{

}
End{

}
