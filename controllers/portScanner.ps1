[CmdletBinding()]param()
begin{
	
	Class PortScanner{
		
		PortScanner(){
			
		}
		
		[void]Poll(){
		
		}
		
		[void]Test(){
			write-host 'in test'
		}
		
		[void]Load(){
			#make the home content div
			$uc = Get-XAML( [xml](iex ('@"' + "`n" + (gc "$($global:csts.execPath)/views/scans/portScanner.xaml") + "`n" + '"@') ) )
			$global:csts.window.FindName('contentContainer').Children.clear()
			$global:csts.window.FindName('contentContainer').AddChild($uc);

			#now load up the events
			$global:csts.window.FindName('contentContainer').Children.FindName('btnTest').add_Click( { 
				
				$computer = 'localhost'
				$testArray = @()
				$netStat = invoke-command -computerName $computer -scriptBlock { $d = & netstat -ano ; return $d }
				($netStat -split "`r`n") | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {
					
					$item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
					
					if($item ){
						if($item[1] -notmatch '^\[::') {
							
							if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') { 
							   $localAddress = $la.IPAddressToString 
							   $localPort = $item[1].split('\]:')[-1] 
							} else { 
								$localAddress = $item[1].split(':')[0] 
								$localPort = $item[1].split(':')[-1] 
							} 

							if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') { 
							   $remoteAddress = $ra.IPAddressToString 
							   $remotePort = $item[2].split('\]:')[-1] 
							} else { 
							   $remoteAddress = $item[2].split(':')[0] 
							   $remotePort = $item[2].split(':')[-1] 
							} 
							
							$r = New-Object PSObject -Property @{
								System = $computer
								PID = $item[-1] 
								'TcpUdp' = $item[0] 
								'LocalAddress' = $localAddress 
								'LocalPort' = $localPort 
								'RemoteAddress' = $remoteAddress 
								'RemotePort' = $remotePort
								State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
							} | Select-Object -Property $properties
				
							$testArray += $r
						}
					}
				}
	
				$global:csts.window.FindName('contentContainer').Children.FindName('dGridScannersPorts').ItemsSource = $testArray ;
				
			} );
		}
	}
}
process{

	
}
end{
	[System.GC]::Collect() | out-null
}