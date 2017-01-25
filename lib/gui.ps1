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
	 
	 
			
			# [GUI]::Get().window.resources.themeDictionary.theme = $theme
			
			# [GUI]::Get().window.resources | gm |  ft | out-string | write-host 
			# [GUI]::Get().window.resources.themeDictionary.theme.themeBG |  fl | out-string | write-host 
			
			# $theme | fl | out-string | write-host
			# [GUI]::Get().window.findName('Ribbon') | fl | out-string | write-host
			
			
		}
		
		[void] sbarMsg($msg){
			[GUI]::Get().window.findName('sbarMsg').Text = $msg
		}
		
		[void] sbarProg($p){
			[GUI]::Get().window.findName('sbarPrg').Value = $p
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
		}
		
		
		[void] showModal($msg){
			[GUI]::Get().window.findName('modalBody').Text = $msg
			[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
		}
		
		[void] hideModal(){
			[GUI]::Get().window.findName('modalBody').Text = ''
			[GUI]::Get().window.findName('modalDialog').Visibility = 'Collapsed'
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
			}
		}
	}
}
Process{
	# $global:csts.libs.add('GUI', ([GUI]::new()) ) | out-null
}
End{

}