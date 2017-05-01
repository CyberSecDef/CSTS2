[CmdletBinding()]param()
begin{
	Class Model_Assets : Model_Table{
		static $tableName = "assets"
		static $ddl = "CREATE TABLE assets (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), model VARCHAR (64), firmware VARCHAR (64), hostname VARCHAR (64), ip VARCHAR (16), description BLOB, osKey VARCHAR (256), location VARCHAR (256), operatingSystemId VARCHAR (36) REFERENCES operatingSystems (id), deviceTypeId VARCHAR (36) REFERENCES deviceTypes (id), vendorId VARCHAR (36) REFERENCES vendors (id));";
		static [Model_Assets] $model = $null
		static $columns = @()
		
		[Model_Assets] static Get( ){
			if( [Model_Assets]::model -eq $null){
				[Model_Assets]::model = [Model_Assets]::new( );
			}			
			return [Model_Assets]::model
		}
		
		[Object[]] info( $packageId, $assetId ){
		$query = @"
Select 
	a.id, 
	a.model, 
	a.firmware, 
	a.hostname, 
	a.ip, 
	a.description, 
	a.osKey, 
	a.location, 
	a.operatingSystemId, 
	a.deviceTypeId,
	a.vendorId,
	(select name from operatingSystems where id = a.operatingSystemId) as operatingSystem,
	(select name from deviceTypes where id = a.deviceTypeId) as deviceType,
	(select name from vendors where id = a.vendorId) as Vendor
from 
	assets a
where 
	a.id = @assetId
	and a.id in (select assetId from xPackagesAssets where packageId = @packageId)
"@
				$params = @{
					"@assetId" = $assetId
					"@packageId" = $packageId
				}
							
			return ( [SQL]::Get( 'packages.dat' ).query( $query, $params ).execSingle() )
		}
		
		[void] delete($packageId, $assetId){
			$params = @{
				'@assetId' = $assetId;
				'@packageId' = $packageId;
			}

			$query = "delete from {{{table}}} where packageId = @packageId and assetId = @assetId"
			@('xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
				[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
			}
			
			$query = "select count(id) from xPackagesAssets where assetId = @assetId"
			$params = @{ "@assetId" = $assetId }			
			$assetFound = [SQL]::Get( 'packages.dat' ).query( $query , $params ).execSingle()
			if($assetFound -eq 0){
				$query = "delete from assets where assetId = @assetId"
				$params = @{ "@assetId" = $assetId }			
				[SQL]::Get( 'packages.dat' ).query( $query , $params ).execNonQuery()
			}
			
			
		}

	}
}
Process{
	
}
End{
	
}