[CmdletBinding()]param()
begin{
	# =========================================================
	#	Class: FindDormant
	#		The class definition for the object that will 
	#		update the sleep settings on computers
	# =========================================================
	Class FindDormant{
	
		# =========================================================	
		#	Properties: Static Properties
		#		name 	- The name of the class
		#		desc 	- A detailed description of the class
		# =========================================================
		static $name = "FindDormant"
		static $desc = "Finds dormant accounts"
		
		# =========================================================	
		#	Properties: Public Properties
		#		data 		- The results from the applet invocation
		#		dataComp 	- Used to see if any of the data has 
		#						changed between iterations
		#		isChanged	- Has the data changed
		# =========================================================
		$data = @()
		$dataComp = @()
		$isChanged = $false
		
		# =========================================================		
		#	Constructor: FindDormant
		#		Creates the FindDormant applet and updates the 
		#		active module in the CSTS
		# =========================================================
		FindDormant(){
			$global:csts.activeModule = $this
		}
		
		# =========================================================
		# 	Method: __
		# 		Magic Method overide like PHP's __call
		#
		# 	Parameters:
		# 		$methodName - The 'name' of the method to call
		#		$parameters - The Parameters to pass to the method
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<>
		# =========================================================
		__($methodName, $parameters){
			write-host "$($methodName) was called with parameters: $($parameters)"
		}
		
		# =========================================================
		# 	Method: pollEvents
		# 		Since there are no events binded like in C#, this is 
		#		called every 1 second to poll for changes. 
		#		Currently sets a flag as to whether or not data changed
		#
		# 	Parameters:
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<>
		# =========================================================
		[void] pollEvents(){
			if((compare-object -referenceObject ($this.data) -differenceObject ($this.dataComp) ) -ne $null ){
				$this.dataComp = $this.data
				$this.isChanged = $true
			}else{
				$this.isChanged = $false
			}
		}
		
		# =========================================================
		#	Method: ExportData
		#		Exports the Find Dormant Accounts Results
		#
		# 	Parameters:
		# 		exportType - The type of export to perform
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<Test>
		# =========================================================
		[void] ExportData($exportType){
			switch( "$([CSTS_Export]::$($exportType))" ){
				{ "$([CSTS_Export]::XLSX)" } {
					$filename = "$($global:csts.execPath)\results\DormantAccounts_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Dormant Accounts')
				}
			}
		}
				
		# =========================================================
		# 	Method: InvokeFindDormant
		# 		Updates GUI for each host and calls the UpdateHost function
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<UpdateHost>
		#
		# =========================================================
		[void] InvokeFindDormant(){
			[GUI]::Get().showModal('Retrieving Existing Users')
			
			$hosts = $global:csts.libs.hosts.Get()
			$this.data = @()
			$this.dataComp = @()
			
			$i = 0
			$t = $hosts.keys.count
			foreach($h in ($hosts.keys | sort)){
				$i++
				[Log]::Get().msg( "Retrieving Local Accounts information on  $($h).", 0, $this)
				[GUI]::Get().sbarMsg("$($i) / $($t) : Retrieving Local Accounts on $($h).")
				[GUI]::Get().sbarProg( ( $i/$t*100 ) )
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				#get accounts on selected host
				$ping = [Net]::Ping($h)
				if( ($ping.StatusCode -eq 0 -or $ping.StatusCode -eq $null ) -and [Utils]::isBlank($ping.IPV4Address) -eq $false ) {
					$global:csts.vms.FindDormant.getLocalAccounts($h, [int]( [GUI]::Get().window.findName('UC').findName('txtNumOfDays').Text ))
					[System.Windows.Forms.Application]::DoEvents()  | out-null		
					$global:csts.controllers.accounts.updateFindDormantUI()
				}
				
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				$global:csts.controllers.accounts.updateFindDormantUI()
			}
			
			if( $global:csts.vms.AD -ne $null){
				$global:csts.vms.AD.getCheckedItems() | % {
					$global:csts.vms.FindDormant.getDomainAccounts( $_.tag, [int]( [GUI]::Get().window.findName('UC').findName('txtNumOfDays').Text ) )
				}
			}
			
			
			[GUI]::Get().sbarMsg(" ")
			[GUI]::Get().sbarProg( 0 )
			[GUI]::Get().hideModal()
		}
		
		# =========================================================
		# 	Method: getDomainAccounts
		# 		Populates the dormant accounts on specified OU
		#
		# 	Parameters:
		# 		$ou - The OU to get users from
		#		$age - How many days to consider an account dormant
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<getLocalAccounts>
		# =========================================================		
		[void] getDomainAccounts($ou, $age){
			$prefix = "LDAP://"		
			$domain = "$( ([ADSI]'LDAP://RootDSE').Get('rootDomainNamingContext') )"
			if(![Utils]::IsBlank($ou)){
				$query = "$($prefix)$($ou.replace('LDAP://',''))"
			}else{
				$query = "$($prefix)$($domain)"
			}
			
			$currentDate = [System.DateTime]::Now
			$currentDateUtc = $currentDate.ToUniversalTime()
			$lltstamplimit = $currentDateUtc.AddDays(-1 * $age)
			$lltIntLimit = $lltstampLimit.ToFileTime()
			$adobjroot = [adsi]$query
			$objstalesearcher = New-Object System.DirectoryServices.DirectorySearcher($adobjroot)
			$objstalesearcher.filter = "(&(objectCategory=person)(objectClass=user)(lastLogonTimeStamp<=" + $lltIntLimit + "))"

			$domainusers = $objstalesearcher.findall() | select `
				@{e={$_.properties.cn};n='DisplayName'}, `
				@{e={$_.properties.samaccountname};n='Username'}, `
				@{e={[datetime]::FromFileTimeUtc([int64]$_.properties.lastlogontimestamp[0])};n='LastLogon'}, `
				@{e={[string]$adspath=$_.properties.adspath;$account=[ADSI]$adspath;$account.psbase.invokeget('AccountDisabled')};n='Disabled'}, `
				@{e={$_.properties.distinguishedname};n='Path'}, `
				@{e={'Domain'};n='AccountType'}`

			foreach($domainUser in $domainusers){
				$this.data += [pscustomobject]@{
					accountType = "$($domainUser.AccountType)";
					displayName = "$($domainUser.DisplayName)";
					userName = "$($domainUser.UserName)";
					lastLogon = "$($domainUser.LastLogon)";
					disabled = "$($domainUser.Disabled)";
					path = "$($domainUser.Path)";
				}
			}
		}
		
		# =========================================================
		# 	Method: getLocalAccounts
		# 		Populates the dormant accounts on specified host
		#
		# 	Parameters:
		# 		$h - The host to get users from
		#		$age - How many days to consider an account dormant
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<getDomainAccounts>
		# =========================================================		
		[void] getLocalAccounts($h, $age){
			if($global:csts.Role -eq 'Admin'){
				[Log]::Get().msg( "Retrieving Local Accounts information on  $($h) that haven't logged on in $($age) days.", 0, $this)
				
				$localUsers = ([ADSI]"WinNT://$h").Children | ? {$_.SchemaClassName -eq 'user'} | ? { $_.properties.lastlogin -lt ( ( ([System.DateTime]::Now).ToUniversalTime() ).AddDays(-1 * $age) ) } | select `
					@{e={$_.name};n='DisplayName'},`
					@{e={$_.name};n='Username'},`
					@{e={$_.properties.lastlogin};n='LastLogon'},`
					@{e={if($_.properties.userFlags.ToString() -band 2){$true}else{$false} };n='Disabled'},`
					@{e={$_.path};n='Path'}, `
					@{e={'Local'};n='AccountType'}
			
				foreach($localUser in $localUsers){
					$this.data += [pscustomobject]@{
						accountType = "$($localUser.AccountType)";
						displayName = "$($localUser.DisplayName)";
						userName = "$($localUser.UserName)";
						lastLogon = "$($localUser.LastLogon)";
						disabled = "$($localUser.Disabled)";
						path = "$($localUser.Path)";
					}
				}
			}
		}
		
		# =========================================================
		# 	Method: Initialize
		# 		Intiailizes the list of hosts that will be updated
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<InvokeFindDormant>
		# =========================================================
		[void] Initialize(){
			[GUI]::Get().window.findName('UC').findName('txtNumOfDays').Text = '30';
		}

	}
}
Process{
	
}
End{
	
}