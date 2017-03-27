[CmdletBinding()]param()
begin{
	Class Model_XPackageContacts : Model_Table{
		static $tableName = "XPackageContacts"
		static $ddl = "CREATE TABLE xPackageContacts (id VARCHAR (36) PRIMARY KEY UNIQUE NOT NULL DEFAULT ((lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || substr(lower(hex(randomblob(2))), 2) || '-' || substr('89ab', abs(random()) % 4 + 1, 1) || substr(lower(hex(randomblob(2))), 2) || '-' || lower(hex(randomblob(6))))), packageId VARCHAR (36) REFERENCES packages (id) NOT NULL, contactId VARCHAR (36) REFERENCES contacts (id) NOT NULL);";
		static [Model_XPackageContacts] $model = $null
		static $columns = @()

		[Model_XPackageContacts] static Get( ){
			if( [Model_XPackageContacts]::model -eq $null){
				[Model_XPackageContacts]::model = [Model_XPackageContacts]::new( );
			}
			return [Model_XPackageContacts]::model
		}

	}
}
Process{

}
End{

}
