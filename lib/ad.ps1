[CmdletBinding()]param()
begin{
	Class ActiveDirectory{
		ActiveDirectory(){
		
		}
		
		[void] adLoadLevel($selNode){
			#get rid of the null node
			$selNode.items.clear()
			$adNode = new-object directoryservices.directoryentry "LDAP://$($selNode.tag)"
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $adNode
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*//OU=*'}
			
			$ous | sort { $_.Path } | % {
				$this.addNode($selNode,$_)
			}
		}
		
		[void] addNode($RootNode, $obj){
	        $newNode = new-object System.Windows.Controls.TreeViewItem
			
		    $newNode.Tag = $obj.properties['distinguishedname'][0]
		    $newNode.Header = $obj.properties['name'][0]
			
			If ($this.adNodeHasChildren($obj)){
				$newNode.Items.Add('') | Out-Null
			}
			
	        $RootNode.Items.Add($newNode) | Out-Null 
		}
		
		[bool] adNodeHasChildren($node){
			
			$adNode = new-object directoryservices.directoryentry $node.path
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $adNode
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*OU=*'}
			
			if($ous.length -gt 0){
				return $true
			}else{
				return $false
			}
		}
		
		[void] builtAdTree(){
			$currentDomain = ([ADSI]"LDAP://RootDSE").Get("rootDomainNamingContext") -replace 'DC=','' -replace ',','.'
			$rootNode = $global:csts.libs.gui.window.FindName('treeAD').Items[0]
			$rootNode.header = $currentDomain
			
			#add children under root node
			$prefix = "LDAP://"
			$query = "$($prefix)$($currentDomain)"
			$root = new-object directoryservices.directoryentry $query
            $selector = new-object directoryservices.directorysearcher
            $selector.searchroot = $root
            $selector.SearchScope  = "OneLevel"
            $ous = $selector.findall() | ? { $_.path -like '*OU=*'}
            $ous | sort { $_.Path } | % {
				$this.addNode($rootNode,$_)
			}

			$global:csts.libs.gui.window.FindName('treeAD').Items[0].IsExpanded = $true;
		}
		
	}
}
Process{
	$global:csts.libs.add('AD', ( [ActiveDirectory]::new() ) ) | out-null
}
End{

}