[CmdletBinding()]param()
begin{
	Class Model_DeviceTypes{
		static $tableName = "deviceTypes"
		static $ddl = "CREATE TABLE deviceTypes (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (32) UNIQUE);";
		static $defaults = @('Printer', 'Server', 'Workstation', 'Router', 'Switch');
		static [Model_DeviceTypes]$Model_DeviceTypes = $null;
		static $columns = [SQL]::Get('packages.dat').query("PRAGMA table_info($([Model_DeviceTypes]::tableName))").execAssoc();
		
		[Model_DeviceTypes] static Get(  ){
			if( [Model_DeviceTypes]::Model_DeviceTypes -eq $null){
				[Model_DeviceTypes]::Model_DeviceTypes = [Model_DeviceTypes]::new( );
			}
			
			return [Model_DeviceTypes]::Model_DeviceTypes
		}
		
		Model_DeviceTypes(){
			$this.verifyExists()
			$this.verifyPopulated()
			$this.populate()
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$([Model_DeviceTypes]::tableName)' COLLATE NOCASE;"
			# write-host $query
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyPopulated( ){
			if([Utils]::IsBlank( [Model_DeviceTypes]::defaults ) -eq $false){
				$query = "SELECT count(*) as ct FROM $([Model_DeviceTypes]::tableName);"
				# write-host $query
				$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
				return ( [bool]( $results.ct ) )
			}else{
				return $true
			}
		}
		
		[void] populate( ){
			if([Model_DeviceTypes]::defaults -ne $null -and $this.verifyPopulated -eq 0){
				[Model_DeviceTypes]::defaults | %{
					[SQL]::Get( 'packages.dat' ).query( "insert into $([Model_DeviceTypes]::tableName) (name) values ('$($_)');" ).execNonQuery()	
				}
			}
		}

		[Object[]] table(){
			return [SQL]::Get('packages.dat').query("SELECT id, Name from deviceTypes order by Name").execAssoc()
		}
	}
}
Process{
	
}
End{
	
}