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
					$filename = "$($global:csts.execPath)\results\FindDormant_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Find Dormant Accounts')
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
			$i = 0
			$t = $this.data.count
			
			$this.data | % {
				$i++
				
				[GUI]::Get().sbarMsg("Updating Standby Values on $($_.hostname).")
				[GUI]::Get().sbarProg( ( $i/$t*100 ) )
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				$_.Results = $([enum]::GetValues([CSTS_Status])[ $this.UpdateHost( $_.hostname ) ])
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				$global:csts.controllers.systems.updateFindDormantUI()
			}
			
			[GUI]::Get().sbarMsg(" ")
			[GUI]::Get().sbarProg( 0 )
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
			$hosts = $global:csts.libs.hosts.Get()
			$this.data = @()
			$this.dataComp = @()
			$hosts.keys | sort | % {
				[Log]::Get().msg( "Gathering information on  $($_).", 0, $this)
			
				$this.data += [pscustomobject]@{
					accountType = "test";
					displayName = "test";
					userName = "test";
					lastLogon = "test";
					disabled = "test";
					path = "test";
				}
			}
		}
		
		
	}
}
Process{
	
}
End{
	
}