[CmdletBinding()]param()
begin{
	Class Model_Milestones : Model_Table{
		static $tableName = "Milestones"
		static $ddl = "CREATE TABLE milestones (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (128), scd DATE, statusId VARCHAR (36) REFERENCES statuses (id) NOT NULL);";
		static [Model_Milestones] $model = $null
		static $columns = @()

		[Model_Milestones] static Get( ){
			if( [Model_Milestones]::model -eq $null){
				[Model_Milestones]::model = [Model_Milestones]::new( );
			}
			return [Model_Milestones]::model
		}

	}
}
Process{

}
End{

}
