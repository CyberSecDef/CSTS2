[CmdletBinding()]param()
begin{
	Class Model_OperatingSystems{
		static $tableName = "operatingSystems"
		static $ddl = "CREATE TABLE operatingSystems (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE, version VARCHAR (32), vendorId VARCHAR (36) REFERENCES operatingSystems (id) NOT NULL);";

		static [Model_OperatingSystems]$Model_OperatingSystems = $null;
		static $columns = [SQL]::Get('packages.dat').query("PRAGMA table_info($([Model_OperatingSystems]::tableName))").execAssoc();
		
		[Model_OperatingSystems] static Get(  ){
			if( [Model_OperatingSystems]::Model_OperatingSystems -eq $null){
				[Model_OperatingSystems]::Model_OperatingSystems = [Model_OperatingSystems]::new( );
			}
			
			return [Model_OperatingSystems]::Model_OperatingSystems
		}
		
		Model_OperatingSystems(){
			$this.verifyExists()
			$this.verifyPopulated()
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$([Model_OperatingSystems]::tableName)' COLLATE NOCASE;"
			# write-host $query
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyPopulated( ){
			if([Utils]::IsBlank( [Model_OperatingSystems]::defaults ) -eq $false){
				$query = "SELECT count(*) as ct FROM $([Model_OperatingSystems]::tableName);"
				# write-host $query
				$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
				return ( [bool]( $results.ct ) )
			}else{
				return $true
			}
		}
		
		[Object[]] table(){
			return [SQL]::Get('packages.dat').query("SELECT id, Name, Version, VendorId from operatingSystems order by Name").execAssoc()
		}
	}
}
Process{
	
}
End{
	
}