[CmdletBinding()]param()
begin{
	# =========================================================
	#	Class: PreventSleep
	#		The class definition for the object that will 
	#		update the sleep settings on computers
	# =========================================================
	Class PreventSleep{
	
		# =========================================================	
		#	Properties: Static Properties
		#		name 	- The name of the class
		#		desc 	- A detailed description of the class
		# =========================================================
		static $name = "PreventSleep"
		static $desc = "Updates the sleep settings for computers"
		
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
		#	Constructor: PreventSleep
		#		Creates the PreventSleep applet and updates the 
		#		active module in the CSTS
		# =========================================================
		PreventSleep(){
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
		#		Exports the Prevent Sleep Results
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
					$filename = "$($global:csts.execPath)\results\PreventSleep_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"
					$global:csts.libs.Export.Excel( $this.data, $fileName,$false, 'Prevent Sleep')
				}
			}
		}
				
		# =========================================================
		# 	Method: InvokePreventSleep
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
		[void] InvokePreventSleep(){
			[GUI]::Get().showModal('Please Wait... Updating Sleep Settings on Hosts')
			$i = 0
			$t = $this.data.count
			
			$this.data | % {
				$i++
				
				[GUI]::Get().sbarMsg("Updating Standby Values on $($_.hostname).")
				[GUI]::Get().sbarProg( ( $i/$t*100 ) )
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				$_.Results = $([enum]::GetValues([CSTS_Status])[ $this.UpdateHost( $_.hostname ) ])
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				$global:csts.controllers.systems.updatePreventSleepUI()
			}
			
			[GUI]::Get().sbarMsg(" ")
			[GUI]::Get().sbarProg( 0 )
			[GUI]::Get().hideModal()
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
		# 		<InvokePreventSleep>
		# =========================================================
		[void] Initialize(){
			$hosts = $global:csts.libs.hosts.Get()
			$this.data = @()
			$this.dataComp = @()
			$hosts.keys | sort | % {
				[Log]::Get().msg( "Gathering information on  $($_).", 0, $this)
			
				$this.data += [pscustomobject]@{
					Hostname = $_;
					IP 		 = "$($hosts.$($_).IP)";
					Results  = "___";
				}
			}
		}
		
		# =========================================================
		# 	Method: UpdateHost
		#		Updates the sleep settings on a specified host
		#
		#	Parameters:
		#		computerName - the hostname of the computer to update
		#
		#	Returns:
		#		Status code of the update request
		#
		#	See Also:
		#		<InvokePreventSleep>
		# =========================================================
		[int] UpdateHost( $computerName ){
			try{
				([wmiclass]"\\$($computerName)\root\cimv2:win32_Process").create('cmd /c powercfg.exe -change -standby-timeout-ac 0')  | out-null
				([wmiclass]"\\$($computerName)\root\cimv2:win32_Process").create('cmd /c powercfg.exe -change -hibernate-timeout-ac 0')  | out-null
				[Log]::Get().msg( "Standby values updated on $($computerName).", 0, $this)
				return [CSTS_Status]::OK
			}catch{
				[Log]::Get().msg( "Could not connect to $($computerName).", 4, $this)
				return [CSTS_Status]::ERROR
			}
		}
	}
}
Process{
	
}
End{
	
}