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
			
			$ds.FindAll() | % {
				$adHost = [string]($_.Properties['dnshostname'])
				
				if(($adHost.indexOf(".")) -ne -1){
					if(($adHost.indexOf(".")) -gt 0){
						$adHost = $adHost.substring(0,$adHost.indexOf("."))
					}
				}
			
				$adHost = $adHost.trim()
				
				if($global:Utils::isBlank($adHost) -eq $false){
					if( $adHost -ne $null -and $this.hostTable.keys -notcontains $adHost ){
						$this.hostTable.Add( $adHost, @{"Software" = @(); "Stigs" = @();} ) | out-null
					}
				}
			} | out-null
		}
		
		[void] parseTxt( $txt ){
			$txt = $txt -replace "`r", "" -replace "`n","," -replace ' ',''
			foreach($c in $txt.split(",")){
				if($c -ne "" -and $c -ne $null){
					if( $c -ne $null -and $this.hostTable.keys -notcontains $c.Trim() ){
						$this.hostTable.Add($c.Trim(), @{"Software" = @(); "Stigs" = @(); } )
					}
				}
			}
		}
		
		[Object[]] Get(){
			$this.hostTable = @{};
			 
			if( $global:csts.window.findName('txtHosts').Text -ne $null){
				$this.parseTxt( $global:csts.window.findName('txtHosts').Text ) | out-null
			}
			
			if( $global:csts.window.findName('treeAD').SelectedItem.tag -ne $null){
				$this.parseOU($global:csts.window.findName('treeAD').SelectedItem.tag) | out-null
			}
			
			return $this.hostTable;
		}
		
	}
}
Process{
	$global:Hosts = [Hosts]::new()
}
End{

}