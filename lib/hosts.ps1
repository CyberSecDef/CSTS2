[CmdletBinding()]param()
begin{
	Class Hosts{
		$hostTable = @{};
		
		Hosts(){
		
		}
		
		[void] parseOU( $ou ){
			$ds = New-Object DirectoryServices.DirectorySearcher
			$ds.Filter = "ObjectCategory=Computer"
			$ds.SearchRoot = "LDAP://$($ou)"
			
			$hosts = $ds.FindAll() 
			$i = 0
			$t = $hosts.count
			$hosts | sort { $_.properties['dnshostname']} | % {
				$i++
				$adHost = [string]($_.Properties['dnshostname'])
				
				[GUI]::Get().sbarMsg("Gathering information on $($adhost).")
				[GUI]::Get().sbarProg( ( $i/$t*100 ) )
				[System.Windows.Forms.Application]::DoEvents()  | out-null		
				
				if(($adHost.indexOf(".")) -ne -1){
					if(($adHost.indexOf(".")) -gt 0){
						$adHost = $adHost.substring(0,$adHost.indexOf("."))
					}
				}
			
				$adHost = $adHost.trim()
				
				if($global:csts.libs.Utils::isBlank($adHost) -eq $false){
					if( $adHost -ne $null -and $this.hostTable.keys -notcontains $adHost ){
						$ip = ''
						try{
							$ip = ([System.Net.Dns]::GetHostAddresses($adHost).IPAddressToString | select -first 1)
						}catch{
							$ip = ''
						}
					
						$this.hostTable.Add( $adHost, @{ IP = $ip; } ) | out-null
					}
				}
			} | out-null
			
			[GUI]::Get().sbarMsg("")
			[GUI]::Get().sbarProg( 0 )
			[System.Windows.Forms.Application]::DoEvents()  | out-null		
		}
		
		[void] parseTxt( $txt ){
			$txt = $txt -replace "`r", "" -replace "`n","," -replace ' ',''
			foreach($c in $txt.split(",")){
				if($c -ne "" -and $c -ne $null){
					if( $c -ne $null -and $this.hostTable.keys -notcontains $c.Trim() ){
						try{
							$ip = ([System.Net.Dns]::GetHostAddresses($c.Trim()).IPAddressToString | select -first 1);	
						}catch{
							$ip = ""
						}
						
						$this.hostTable.Add($c.Trim(), @{ IP = $ip; } )
					
					
					}
				}
			}
		}
		
		[Object[]] Get(){
			$this.hostTable = @{};
			 
			if( [GUI]::Get().window.findName('txtHosts').Text -ne $null){
				$this.parseTxt( [GUI]::Get().window.findName('txtHosts').Text ) | out-null
			}
			
			if( [GUI]::Get().window.findName('treeAD').SelectedItem.tag -ne $null){
				$this.parseOU( [GUI]::Get().window.findName('treeAD').SelectedItem.tag) | out-null
			}

			if($global:csts.objs.AD -ne $null){
				$global:csts.objs.AD.getCheckedItems()
				$global:csts.objs.AD.checkedItems | % {
					$this.parseOU( $_.tag ) | out-null
				}
			}
			
			return $this.hostTable;
		}
		
	}
}
Process{
	$global:csts.libs.add('Hosts', ([Hosts]::new()) ) | out-null
}
End{

}