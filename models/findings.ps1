[CmdletBinding()]param()
begin{
	Class Model_Findings : Model_Table{
		static $tableName = "findings"
		static $ddl = "CREATE TABLE findings (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), iaControl VARCHAR (16), grpId VARCHAR (128), vulnId VARCHAR (64), ruleId VARCHAR (64), pluginId VRCHAR (32), impact VARCHAR (16), likelihood VARCHAR (16), rawRisk INT, description BLOB, correctiveAction BLOB, riskStatement BLOB, findingTypeId VARCHAR (36) REFERENCES scanTypes (id) NOT NULL);";
		static [Model_Findings] $model = $null
		static $columns = @()
		
		[Model_Findings] static Get( ){
			if( [Model_Findings]::model -eq $null){
				[Model_Findings]::model = [Model_Findings]::new( );
			}			
			return [Model_Findings]::model
		}

	}
}
Process{
	
}
End{
	
}