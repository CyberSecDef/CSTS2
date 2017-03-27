[CmdletBinding()]param()
begin{
	
	Class SQL{
		static [SQL] $db = $null;
		$dbConnection = $null;
		$dbCommand = $null;
		
		SQL(){
		
		}
		
		__($methodName, $parameters){
			write-host "$($methodName) was called with parameters: $($parameters)"
		}
		
		SQL( $sqlFile ){
			$this.dbConnection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
			
			$this.dbConnection.ConnectionString = "Data Source=$($sqlFile)"
			$this.dbConnection.open()
		}
		
		[SQL] static Get( $sqlFile ){
			if( [SQL]::db -eq $null){
				[SQL]::db = [SQL]::new( "$($global:csts.execPath)\db\$($sqlFile)");
			}else{
				if( [SQL]::db.dbConnection.state -ne 'Open'){
					[SQL]::db.dbConnection.open()
				}
			}
			
			$pragma = New-Object -TypeName System.Data.SQLite.SQLiteCommand
			$pragma.Connection = [SQL]::db.dbConnection
			$pragma.CommandText = "pragma journal_mode = TRUNCATE"
			$pragma.ExecuteNonQuery()
			
			return [SQL]::db
		}

		[SQL] query( $sql){
		
			$this.dbCommand = New-Object -TypeName System.Data.SQLite.SQLiteCommand
			$this.dbCommand.Connection = $this.dbConnection
			$this.dbCommand.CommandText = $sql

			return $this
		}
		
		[SQL] query( $sql, $parms){
			# write-host $sql
			
			$this.dbCommand = New-Object -TypeName System.Data.SQLite.SQLiteCommand
			$this.dbCommand.Connection = $this.dbConnection
			$this.dbCommand.CommandText = $sql
			if($parms -ne $null){
				foreach($par in ($parms.getEnumerator() ) ){

					$this.dbCommand.Parameters.Add(  ( new-object -TypeName System.Data.SQLite.SQLiteParameter( "$($par.name)", ($par.value)  ) ) ) | out-null

				}
				$this.dbCommand.prepare()
			}
			return $this
		}
		
		[Object[]] execSingle(){
			$dbReader = $this.dbCommand.executeReader()

			$row = @{}
			for($f=0; $f -lt $dbReader.fieldCount; $f++){
				$row.$($dbReader.getName($f)) = $dbReader.getValue($f)
			}
				
			
			$dbReader.close()
			return $row
		}
		
		[String] execOne(){
			$dbReader = $this.dbCommand.executeReader()
			$val = [String]($dbReader.getValue(0))
			$dbReader.close()
			return $val
		}
		
		[Object[]] execAssoc(){
			$dbReader = $this.dbCommand.executeReader()
			$results = @()
		
			while ($dbReader.Read()){
				$row = @{}
				for($f=0; $f -lt $dbReader.fieldCount; $f++){
					$row.$($dbReader.getName($f)) = $dbReader.getValue($f)
				}
				$results +=  $row
			}
			$dbReader.close()
			return $results
		}
	
		[Int] execNonQuery(){				
			$this.dbCommand.ExecuteNonQuery()
			$rowid = $this.query('select last_insert_rowid() as id').execOne() 
			
			if( $rowid -ne $null){
				return ($rowid)
			}else{
				return 0
			}			
		}
		
		[SQL] close(){		
			$this.dbConnection.close()
			return $this
		}
	}
}
Process{
	$global:csts.libs.add('SQL', ([SQL]::new()) ) | out-null
}
End{

}