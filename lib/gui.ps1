[CmdletBinding()]param()
begin{
	Class GUI{
		static [GUI]$gui = $null;
		$window;
		
		GUI(){
			$xaml =  [xml]( iex ('@"' + "`n" + ( (gc "$($global:csts.execPath)/views/layouts/csts.xaml" ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			$this.window = Get-XAML( $xaml );
			$this.window.FindName('btnHostExpand').add_Click({
				[GUI]::Get().expandHost();
			})
			$this.window.findName('sbarRole').Text = $global:csts.Role;
			$this.window.findName('rgrpSpace').Width = $this.window.Width - 175;
			
			$this.window.add_SizeChanged( { 
			
			[GUI]::Get().window.findName('rgrpSpace').Width = $_.NewSize.width - 175 
			
			} )
		}
		
		[GUI] static Get(  ){
			if( [GUI]::GUI -eq $null -or $global:csts.isActive -eq $false){
				[GUI]::GUI = [GUI]::new( );
			}

			return [GUI]::GUI
		}
		
		[void] changeTheme($theme){
			$xaml =  [xml]( iex ('@"' + "`n" + ( (gc "$($global:csts.execPath)\views\themes\$($theme)" ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			$theme = Get-XAML( $xaml );
			[GUI]::Get().window.resources.MergedDictionaries.Clear();
			[GUI]::Get().window.resources.MergedDictionaries.Add($theme);
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] sbarMsg($msg){
			[GUI]::Get().window.findName('sbarMsg').Text = $msg
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] sbarProg($p){
			[GUI]::Get().window.findName('sbarPrg').Value = $p
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] expandHost(){
			$windowWidth = ([GUI]::Get().window.width)
			if( ([GUI]::Get().window.findName('gridContent').ColumnDefinitions[2].width.value) -lt 200){				
				[GUI]::Get().window.findName('gridContent').ColumnDefinitions[2].width = 200;
				[GUI]::Get().window.findName('btnHostExpand').Content = '>>>'
			}else{
				[GUI]::Get().window.findName('gridContent').ColumnDefinitions[2].width = 25;
				[GUI]::Get().window.findName('btnHostExpand').Content = '<<<'
			}
		}
		
		[void] ShowContent($path){
			$content = [xml]( iex ('@"' + "`n" + ( (gc "$($global:csts.execpath)/$($path)" ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			$uc = Get-XAML( $content )
			
			try{
				if([GUI]::Get().window.FindName('contentContainer').FindName( 'UC' )){
					[GUI]::Get().window.FindName('contentContainer').UnregisterName( 'UC' )
				}
			}catch{
				
			}
			[GUI]::Get().window.FindName('contentContainer').children.clear()
			[GUI]::Get().window.FindName('contentContainer').addChild($uc)
			[GUI]::Get().window.FindName('contentContainer').RegisterName( 'UC', $uc )
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		
		[void] showModal([System.Object[]]$msg){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Collapsed'
			}
			
			[GUI]::Get().window.findName('modalPanel').child.children.clear()
			
			foreach($m in $msg){
				$pbar = new-object "system.windows.controls.ProgressBar"
				$pbar.height = 15
				$pbar.width = 500
				$pbar.value = $m.Progress
				[GUI]::Get().window.findName('modalPanel').child.children.Add($pbar)
				
				$textBlock = new-object "system.windows.controls.textblock"
				$textBlock.FontSize = 18
				$textBlock.Text = $m.Text
				[GUI]::Get().window.findName('modalPanel').child.children.Add($textBlock)
			}
			
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] showModal([String]$msg){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Collapsed'
			}
			[GUI]::Get().window.findName('modalBody').Text = $msg
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		[void] hideModal(){
			[GUI]::Get().window.findName('modalBody').Text = ''
			[GUI]::Get().window.findName('modalDialog').Visibility = 'Collapsed'
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] ShowDialog(){
			if(! [GUI]::Get().window.IsVisible){
				[GUI]::Get().window.Icon = "$($global:csts.execpath)/images/lock.png"
				if($global:csts.safe -eq $true){
					[GUI]::Get().window.ShowDialog() | out-null
				}else{
					[GUI]::Get().window.Add_Closing({[System.Windows.Forms.Application]::Exit(); Stop-Process $pid})
					$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' 
					$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru 
					$asyncwindow::ShowWindowAsync((Get-Process -PID $global:pid).MainWindowHandle, 0) | out-null

					[System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop([GUI]::Get().window)
					[GUI]::Get().window.Show()
					[GUI]::Get().window.Activate()
					$appContext = New-Object System.Windows.Forms.ApplicationContext 
					[void][System.Windows.Forms.Application]::Run($appContext)
				}
			}
		}
		
		[void] GetColors(){
			if($global:csts.controllers.developer.PixelData -ne $null){
				$c = $global:csts.controllers['developer'].PixelData.Get()			
				[GUI]::Get().window.FindName("Color").Background = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
				[GUI]::Get().window.FindName('lblHtml').Text = "#" + $('{0:X2}' -f $c.R) + ('{0:X2}' -f $c.G) + ('{0:X2}' -f $c.B);
				[System.Windows.Forms.Application]::DoEvents()  | out-null
			}
		}
	}
}
Process{
	# $global:csts.libs.add('GUI', ([GUI]::new()) ) | out-null
}
End{

}