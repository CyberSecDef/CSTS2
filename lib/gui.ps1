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
			if($this.window.FindName('contentContainer').content){
				$this.window.FindName('contentContainer').content = $null
			}
			$this.window.FindName('contentContainer').addChild($uc)
		}
		
		[void] ShowDialog(){
			$this.window.ShowDialog() | out-null
		}
		
		[void] GetColors(){
			if($global:csts.controllers['PixelData'] -ne $null){
				$c = $global:csts.controllers['PixelData'].Get()			
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