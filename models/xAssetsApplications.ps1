[CmdletBinding()]param()
begin{
	Class Model_XAssetsApplications{
		static $tableName = "xAssetsApplications"
		static $ddl = "CREATE TABLE xAssetsApplications ( id            VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ( (lower(hex(randomblob(4) ) ) || '-' || lower(hex(randomblob(2) ) ) || '-4' || substr(lower(hex(randomblob(2) ) ), 2) || '-' || substr('89ab', abs(random() ) % 4 + 1, 1) || substr(lower(hex(randomblob(2) ) ), 2) || '-' || lower(hex(randomblob(6) ) ) ) ), installDate   DATE, applicationId VARCHAR (36) REFERENCES applications (id) NOT NULL, assetId       VARCHAR (36) REFERENCES operatingSystems (id) NOT NULL, packageId     VARCHAR (36) REFERENCES packages (id) );"
		
		static [Model_XAssetsApplications]$Model_XAssetsApplications = $null;
		static $columns = [SQL]::Get('packages.dat').query("PRAGMA table_info($([Model_XAssetsApplications]::tableName))").execAssoc();
		
		[Model_XAssetsApplications] static Get(  ){
			if( [Model_XAssetsApplications]::Model_XAssetsApplications -eq $null){
				[Model_XAssetsApplications]::Model_XAssetsApplications = [Model_XAssetsApplications]::new( );
			}
			
			return [Model_XAssetsApplications]::Model_XAssetsApplications
		}
		
		Model_XAssetsApplications(){
			$this.verifyExists()
		}
		
		[bool] verifyExists(){
			$query = "SELECT count(*) as ct FROM sqlite_master WHERE type='table' AND name='$([Model_XAssetsApplications]::tableName)' COLLATE NOCASE;"
			$results = [SQL]::Get( 'packages.dat' ).query( $query ).execSingle()
			return ( [bool]( $results.ct ) )
		}
				
		[Object[]] findBy($cols,$values){
		
			$cols = $cols -split 'and'
			if($cols.count -eq $values.count){
				$query = "SELECT id, installDate, applicationId, assetId, packageId from xAssetsApplications "
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
		
		[Object[]] Hosts($packageId, $applicationId){
			$query = "SELECT a.id, a.model, a.firmware, a.hostname, a.ip, a.description, a.osKey, a.location from assets a where id in (select assetId from xAssetsApplications where applicationId = @applicationId and packageId = @packageId) order by hostname"
			$params = @{"@applicationId" = $applicationId; "@packageId" = $packageId}
			return [SQL]::Get('packages.dat').query($query,$params).execAssoc();
			
		}
		
		[Object[]] create($installDate, $applicationId, $assetId, $packageId){
			write-host $installDate
			$query = "insert into xAssetsApplications (installDate, applicationId, assetId, packageId) values (@installDate, @applicationId, @assetId, @packageId)"
			if([Utils]::IsBlank($installDate)){
				$installDate = $null
			}else{
				$installDate = $installDate.ToString("yyyy-MM-dd")
			}
			
			$params = @{"@installDate" = $installDate; "@applicationId" = $applicationId; "@assetId" = $assetId; "@packageId" = $packageId }
			[SQL]::Get('packages.dat').query($query,$params).execNonQuery()
			return $this.findBy("InstallDateAndApplicationIdAndAssetIdAndPackageId",@($installDate, $applicationId, $assetId, $packageId))
		}
		
		[void] remove($id){
			$query = "delete from xAssetsApplications where id = @id"
			$params = @{"@id" = $id}
			[SQL]::Get('packages.dat').query($query,$params).execNonQuery()
		}
	}
}
Process{
	
}
End{
	
}