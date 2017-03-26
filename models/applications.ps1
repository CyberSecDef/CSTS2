[CmdletBinding()]param()
begin{
	Class Model_Applications{
		static $tableName = "applications"
		static $ddl = "CREATE TABLE applications ( id       VARCHAR (36)  PRIMARY KEY UNIQUE NOT NULL DEFAULT ( (lower(hex(randomblob(4) ) ) || '-' || lower(hex(randomblob(2) ) ) || '-4' || substr(lower(hex(randomblob(2) ) ), 2) || '-' || substr('89ab', abs(random() ) % 4 + 1, 1) || substr(lower(hex(randomblob(2) ) ), 2) || '-' || lower(hex(randomblob(6) ) ) ) ), name     VARCHAR (256) UNIQUE, version  VARCHAR (32)  NOT NULL, vendorId VARCHAR (36)  REFERENCES vendors (id) NOT NULL );";
		static [Model_Applications]$Model_Applications = $null;
		static $columns = [SQL]::Get('packages.dat').query("PRAGMA table_info($([Model_Applications]::tableName))").execAssoc();
		
		[Model_Applications] static Get(  ){
			if( [Model_Applications]::Model_Applications -eq $null){
				[Model_Applications]::Model_Applications = [Model_Applications]::new( );
			}
			
			return [Model_Applications]::Model_Applications
		}
		
		Model_Applications(){
			$this.verifyExists()
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$([Model_Applications]::tableName)' COLLATE NOCASE;"
			# write-host $query
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
		
		[Object[]] table(){
			return [SQL]::Get('packages.dat').query("SELECT id, Name, Version, vendorId from Applications order by Name").execAssoc()
		}
		
		[Object[]] findBy($cols,$values){
			$cols = $cols -split 'and'
			if($cols.count -eq $values.count){
				$query = "SELECT id, Name, Version, vendorId from Applications "
				$query += "where 1=1 "
				$params = @{}
				for($i=0; $i -lt $cols.count -and $i -lt $values.count; $i++){
					$query += " and $($cols[$i]) = @$($cols[$i]) "
					$params.add( "@$($cols[$i])" , $values[$i] )
				}
				$query += " order by Name"
				
				$results = [SQL]::Get('Packages.dat').query($query, $params).ExecAssoc();
				if($results.count -gt 0){
					return $results
				}else{
					return $null
				}
			}else{
				Throw "Columns and Values Count Mismatch"
				return $null
			}
			
			return $null
		}
		
		[Object[]] create($name, $version, $vendorId){
			$query = "insert into applications (name, version, vendorId) values (@name,@version, @vendorId)"
			$params = @{"@Name" = $name; "@Version" = $version; "@vendorId" = $vendorId }

			[SQL]::Get('packages.dat').query($query,$params).execNonQuery()
			return $this.findBy("NameAndVersionAndVendorID",@($name, $version, $vendorId))
		}
	}
}
Process{
	
}
End{
	
}