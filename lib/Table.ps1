[CmdletBinding()]param()
begin{
	Class Model_Table{
		static $tableName = ""
		static $ddl = "";
		static [Model_Table]$model = $null;
		static $columns = @()
		
		Model_Table(){
			if($this.verifyExists() -ne $true){
				[SQL]::Get('packages.dat').query( $this::ddl ).execNonQuery()				
			}
			
			[SQL]::Get('packages.dat').query( "pragma table_info( $($this::tableName) ); " ).execAssoc() | % { $this::columns += $_.name }
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$($this::tableName)' COLLATE NOCASE;"
			return ( [bool]( ([SQL]::Get( 'packages.dat' ).query( $query ).execSingle()).ct ) )
		}
		
		[Object[]] table(){
			return [SQL]::Get('packages.dat').query("SELECT $( $this::columns -join ', ') from $($this::tableName)").execAssoc()
		}
		
		[Object[]] findBy($pairs){

			$query = "SELECT $( $this::columns -join ', ') from $( $this::tableName ) "
			$query += "where 1=1 "
			
			$params = @{}
			$pairs.keys | % {
				$query += " and $($_) = @$($_) "
				$params.add( "@$($_)" , $pairs.$($_) )
			}
						
			$results = [SQL]::Get('Packages.dat').query($query, $params).ExecAssoc();
			if($results.count -gt 0){
				return $results
			}else{
				return $null
			}

		}
		
		
		[Object[]] findBy($cols,$values){
			$cols = $cols -split 'and'
			if($cols.count -eq $values.count){
				$query = "SELECT $( $this::columns -join ', ') from $( $this::tableName) "
				$query += "where 1=1 "
				$params = @{}
				for($i=0; $i -lt $cols.count -and $i -lt $values.count; $i++){
					$query += " and $($cols[$i]) = @$($cols[$i]) "
					$params.add( "@$($cols[$i])" , $values[$i] )
				}
				
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
		
		[Object[]] create($values){			
			$query = "insert into $( $this::tableName) ( $($values.keys -join ',') ) values ( "
			$query += $( ($values.keys | % { "@$($_)" } ) -join ', ' )
			$query += ")"
			
			$params = @{}
			$values.keys | %{
				$params.Add( "@$($_)", $values[$_])
			}
			
			[SQL]::Get('packages.dat').query($query,$params).execNonQuery()
			
			return ( [SQL]::Get('packages.dat').query(" select $( $this::columns -join ', ') from $( $this::tableName) order by rowid desc limit 1").execAssoc() )
		}
		
		[void] delete($id){
			$query = "delete from $($this::tableName) where id = @id"
			$params = @{"@id" = $id}
			[SQL]::Get('packages.dat').query($query,$params).execNonQuery()
		}
	}
}
Process{
	
}
End{
	
}