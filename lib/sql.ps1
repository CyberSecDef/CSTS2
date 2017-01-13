[CmdletBinding()]param()
begin{
	Class SQL{
		static [SQL] $db = $null;
		$dbConnection = $null;
		$dbCommand = $null;
		
		SQL(){
		
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
			return [SQL]::db
		}

		[SQL] query( $sql){
			$this.dbCommand = New-Object -TypeName System.Data.SQLite.SQLiteCommand
			$this.dbCommand.Connection = $this.dbConnection
			$this.dbCommand.CommandText = $sql

			return $this
		}
		
		[SQL] query( $sql, $parms){
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
	
		[void] execNonQuery(){			
			$this.dbCommand.ExecuteNonQuery()
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