[CmdletBinding()]param()
begin{
	Class Model_Packages : Model_Table{
		static $tableName = "packages"
		static $ddl = "CREATE TABLE packages (id CHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), name VARCHAR (256) NOT NULL, acronym VARCHAR (32) NOT NULL);";
		static [Model_Packages] $model = $null
		static $columns = @()
		
		[Model_Packages] static Get( ){
			if( [Model_Packages]::model -eq $null){
				[Model_Packages]::model = [Model_Packages]::new( );
			}			
			return [Model_Packages]::model
		}
		
		[Object[]] PackageInfo(){
			$query = @"
Select 
    p.id, 
    p.name, 
    p.acronym,
    (select count(*) from xPackagesAssets xpa where xpa.packageId = p.id) as Hardware,
    (select count(*) from xAssetsApplications xaa where xaa.packageId = p.id) as Software,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'ACAS' )) ) as ACAS,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'CKL' )) ) as CKL,
    (select count(*) from xAssetsScans xas where xas.packageId = p.id and xas.scanId in (select id from scans s where s.scanTypeId in ( select id from scanTypes where name = 'SCAP' )) ) as SCAP,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Open' or name='Error') )) as Open,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Reviewed') )) as NotReviewed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Completed' or name = 'False Positive') )) as Completed,
    (select count(*) from findings f where f.id in ( Select findingId from xAssetsFindings xaf where xaf.packageId = p.id and xaf.statusId in ( select id from statuses where name = 'Not Applicable') )) as NotApplicable
from 
	packages p
order by 
	p.acronym
"@
			return [SQL]::Get('packages.dat').query($query).execAssoc()	
		}
		
		[void] delete($packageId){
			$params = @{
				'@packageId' = $packageId;
			}
			$query = "delete from {{{table}}} where packageId = @packageId"
			@('requirements', 'xPackageContacts', 'xFindingsResources', 'xFindingsMitigations', 'xMitigationsMilestones', 'xAssetsFindings', 'xAssetsScans', 'xPackagesAssets', 'xAssetsApplications', 'xAssetRequirements') | % {
				[SQL]::Get( 'packages.dat' ).query( ($query -replace '{{{table}}}', $_) , $params ).execNonQuery()
			}
			$query = "delete from packages where id = @packageId"
			[SQL]::Get( 'packages.dat' ).query( $query , $params ).execNonQuery()			
		}

	}
}
Process{
	
}
End{
	
}