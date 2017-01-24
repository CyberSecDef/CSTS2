[CmdletBinding()]param()
begin{
	Class ActiveDirectory{
		$checkedItems = @();
		
		ActiveDirectory(){
		
		}
		
		[object[]] getCheckedItems(){
			$this.checkedItems = @();
			$rootNode = [GUI]::Get().window.FindName('treeAD').Items[0]
			$this.ProcessNode($rootNode);
			return $this.checkedItems
		}
		
		processNode($node){
			foreach($child in $node.items){
				if ($child.header.IsChecked -eq $true){
					$this.checkedItems += $child;
				}
				$this.processNode($child);
			}
		}
		
		[void] loadLevel($selNode){
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
			
			$chk = new-object System.Windows.Controls.Checkbox
			$txt = new-object System.Windows.Controls.TextBlock
			$txt.Text = $obj.properties['name'][0]
			$chk.Content = $txt
		    $newNode.Header = $chk
			
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
		
		[void] buildAdTree(){
			$currentDomain = ([ADSI]"LDAP://RootDSE").Get("rootDomainNamingContext") -replace 'DC=','' -replace ',','.'
			$rootNode = [GUI]::Get().window.FindName('treeAD').Items[0]
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
			[GUI]::Get().window.FindName('treeAD').Items[0].IsExpanded = $true;
		}
	}
}
Process{

}
End{

}