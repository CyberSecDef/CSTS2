[CmdletBinding()]param()
begin{
	Class Model_Vendors{
		static $tableName = "vendors"
		static $ddl = "CREATE TABLE vendors (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) UNIQUE);";
		static $defaults = @('Microsoft', 'Oracle', 'HP', 'Dell');
		static [Model_Vendors]$Model_Vendors = $null;
		static $columns = [SQL]::Get('packages.dat').query("PRAGMA table_info($([Model_Vendors]::tableName))").execAssoc();
		
		[Model_Vendors] static Get(  ){
			if( [Model_Vendors]::Model_Vendors -eq $null){
				[Model_Vendors]::Model_Vendors = [Model_Vendors]::new( );
			}
			
			return [Model_Vendors]::Model_Vendors
		}
		
		Model_Vendors(){
			$this.verifyExists()
			$this.verifyPopulated()
			$this.populate()
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$([Model_Vendors]::tableName)' COLLATE NOCASE;"
			# write-host $query
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[bool] verifyPopulated( ){
			if([Utils]::IsBlank( [Model_Vendors]::defaults ) -eq $false){
				$query = "SELECT count(*) as ct FROM $([Model_Vendors]::tableName);"
				# write-host $query
				$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
				return ( [bool]( $results.ct ) )
			}else{
				return $true
			}
		}
		
		[void] populate( ){
			if([Model_Vendors]::defaults -ne $null -and $this.verifyPopulated -eq 0){
				[Model_Vendors]::defaults | %{
					[SQL]::Get( 'packages.dat' ).query( "insert into $([Model_Vendors]::tableName) (name) values ('$($_)');" ).execNonQuery()	
				}
			}
		}

		[Object[]] table(){
			return [SQL]::Get('packages.dat').query("SELECT id, Name from vendors order by Name").execAssoc()
		}
	}
}
Process{
	
}
End{
	
}