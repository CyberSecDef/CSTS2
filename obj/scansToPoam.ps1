[CmdletBinding()]param()
begin{
	# =========================================================
	#	Class: FindDormant
	#		The class definition for the object that will
	#		generate a POAM based off of scans
	# =========================================================
	Class ScansToPoam{

		# =========================================================
		#	Properties: Static Properties
		#		name 	- The name of the class
		#		desc 	- A detailed description of the class
		# =========================================================
		static $name = "ScansToPoam"
		static $desc = "Generates a POAM based on submitted CKLs, ACAS and SCAP Scans"

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
		$scans = @{
			scap = @{};
			acas = @();
			ckl = @{};
		}
		$poamArr = @{}
		$poamKeys = @();
		$scapOpen = @()
		$cklOpen = @()


		# =========================================================
		#	Constructor: ScansToPoam
		#		Creates the ScansToPoam applet and updates the
		#		active module in the CSTS
		# =========================================================
		ScansToPoam(){
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
					$filename = "$($global:csts.execPath)\results\ScansToPoam_$(get-date -format 'yyyy.MM.dd_HH.mm.ss').xlsx"

					$poam = @()
					$rar = @()
					$tests = @()
					$summary = @()
					$issues = @()
					
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting RAR and POAM"; Progress = 65 } ), "Exporting Results" )
					foreach($finding in ($this.poamArr.keys)){
						$rule = $this.poamArr.$finding

						$poam += [pscustomobject]@{
							'Control Vulnerability Description' = @"
Title: $($rule.title)

Description:
$($rule.description)

Devices Affected:
$($rule.hosts -join "`n")
"@;
							'Security Control Number (NC/NA controls only)' = $rule.IAControl;
							'Office/Org' = "";
							'Security Checks' = @"
Group ID: $($rule.GrpId)
Vuln ID: $($rule.VulnId)
Rule ID: $($rule.RuleId)
Plugin ID: $($rule.PluginId)
"@;
							'Raw Severity Value' = $rule.RawRisk;
							'Mitigations' = $rule.mitigations;
							'Severity Value' = $rule.RawRisk;
							'Resources Required' = $rule.Responsibility;
							'Scheduled Completion Date' = "";
							'Milestone with Completion Dates' = "";
							'Milestone Changes' = "";
							'Source Identifying Control Vulnerability' = "$( ( $rule.sources | sort ) -join '/' ): $($rule.Source)";
							'Status' = $rule.Status;
							'Comments' = @"
$($rule.comments)

$($rule.hosts -join "`n");
"@
						}

						$rar += [pscustomObject]@{
							'Non-Compliant Security Controls (16a)' = $rule.IAControl;
							"Affected CCI (16a.1)" = $rule.cci;
							"Source of Discovery(16a.2)" = "$( ( $rule.sources | sort ) -join '/' ): $($rule.Source)";
							"Vulnerability ID(16a.3)" = @"
Group ID: $($rule.GrpId)
Vuln ID: $($rule.VulnId)
Rule ID: $($rule.RuleId)
Plugin ID: $($rule.PluginId)
"@;
							'Vulnerability Description (16.b)' = $rule.title;
							'Devices Affected (16b.1)'= $($rule.hosts -join "`n");
							"Security Objectives (C-I-A) (16c)" = "";
							"Raw Test Result (16d)" = $rule.RawRisk;
							"Predisposing Condition(s) (16d.1)" = "";
							"Technical Mitigation(s)/Remediation(s) (16d.2)" = $rule.mitigations;
							"Severity or Pervasiveness (VL-VH) (16d.3)" = "";
							"Relevance of Threat (VL-VH) (16e)" = "";
							'Threat Description (16e.1)' = $rule.description;
							'Resources' = $rule.Responsibility;
							'Likelihood (Cells 16d.3 & 16e) (VL-VH) (16f)' = "";
							"Impact (VL-VH) (16g)" = "$(switch($rule.RawRisk){ 'IV' {'VL'} 'III' {'L'} 'II' {'M'} 'I' {'H'} })";
							"Impact Description (16h)" = "";
							"Risk (Cells 16f & 16g) (VL-VH) (16i)" = $rule.RawRisk;
							"Proposed Mitigations (From POA&M) (16j)" = "";
							"Residual Risk (After Proposed Mitigations) (16k)" = "";
							'Status' = $rule.status;
							'Recommendations (16l)' = "$($rule.comments)`n`n$($rule.fixid) $($rule.solution)";

						}
					}

					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Test Plan"; Progress = 75 } ), "Exporting Results" )
					$tmpAcas = @()
					foreach($acasScan in ( $this.scans.acas | sort -property scanDate )){
						$tmpAcas += "$($acasScan.scanDate.toString('MM/dd/yyyy') )|$($acasScan.scanOs)|$($acasScan.scanFile)|$($acasScan.engine)|$($acasScan.host)"
					}

					foreach($acasScan in ( $tmpAcas | sort -unique)){
						$scan = $acasScan.split("|")

						$tests += [psCustomObject]@{
							'Title' = 'Assured Compliance Assessment Solution (ACAS) Nessus Scanner'
							'Version' = "$($scan[3])"
							'Host' = "$($scan[4])"
							'Filename' = "$($scan[2])"
							'Date' = "$($scan[0])"
						}
					}

					#only doing it this way because there is no sort unique for objects that works well.
					$tmpScapCkl = @()
					foreach($scapTitle in ( $this.scans.scap.keys | sort )){
						foreach($scapVersion in ($this.scans.scap.$scapTitle.keys | Sort )){
							$tmpScapCkl += "$($scapTitle -replace 'Security Technical Implementation Guide','STIG') - SCAP Benchmark|$($scapVersion)|$($this.scans.scap.$scapTitle.$scapVersion.hosts -join '; ')| |$($this.scans.scap.$scapTitle.$scapVersion.date | sort | select @{Label='Start'; Expression = {$_.toString('MM/dd/yyyy') }} -first 1 | select -expand Start) - $($this.scans.scap.$scapTitle.$scapVersion.date | sort  -descending| select @{Label='Stop'; Expression = {$_.toString('MM/dd/yyyy') }} -first 1 | select -expand Stop)"
						}
					}

					foreach($cklTitle in ( $this.scans.ckl.keys | sort )){
						foreach($cklVersion in ($this.scans.ckl.$cklTitle.keys | Sort )){
							foreach($cklFile in ($this.scans.ckl.$cklTitle.$cklVersion.keys | Sort )){
								$tmpScapCkl += "$($cklTitle -replace 'Security Technical Implementation Guide','STIG') - STIG Checklist|$($cklVersion)|$( $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.host )|$($cklFile)|$( $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.date.toString('MM/dd/yyyy') )"
							}
						}
					}

					foreach($scapCkl in ( $tmpScapCkl | sort -unique)){
						$scan = $scapCkl.split("|")
						$tests += [psCustomObject]@{
							'Title' = "$($scan[0])"
							'Version' = "$($scan[1])"
							'Host' = "$($scan[2])"
							'Filename' = "$($scan[3])"
							'Date' = "$($scan[4])"
						}
					}

					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Summary"; Progress = 80 } ), "Exporting Results" )
					foreach($acasScan in ( $this.scans.acas | sort -property scanDate )){
						$summary += [psCustomObject]@{
							'Type' = "ACAS"
							'Host' = $acasScan.host
							'OS' = $acasScan.scanOs
							'File' = $acasScan.scanFile
							'CAT I' = $acasScan.'cat i'
							'CAT II' = $acasScan.'cat ii'
							'CAT III' = $acasScan.'cat iii'
							'CAT IV' = $acasScan.'cat iv'
							'Total' = ( $acasScan.'criticals' + $acasScan.'cat i' + $acasScan.'cat ii' + $acasScan.'cat iii' + $acasScan.'cat iv')
							'Score' = ( (40*$acasScan.'criticals') + (10*$acasScan.'cat i') + (3*$acasScan.'cat ii') + (1*$acasScan.'cat iii') )
							'Credentialed' = $acasScan.credentialed
						}
					}
					
					
					foreach($cklTitle in ( $this.scans.ckl.keys | sort )){
						foreach($cklVersion in ($this.scans.ckl.$cklTitle.keys | Sort )){
							foreach($cklFile in ($this.scans.ckl.$cklTitle.$cklVersion.keys | Sort )){
							
								$summary += [psCustomObject]@{
									'Type' = "CKL"
									'Host' = $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.host
									'OS' = $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.os
									'File' = $cklFile
									'CAT I' = $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat i'
									'CAT II' = $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat ii'
									'CAT III' = $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat iii'
									'CAT IV' = "0"
									'Total' = ( $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat i' + $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat ii' + $this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat iii' )
									'Score' = ( (10*$this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat i') + (3*$this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat ii') + (1*$this.scans.ckl.$cklTitle.$cklVersion.$cklFile.'cat iii') )
									'Credentialed' = $true
								}
							}
						}
					}
					
					foreach($scapTitle in ( $this.scans.scap.keys | sort )){
						foreach($scapVersion in ($this.scans.scap.$scapTitle.keys | Sort )){
							foreach($scapScore in $this.scans.scap.$scapTitle.$scapVersion.scores.keys){
										
								$summary += [psCustomObject]@{
									'Type' = "SCAP"
									'Host' = $scapScore;
									'OS' = $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'os'
									'File' = "$($this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'title') - $($scapVersion)"
									
									'CAT I' = $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat i'
									'CAT II' = $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat ii'
									'CAT III' = $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat iii'
									'CAT IV' = "0"
									'Total' = ( $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat i' + $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat ii' + $this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat iii' )
									'Score' = ( (10*$this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat i') + (3*$this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat ii') + ($this.scans.scap.$scapTitle.$scapVersion.scores.$scapScore.'cat iii') )
									'Credentialed' = $true
								}
							}
						}
					}
					
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Issues"; Progress = 85 } ), "Exporting Results" )
					foreach($scap in $this.scapOpen){
						$cnt = $this.cklOpen | ? { $_.vulnId -eq $scap.vulnId -and $_.ruleId -eq $scap.ruleId}
						if($cnt -eq $null){
							$issues += [psCustomObject]@{					
								'SCAP/STIG' = $scap.file
								'Asset' = $scap.host
								'Vuln Title' = $scap.title
								'Version/Release' = "V$($scap.version)R$($scap.release)"
								'Group ID' = $scap.grpId
								'Vuln ID' = $scap.vulnId
								'Rule ID' = $scap.ruleId								
								'SCAP Status' = $scap.status
								'STIG Status' = ""
								'Finding' = $scap.findingDetails
								'Comments' = ""
							}
						}
					}
					
					foreach($ckl in $this.cklOpen){
						$cnt = $this.scapOpen | ? { $_.vulnId -eq $ckl.vulnId -and $_.ruleId -eq $ckl.ruleId}
						$scapRun = $this.scapOpen | ? { $_.file -eq $ckl.file }
						if($cnt -eq $null -and $scapRun -ne $null ){
							$issues += [psCustomObject]@{					
								'SCAP/STIG' = $ckl.file
								'Asset' = $ckl.host
								'Vuln Title' = $ckl.title
								'Version/Release' = "V$($scap.version)R$($scap.release)"
								'Group ID' = $ckl.grpId
								'Vuln ID' = $ckl.vulnId
								'Rule ID' = $ckl.ruleId								
								'SCAP Status' = ""
								'STIG Status' = $ckl.status
								'Finding' = $ckl.findingDetails
								'Comments' = $ckl.comments
							}
						}
					}
					
					write-host "Summary: $($summary.count)"
					write-host "Issues: $($issues.count)"
					write-host "Test: $($tests.count)"
					write-host "POAM: $($poam.count)"
					write-host "RAR: $($rar.count)"
					
					
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Summary Spreadhseet"; Progress = 90 } ), "Exporting Results" )
					$global:csts.libs.Export.Excel( $summary, $fileName, $false, 'Summary', @( 15,20,60,70,15,15,15,15,15,15,25) )
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Issues Spreadhseet"; Progress = 92 } ), "Exporting Results" )
					$global:csts.libs.Export.Excel( $issues, $fileName, $true, 'Issues', @( 75, 25, 50, 25, 15,15,15,20,20,75,75 ) )
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Testplan Spreadhseet"; Progress = 94 } ), "Exporting Results" )
					$global:csts.libs.Export.Excel( $tests, $fileName, $true, 'Test Plan', @(75,15,35,75,35))
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting POAM Spreadhseet"; Progress = 96 } ), "Exporting Results" )
					$global:csts.libs.Export.Excel( $poam, $fileName,$true, 'POAM', @(40,15,25,30,15,40,15,25,15,25,25,30,15,35))
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting RAR Spreadhseet"; Progress = 98 } ), "Exporting Results" )
					$global:csts.libs.Export.Excel( $rar, $fileName,$true, 'RAR', @(15,15,45,40,40,30,30,15,45,45,15,15,30,30,30,15,15,45,20,40,40,40,40))
				}
			}
		}

		# =========================================================
		# 	Method: InvokeScansToPoam
		# 		Executes the scan parsing and export process
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		#
		#
		# =========================================================
		[void] InvokeScansToPoam(){
			$this.data = @()
			$this.dataComp = @()

			if( (test-path ([GUI]::Get().window.findName('UC').findName('txtScanLocation').Text) ) -eq $true ){
				[Log]::Get().msg( "Grabbing Scans", 0, $this)
				[GUI]::Get().showModal('Grabbing Files')
				[GUI]::Get().sbarMsg("Grabbing Scans")
				[GUI]::Get().sbarProg( 1 )
				$scanResults = $this.grabFiles()

				$i = 0
				$t = $scanResults.count
				$scanResults | % {
					$i++
					[Log]::Get().msg( "$($i) / $($t) : Parsing Scan $($_.fullname)", 0, $this)
					[GUI]::Get().sbarMsg("$($i) / $($t) : Parsing Scan $($_.name)")
					[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "$($i) / $($t) : Parsing Scan:`n$($_.name)"; Progress = 10 + ( 50 * ( $i/$t) ) } ), "Parsing Scan Files" )
					[GUI]::Get().sbarProg( 10 + ( 50 * ( $i/$t) ) )
					$this.parseFile( (get-item $_.fullname ) )
					$global:csts.controllers.scans.updateScansToPoamUI()
				}

				[Log]::Get().msg( "Exporting Results", 0, $this)
				[GUI]::Get().sbarMsg("Exporting Results")
				[GUI]::Get().showModal( @( [pscustomobject]@{ Text = "Exporting Results"; Progress = 65 } ), "Exporting Results" )
				[GUI]::Get().sbarProg( 65 )

				$this.ExportData("$([CSTS_Export]::XLSX)")
			}else{
				[GUI]::Get().showMessage('Invalid Scan Location Specified!')
			}
			
			[GUI]::Get().sbarMsg(" ")
			[GUI]::Get().sbarProg( 0 )
			[GUI]::Get().hideModal()
		}

		[void]parseFile($file){
			if($file -is [String]){
				$file = get-item $file
			}

			switch($file.extension){
				".zip" 		{
					$TempDir = [System.Guid]::NewGuid().ToString()
					New-Item -Type Directory -force  "$($global:csts.execpath)\temp\$($tempDir)"

					$shellApplication = new-object -com shell.application
					$zipPackage = $shellApplication.NameSpace($file.fullname)
					$destinationFolder = $shellApplication.NameSpace("$($global:csts.execPath)\temp\$($tempDir)")
					$destinationFolder.CopyHere($zipPackage.Items())

					gci "$($global:csts.execPath)\temp\$($tempDir)" -recurse | %{
						$this.parseFile( $_.fullname )
					}

					Remove-Item "$($global:csts.execPath)\temp\$($TempDir)\*.*" -Force
					Remove-Item "$($global:csts.execPath)\temp\$($TempDir)"
				}
				".xml" 		{ [xml]$scanData = Get-Content $file.fullname }
				".nessus" 	{ [xml]$scanData = Get-Content $file.fullname }
				".ckl" 		{ [xml]$scanData = Get-Content $file.fullname }
				default 	{ $scanData = $null }
			}


			if($scanData.Benchmark -ne $null){
				$this.parseXCCDFResult($scanData)
			}elseif($scanData.CHECKLIST -ne $null){
				$this.parseCKLResult($scanData, $file)
			}elseif($scanData.NessusClientData_v2 -ne $null){
				$this.parseNessusResult($scanData, $file)
			}
		}

		[void]addResult($h,$reportItem){
			if($reportItem.status -ne 'Completed'){
			
				switch($reportItem.shortSource){
					"SCAP"	{
						$this.scapOpen += @{
							'vulnId' = $reportItem.vulnId;
							'grpId' = $reportItem.grpId;
							'ruleId' = $reportItem.ruleId;
							'title' = $reportItem.title;
							'status' = $reportItem.status;
							'host' = "$($h)".ToLower();
							'file' = $reportItem.file;
							'findingDetails' = $reportItem.findingDetails;
							'comments' = $reportItem.comments;
							'version' = $reportItem.version;
							'release' = "$($reportItem.release)";
						}
					}
					"CKL"  	{
						$this.cklOpen += @{
							'vulnId' = $reportItem.vulnId;
							'grpId' = $reportItem.grpId;
							'ruleId' = $reportItem.ruleId;
							'title' = $reportItem.title;
							'status' = $reportItem.status;
							'host' = "$($h)".ToLower();
							'file' = $reportItem.file;
							'findingDetails' = $reportItem.findingDetails;
							'comments' = $reportItem.comments;
							'version' = $reportItem.version;
							'release' = "$($reportItem.release)";
						}
					}
				}
				
			
				#see if this report already exists in $poamArr
				if([Utils]::isBlank("$($reportItem.VulnId)$($reportItem.RuleId)$($reportItem.PluginId)".trim()) -eq $false){
					$key = "$($reportItem.VulnId)-$($reportItem.RuleId)-$($reportItem.PluginId)"

					
					if($this.poamKeys -contains $key ){
						if($this.poamArr.$key.hosts -notcontains ("$h".ToLower()) ){
							$this.poamArr.$key.hosts += "$h".ToLower()
						}

					
						if([Utils]::isBlank( $reportItem.IA_Controls) -eq $false){
							$this.poamArr.$key.IA_Controls = $reportItem.IA_Controls
						}

					
						if([Utils]::isBlank($reportItem.Comments) -eq $false){
							$this.poamArr.$key.Comments = "$($this.poamArr.$key.Comments)`n`n$($reportItem.Comments)"
						}

						if($this.poamArr.$key.sources -notcontains ( $reportItem.shortSource ) ){
							$this.poamArr.$key.sources += ( $reportItem.shortSource )
						}
					}else{
						$this.poamKeys += $key
						$reportItem.Sources = @()
						$reportItem.Sources += $reportItem.shortSource
						$reportItem.hosts = @()
						$reportItem.hosts += "$h".ToLower()
						$this.poamArr.add( $key, $reportItem)

						$this.data += [pscustomobject]@{
							control = "$($reportItem.IAControl)";
							source = "$( ( $reportItem.sources | sort ) -join '/' ): $($reportItem.Source)";
							checks = "Group ID: $($reportItem.GrpId)`nVuln ID: $($reportItem.VulnId)`nRule ID: $($reportItem.RuleId)`nPlugin ID: $($reportItem.PluginId)"
							title = "$($reportItem.Title)";
							rawRisk = "$($reportItem.RawCat)";
							status = "$($reportItem.status)";
							hosts = "$($reportItem.hosts)";
						}

					}
				}
			}
		}

		[void]parseXCCDFResult($xml){
			$xmlNs = @{}
			$xml.DocumentElement.Attributes | % {
				if($_.Prefix -eq 'xmlns'){
					$name = ($_.Name).split(":")[1]
					$uri = $_.'#text'
					$xmlNs[$name] = $uri
				}
			}

			$h  = Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:target" $xml
			$os = Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:target-facts/cdf:fact[@name='urn:scap:fact:asset:identifier:os_name']" $xml
			
			$title = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:title" $xml | select -expand Node | select innerXml).innerxml
			$version = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:version" $xml | select -expand Node | select innerXml).innerxml
			$release = ( ( [regex]::matches( (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:plain-text[@id='release-info']" $xml), "Release: ([0-9.]+)") | select groups).groups[1] | select -expand value)
			$scanDate =  [datetime]::ParseExact(
				(Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/@start-time" $xml ),
				'yyyy-MM-ddTHH:mm:ss',
				$null
			)

			if($this.scans.scap.keys -notcontains $title){
				$this.scans.scap.$title = @{}
			}

			if($this.scans.scap.$title.keys -notcontains "V$($version)R$($release)"){
				$this.scans.scap.$title."V$($version)R$($release)" = @{}
				$this.scans.scap.$title."V$($version)R$($release)".hosts = @()
				$this.scans.scap.$title."V$($version)R$($release)".date = @()
				$this.scans.scap.$title."V$($version)R$($release)".scores = @{}
			}

			$this.scans.scap.$title."V$($version)R$($release)".hosts += ( $h | select -expand Node | select innerXml).innerxml.toString().toLower()
			$this.scans.scap.$title."V$($version)R$($release)".date += $scanDate

			if($this.scans.scap.$title."V$($version)R$($release)".scores.keys -notContains ( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ) ){
				$this.scans.scap.$title."V$($version)R$($release)".scores.add( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower(), @{} )
			}
			
			
			$this.scans.scap.$title."V$($version)R$($release)".scores.( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ).os = $os
			$this.scans.scap.$title."V$($version)R$($release)".scores.( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ).title = "$($title)"
			$this.scans.scap.$title."V$($version)R$($release)".scores.( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ).'cat i' = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:rule-result[./cdf:result!='pass'][@idref=/cdf:Benchmark/cdf:Group/cdf:Rule[@severity='high']/@id]" $xml).count
			$this.scans.scap.$title."V$($version)R$($release)".scores.( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ).'cat ii' = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:rule-result[./cdf:result!='pass'][@idref=/cdf:Benchmark/cdf:Group/cdf:Rule[@severity='medium']/@id]" $xml).count
			$this.scans.scap.$title."V$($version)R$($release)".scores.( ( $h | select -expand Node | select innerXml).innerxml.toString().toLower() ).'cat iii' = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:rule-result[./cdf:result!='pass'][@idref=/cdf:Benchmark/cdf:Group/cdf:Rule[@severity='low']/@id]" $xml).count
			
			
			$vulns = Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:TestResult/cdf:rule-result" $xml
	
			
	
			for($i = 0; $i -lt $vulns.count; $i++){
				$rule = Select-Xml -Namespace $xmlNs -xpath "//cdf:Rule[@id='$($vulns[$i].Node.idref)']" $xml
				
				$reportItem = @{}

				$reportItem.Comments = ""
				$reportItem.Mitigations = ""
				$reportItem.FindingDetails = $vulns[$i].Node.outerXml
				$reportItem.CCI = "$($rule.Node.ident.'#text')"
				$reportItem.FixId = "$($rule.Node.fixtext.fixref)"
				$reportItem.GrpId = $vulns[$i].Node.version
				$reportItem.PluginId = ""
				$reportItem.RuleId = $vulns[$i].Node.idref
				$reportItem.ShortSource = "SCAP"
				$reportItem.Solution = "$($rule.Node.fixtext.'#text')"
				$reportItem.Source = (Select-Xml -Namespace $xmlNs -xpath "/cdf:Benchmark/cdf:title" $xml)
				$reportItem.Title = $rule.Node.title
				$reportItem.VulnId = $rule.Node.ParentNode.id
				$reportITem.file = $title
				
				$reportItem.version = $version
				$reportItem.release = "$($release)"
				
				$reportItem.Description = ""
				$reportItem.IAControl = ""
				$reportItem.Responsibility = ""

				if([Utils]::isBlank( $rule.Node.description ) -eq $false){
					if( $rule.Node.description.indexOf('</VulnDiscussion>') -gt 0){
						$reportItem.Description = $rule.Node.description.substring( $rule.Node.description.indexOf('<VulnDiscussion>') + 17, $rule.Node.description.indexOf('</VulnDiscussion>') - 1)
					}else{
						$reportItem.Description = $rule.Node.description
					}

					try{
						$description = [xml]( "<root>$(
							$rule.Node.description.substring( $rule.Node.description.indexOf('</VulnDiscussion>') + 17 )
						)</root>" )
						$reportItem.Responsibility = $description.root.Responsibility
						$reportItem.IAControl = $description.root.IAControls
						$index = $reportItem.IAControl.indexOf(',')
						if($index -ge 0){
							$reportItem.IAControl = $reportItem.IAControl.substring(0, $index )
						}
					}catch{

					}
				}

				switch($rule.Node.severity){
					"low" 		{$reportItem.RawRisk = "III"}
					"medium" 	{$reportItem.RawRisk = "II"}
					"high" 		{$reportItem.RawRisk = "I"}
					default 	{$reportItem.RawRisk = "IV"}
				}


				switch($vulns[$i].Node.result){
					"pass" {$reportItem.Status = "Completed"}
					"notselected" {$reportItem.Status = "Completed"}
					"fail" {$reportItem.Status = "Ongoing"}
					"error" {$reportItem.Status = "Error"}
					default {$reportItem.Status = "Ongoing"}
				}

				if($reportItem.Status -ne 'Completed' -and "$h".trim() -ne ''){
					$this.addResult($h,$reportItem)
				}
			}
		}

		[void]parseCKLResult($xml, $file){

			$verCheck = select-xml "/CHECKLIST/STIGS/iSTIG" $xml
			$rmfMap = import-csv "$($global:csts.execPath)\db\800-53_to_8500.2_mapping.csv"

			$cciXml = [xml](gc "$($global:csts.execPath)\db\U_CCI_List.xml")
			$cciNs = new-object Xml.XmlNamespaceManager $cciXml.NameTable
			$cciNs.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance" );
			$cciNs.AddNamespace("ns", "http://iase.disa.mil/cci" );

			if( [Utils]::isBlank( $verCheck ) -eq $false){

				$h = Select-Xml "/CHECKLIST/ASSET/HOST_NAME" $xml
				$vulns = Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN" $xml
				$title = (select-xml "/CHECKLIST/STIGS/iSTIG/STIG_INFO/SI_DATA[./SID_NAME='title']/SID_DATA" $xml | select -expand Node | select innerXml).innerxml

				$version = ""
				$release = ""
				$vrKey = "VR"

				$m = ([regex]::matches(  [io.path]::GetFilename( $file.fullname ) , "V([0-9]+)R([0-9]+)" ) | select -expand groups)

				if($m.count -ge 1){
					$version = $m[1].value
					$release = $m[2].value
					$vrKey = "V$($version)R$($release)"
				}else{
					#its not in the filename, lets see if we have any matching stigs in the stig folder
					$cklRules = @()
					(select-xml "/CHECKLIST/STIGS/iSTIG/VULN/STIG_DATA[VULN_ATTRIBUTE='Rule_ID']/ATTRIBUTE_DATA" $xml )| %{
						$cklRules += $_.Node.'#text'
					}

					$ckls = ( gci "$($global:csts.execPath)\stigs\" -recurse -include "*xccdf.xml" -exclude "*Benchmark*" | sort -descending )
					foreach($ckl in $ckls){

						$currentXml = ([xml](gc $ckl.fullname))

						$xccdfNs = new-object Xml.XmlNamespaceManager $currentXml.NameTable
						$xccdfNs.AddNamespace("dsig", "http://www.w3.org/2000/09/xmldsig#" );
						$xccdfNs.AddNamespace("xhtml", "http://www.w3.org/1999/xhtml" );
						$xccdfNs.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance" );
						$xccdfNs.AddNamespace("cpe", "http://cpe.mitre.org/language/2.0" );
						$xccdfNs.AddNamespace("dc", "http://purl.org/dc/elements/1.1/" );
						$xccdfNs.AddNamespace("ns", "http://checklists.nist.gov/xccdf/1.1" );

						if($title -eq $currentXml.Benchmark.title){

							$stigRules = @()
							$currentXml.selectNodes('//ns:Benchmark/ns:Group/ns:Rule', $xccdfNs) | % {
								$stigRules += $_.id
							}

							$comparison = ( compare-object ($stigRules | sort) ($cklRules | sort ) )

							if([Utils]::isBlank($comparison) -eq $true){
								$version = ($currentXml.selectSingleNode("//ns:Benchmark/ns:version", $xccdfNs).'#text')
								$release = ( ( [regex]::matches( ($currentXml.selectSingleNode("//ns:Benchmark/ns:plain-text[@id='release-info']", $xccdfNs).'#text'), "Release: ([0-9.]+)") | select groups).groups[1] | select -expand value)
								$vrKey = "V$($version)R$($release)"
								break
							}
						}
					}
				}

				$scanDate =  ($file | select -expand LastWriteTime)

				#see if stigScapInfo key for this scap exists
				if($this.scans.ckl.keys -notcontains $title){
					$this.scans.ckl.$title = @{}
				}

				#see if this release is already in the stigScapInfo
				if($this.scans.ckl.$title.keys -notcontains $vrKey){
					$this.scans.ckl.$title.$vrKey = @{}
				}

				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullName ))" = @{}
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullName ))".host = ( $h | select -expand Node | select innerXml).innerxml.toString().toLower()
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullName );)".date = $scanDate

				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat i' = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='high' ]" ([xml]$xml)).count
				
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat ii' = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='medium' ]" ([xml]$xml)).count
				
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat iii' = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='low' ]" ([xml]$xml)).count
				
				
				
				
				
				for($i = 0; $i -lt $vulns.count; $i++){

					$reportItem = @{}
					$reportItem.CCI = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='CCI_REF']/ATTRIBUTE_DATA" $xml)
					$reportItem.Comments = ""
					$reportItem.Mitigations = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/COMMENTS" $xml)
					
					$reportItem.FindingDetails = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/FINDING_DETAILS" $xml)
					
					$reportItem.Description = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Vuln_Discuss']/ATTRIBUTE_DATA" $xml)
					$reportItem.FixId= ""
					$reportItem.GrpId = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Group_Title']/ATTRIBUTE_DATA" $xml)
					$reportItem.PluginId = ""
					$reportItem.Responsibility = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Responsibility']/ATTRIBUTE_DATA" $xml)
					$reportItem.RuleId = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Rule_ID']/ATTRIBUTE_DATA" $xml)
					$reportItem.ShortSource = "CKL"
					$reportItem.Solution = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Fix_Text']/ATTRIBUTE_DATA" $xml)
					$reportItem.Source = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='STIGRef']/ATTRIBUTE_DATA" $xml)
					$reportItem.Title = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Rule_Title']/ATTRIBUTE_DATA" $xml)
					$reportItem.VulnId = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Vuln_Num']/ATTRIBUTE_DATA" $xml)
					$reportItem.file = $title
					
					$reportItem.version = $version
					$reportItem.release = $release
				
					$reportItem.IAControl = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='IA_Controls']/ATTRIBUTE_DATA" $xml).'#text'
					if([Utils]::isBlank( $reportItem.IAControl ) -eq $true){
						$cci = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='CCI_REF']/ATTRIBUTE_DATA" $xml | select -first 1)
						if([Utils]::isBlank($cci) -eq $false){
							$cciNode  = $cciXml.selectSingleNode("//ns:cci_list/ns:cci_items/ns:cci_item[@id='$($cci)']", $cciNs)
							$rmfControl = $cciNode.references.reference | sort Version -descending | select -first 1 | select -expand index

							$iaControl = ($rmfMap | ? { $_.'800-53' -eq "$($rmfControl -replace ' ','' -replace '\([a-z]\)','' )" } | select -expand '8500.2' )
							if([Utils]::isBlank($iaControl)){
								$testRmf = $rmfControl -replace '\([a-z]\)','' -replace '\([0-9]+\)','' -replace ' [a-z]','' -replace ' ',''
								$iaControl = ($rmfMap | ? { $_.'800-53' -eq $testRmf } | select -expand '8500.2' -first 1)
							}

							if([Utils]::isblank($iaControl) -eq $false){
								$reportItem.IAControl = $iaControl
							}else{
								$reportItem.IAControl = ''
							}
						}
					}
					$index = "$($reportItem.IAControl)".indexOf(',')
					if($index -ge 0){
						$reportItem.IAControl = $reportItem.IAControl.substring(0, $index )
					}

					switch( (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Severity']/ATTRIBUTE_DATA" $xml) ){
						"low" 		{$reportItem.RawRisk = "III"}
						"medium" 	{$reportItem.RawRisk = "II"}
						"high" 		{$reportItem.RawRisk = "I"}
						default 	{$reportItem.RawRisk = "IV"}
					}

					switch( Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/STATUS" $xml ){
						"Open" 				{$reportItem.Status =  "Ongoing"}
						"NotAFinding" 		{$reportItem.Status =  "Completed"}
						"Not_Applicable" 	{$reportItem.Status =  "Completed"}
						default 			{$reportItem.Status =  "Ongoing"}
					}

					if([Utils]::isBlank("$($reportItem.RuleId)$($reportItem.vulnid)$($reportItem.grpId)".Trim() ) -eq $false  ){
						$this.addResult($h,$reportItem)
					}
				}
			}else{
				$h = Select-Xml "/CHECKLIST/ASSET/HOST_NAME" $xml
				$vulns = Select-Xml "/CHECKLIST/VULN" $xml

				$version = ""
				$release = ""
				$vrKey = "VR"

				$title = (Select-Xml "/CHECKLIST/STIG_INFO/STIG_TITLE" $xml | select -expand Node | select innerXml).innerxml
				$m = ([regex]::matches(  [io.path]::GetFilename( $file.fullname ) , "V([0-9]+)R([0-9]+)" ) | select -expand groups)

				if($m.count -ge 1){
					$version = $m[1].value
					$release = $m[2].value
					$vrKey = "V$($version)R$($release)"
				}else{

					$cklRules = @()
					(Select-Xml "/CHECKLIST/VULN/STIG_DATA[VULN_ATTRIBUTE='Rule_ID']/ATTRIBUTE_DATA" $xml )| %{
						$cklRules += $_.Node.'#text'
					}

					$ckls = ( gci "$($global:csts.execPath)\stigs\" -recurse -include "*xccdf.xml" -exclude "*Benchmark*" | sort -descending )
					foreach($ckl in $ckls){

						$currentXml = ([xml](gc $ckl.fullname))

						$xccdfNs = new-object Xml.XmlNamespaceManager $currentXml.NameTable
						$xccdfNs.AddNamespace("dsig", "http://www.w3.org/2000/09/xmldsig#" );
						$xccdfNs.AddNamespace("xhtml", "http://www.w3.org/1999/xhtml" );
						$xccdfNs.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance" );
						$xccdfNs.AddNamespace("cpe", "http://cpe.mitre.org/language/2.0" );
						$xccdfNs.AddNamespace("dc", "http://purl.org/dc/elements/1.1/" );
						$xccdfNs.AddNamespace("ns", "http://checklists.nist.gov/xccdf/1.1" );

						if($title -eq $currentXml.Benchmark.title){
							$stigRules = @()
							$currentXml.selectNodes('//ns:Benchmark/ns:Group/ns:Rule', $xccdfNs) | % {
								$stigRules += $_.id
							}

							$comparison = ( compare-object ($stigRules | sort) ($cklRules | sort ) )

							if([Utils]::isBlank($comparison) -eq $true){
								$version = ($currentXml.selectSingleNode("//ns:Benchmark/ns:version", $xccdfNs).'#text')
								$release = ( ( [regex]::matches( ($currentXml.selectSingleNode("//ns:Benchmark/ns:plain-text[@id='release-info']", $xccdfNs).'#text'), "Release: ([0-9.]+)") | select groups).groups[1] | select -expand value)
								$vrKey = "V$($version)R$($release)"
								break
							}
						}
					}
				}

				$scanDate =  ($file | select -expand LastWriteTime)

				if($this.scans.ckl.keys -notcontains $title){
					$this.scans.ckl.$title = @{}
				}

				if($this.scans.ckl.$title.keys -notcontains $vrKey){
					$this.scans.ckl.$title.$vrKey = @{}
				}

				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname ))" = @{}
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname ))".host = ( $h | select -expand Node | select innerXml).innerxml.toString().toLower()
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".date = $scanDate

				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat i' = (Select-Xml "/CHECKLIST/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='high' ]" ([xml]$xml)).count
				
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat ii' = (Select-Xml "/CHECKLIST/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='medium' ]" ([xml]$xml)).count
				
				$this.scans.ckl.$title.$vrKey."$([io.path]::GetFilename( $file.fullname );)".'cat iii' = (Select-Xml "/CHECKLIST/VULN[not(./STATUS='NotAFinding') and not(./STATUS='Not_Applicable')]/STIG_DATA[./VULN_ATTRIBUTE='Severity' and ./ATTRIBUTE_DATA='low' ]" ([xml]$xml)).count
				

				
				
				for($i = 0; $i -lt $vulns.count; $i++){

					$reportItem = @{}
					$reportItem.CCI = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='CCI_REF']/ATTRIBUTE_DATA" $xml)

					$reportItem.Comments = ""
					$reportItem.Mitigations = (Select-Xml "/CHECKLIST/STIGS/iSTIG/VULN[$i]/COMMENTS" $xml)
					
					$reportItem.FindingDetails = (Select-Xml "/CHECKLIST/VULN[$i]/FINDING_DETAILS" $xml)
					$reportItem.Description = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Vuln_Discuss']/ATTRIBUTE_DATA" $xml)
					$reportItem.FixId= ""
					$reportItem.GrpId = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Group_Title']/ATTRIBUTE_DATA" $xml)
					$reportItem.PluginId = ""
					$reportItem.Responsibility = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Responsibility']/ATTRIBUTE_DATA" $xml)
					$reportItem.RuleId = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Rule_ID']/ATTRIBUTE_DATA" $xml)
					$reportItem.ShortSource = "CKL"
					$reportItem.Solution = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Fix_Text']/ATTRIBUTE_DATA" $xml)
					$reportItem.Source = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='STIGRef']/ATTRIBUTE_DATA" $xml)
					$reportItem.Title = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Rule_Title']/ATTRIBUTE_DATA" $xml)
					$reportItem.VulnId = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Vuln_Num']/ATTRIBUTE_DATA" $xml)
					$reportItem.file = $title

					$reportItem.version = $version
					$reportItem.release = $release
				
					switch( (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='Severity']/ATTRIBUTE_DATA" $xml) ){
						"low" 		{$reportItem.RawRisk = "III"}
						"medium" 	{$reportItem.RawRisk = "II"}
						"high" 		{$reportItem.RawRisk = "I"}
						default 	{$reportItem.RawRisk = "IV"}
					}

					$reportItem.IAControl = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='IA_Controls']/ATTRIBUTE_DATA" $xml).'#text'
					if([Utils]::isBlank( $reportItem.IAControl ) -eq $true){
						$cci = (Select-Xml "/CHECKLIST/VULN[$i]/STIG_DATA[VULN_ATTRIBUTE='CCI_REF']/ATTRIBUTE_DATA" $xml | select -first 1)
						if([Utils]::isBlank($cci) -eq $false){
							$cciNode  = $cciXml.selectSingleNode("//ns:cci_list/ns:cci_items/ns:cci_item[@id='$($cci)']", $cciNs)
							$rmfControl = $cciNode.references.reference | sort Version -descending | select -first 1 | select -expand index

							$iaControl = ($rmfMap | ? { $_.'800-53' -eq "$($rmfControl -replace ' ','' -replace '\([a-z]\)','' )" } | select -expand '8500.2' )
							if([Utils]::isBlank($iaControl)){
								$testRmf = $rmfControl -replace '\([a-z]\)','' -replace '\([0-9]+\)','' -replace ' [a-z]','' -replace ' ',''
								$iaControl = ($rmfMap | ? { $_.'800-53' -eq $testRmf } | select -expand '8500.2' -first 1)
							}

							if([Utils]::isblank($iaControl) -eq $false){
								$reportItem.IAControl = $iaControl
							}else{
								$reportItem.IAControl = ''
							}
						}
					}

					$index = "$($reportItem.IAControl)".indexOf(',')
					if($index -ge 0){
						$reportItem.IAControl = $reportItem.IAControl.substring(0, $index )
					}

					switch( Select-Xml "/CHECKLIST/VULN[$i]/STATUS" $xml ){
						"Open" 				{$reportItem.Status =  "Ongoing"}
						"NotAFinding" 		{$reportItem.Status =  "Completed"}
						"Not_Applicable" 	{$reportItem.Status =  "Completed"}
						default 			{$reportItem.Status =  "Ongoing"}
					}

					if([Utils]::isBlank("$($reportItem.RuleId)$($reportItem.vulnid)$($reportItem.grpId)".Trim() ) -eq $false  ){
						$this.addResult($h,$reportItem)
					}
				}
			}
		}

		[void]parseNessusResult($xml, $file){
			$hosts = Select-Xml "/NessusClientData_v2/Report/ReportHost" $xml

			foreach($h in $hosts){
				$hostScanDate =  ([dateTime]::ParseExact( ($h.Node.SelectSingleNode("./HostProperties/tag[@name='HOST_START']").'#text').replace('  ',' '), 'ddd MMM d HH:mm:ss yyyy', $null) )
				$hostScanOs = ($h.Node.SelectSingleNode("./HostProperties/tag[@name='operating-system']").'#text') + ' ' + ($h.Node.SelectSingleNode("./HostProperties/tag[@name='os']").'#text')

				$hostScanEngine = "0.0"
				$hostScanCred = $false
				($h.Node.SelectSingleNode("./ReportItem[@pluginID='19506']/plugin_output").'#text') -split "`n"   | % {
					if ( (($_ -split ":")[0]) -like 'Nessus version*'){
						$hostScanEngine =  ( [regex]::matches(  (($_ -split ":")[1]).Trim() , "(^[0-9\.]+)" ) | select -first 1 )
					}
					
					if ($_ -like '*Credentialed checks : yes*'){
						$hostScanCred = $true
					}
				}

				$this.scans.acas += @{
					"scanDate" = $hostScanDate;
					"scanOs" = $hostScanOs;
					"scanFile" = [io.path]::GetFilename( $file.name );
					"engine" = $hostScanEngine;
					"host" = $h.node.name;
					"criticals" = 0 + ($h.node.reportItem | ? { $_.risk_factor -eq 'Critical'   }).count
					"cat i" = 0 + ($h.node.reportItem | ? { $_.risk_factor -eq 'High' }).count
					"cat ii" = 0 + ($h.node.reportItem | ? { $_.risk_factor -eq 'Medium'}).count
					"cat iii" = 0 + ($h.node.reportItem | ? { $_.risk_factor -eq 'Low'}).count
					"cat iv" = 0 + ($h.node.reportItem | ? { $_.risk_factor -eq 'None'}).count
					"credentialed" = $hostScanCred
				}


				foreach($report in $h.Node.ReportItem){
					
					#create a report item
					$reportItem = @{}
					$reportItem.CCI = "";
					$reportItem.Comments = $report.plugin_output
					$reportItem.Mitigations = ""
					$reportItem.findingDetails = ""
					$reportItem.Description = $report.synopsis
					$reportItem.FixId= ""
					$reportItem.GrpId = $report.pluginFamily
					$reportItem.PluginId = $report.pluginId
					$reportItem.Responsibility = ""
					$reportItem.RuleId = ""
					$reportItem.ShortSource = "ACAS"
					$reportItem.Solution = $report.solution
					$reportItem.Source = "Assured Compliance Assessment Solution:"
					$reportItem.Title = $report.pluginName
					$reportItem.VulnId = ""


					$reportItem.IA_Controls = ""
					$reportItem.Status = "Ongoing"

					switch($report.risk_factor){
						"None" 		{$reportItem.RawRisk = "IV"}
						"Low" 		{$reportItem.RawRisk = "III"}
						"Medium" 	{$reportItem.RawRisk = "II"}
						"High" 		{$reportItem.RawRisk = "I"}
						"Critical" 	{$reportItem.RawRisk = "I"}
						default 	{$reportItem.RawRisk = "IV"}
					}

					$this.addResult($h.Node.name, $reportItem)
				}
			}
		}

		[Object[]]grabFiles(){
			$t = @()
			$scanResults = @()
			$recurse = [GUI]::Get().window.findName('UC').findName('chkScansToPoamRecurse').IsChecked

			#these are ordered by reverse write time.  so the latest is processed first.  Any updates will only add host names and comments.
			#not perfect, but you shouldn't be processing multiple sets of scans at the same time.
			if($recurse){
				gci ([GUI]::Get().window.findName('UC').findName('txtScanLocation').Text) -recurse | ? { $_.name -notlike '*oval*' } | ? { !$_.PSIsContainer } | ? { [CSTS_ScanExtension].GetEnumValues() -contains "$($_.extension.replace('.',''))" } | Sort-Object LastWriteTime -Descending | %{
					if($t -notcontains $_.name ){
						[Log]::Get().msg( "Grabbed $_.fullname", 0, $this)
						$scanResults  += $_;
						$t += $_.name
					}
				}
			}else{
				gci ([GUI]::Get().window.findName('UC').findName('txtScanLocation').Text) | ? { $_.name -notlike '*oval*' } | ? { !$_.PSIsContainer } | ? { [CSTS_ScanExtension].GetEnumValues() -contains "$($_.extension.replace('.',''))" } | Sort-Object LastWriteTime -Descending | %{
					if($t -notcontains $_.name ){
						[Log]::Get().msg( "Grabbed $_.fullname", 0, $this)
						$scanResults  += $_;
						$t += $_.name
					}
				}
			}

			return $scanResults
		}

		# =========================================================
		# 	Method: Initialize
		# 		Intiailizes the scans to poam applet
		#
		# 	Parameters:
		# 		NA
		#
		# 	Returns:
		# 		NA
		#
		# 	See Also:
		# 		<InvokeScansToPoam>
		# =========================================================
		[void] Initialize(){

		}

	}
}
Process{

}
End{

}