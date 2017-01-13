[CmdletBinding()]param()
begin{
	Class GUI{
		$window;
		
		GUI(){
			$xaml =  [xml]( iex ('@"' + "`n" + ( (gc "$($global:csts.execPath)/views/layouts/csts.xaml" ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			$this.window = Get-XAML( $xaml );
			$this.window.FindName('btnHostExpand').add_Click({
				$global:csts.libs.gui.expandHost();
			})
			$this.window.findName('sbarRole').Text = $global:csts.Role;
		}
		
		[void] sbarMsg($msg){
			$this.window.findName('sbarMsg').Text = $msg
			if($msg.length -gt 0){
				$this.window.findName('txtLog').Text += "$(get-date -format 'HH:mm:ss') - $($msg)`n"
			}
		}
		[void] sbarProg($p){
			$this.window.findName('sbarPrg').Value = $p
		}
		
		[void] expandHost(){
			$windowWidth = ($this.window.width)
			if( ($this.window.findName('gridContent').ColumnDefinitions[2].width.value) -lt 200){				
				$this.window.findName('gridContent').ColumnDefinitions[2].width = 200;
				$this.window.findName('btnHostExpand').Content = '>>>'
			}else{
				$this.window.findName('gridContent').ColumnDefinitions[2].width = 25;
				$this.window.findName('btnHostExpand').Content = '<<<'
			}
		}
		
		[void] ShowContent($path){
			$content = [xml]( iex ('@"' + "`n" + ( (gc "$($global:csts.execpath)/$($path)" ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			$uc = Get-XAML( $content )
			
			try{
				if($this.window.FindName('contentContainer').FindName( 'UC' )){
					$this.window.FindName('contentContainer').UnregisterName( 'UC' )
				}
			}catch{
				
			}
			$this.window.FindName('contentContainer').children.clear()
			$this.window.FindName('contentContainer').addChild($uc)
			$this.window.FindName('contentContainer').RegisterName( 'UC', $uc )
			
			
		}
		
		[void] ShowDialog(){
			if(! $this.window.IsVisible){
				$this.window.ShowDialog() | out-null
			}
		}
		
		[void] GetColors(){
			if($global:csts.controllers.developer.PixelData -ne $null){
				$c = $global:csts.controllers['developer'].PixelData.Get()			
				$global:csts.libs.gui.window.FindName("Color").Background = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
				$global:csts.libs.gui.window.FindName('lblHtml').Text = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
			}
		}
	}
}
Process{
	$global:csts.libs.add('GUI', ([GUI]::new()) ) | out-null
}
End{

}