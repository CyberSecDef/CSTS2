[CmdletBinding()]param()
begin{
	Class GUI{
		static [GUI]$gui = $null;
		$window;
		
		GUI(){
			$this.window = $this.parseXaml( "$($global:csts.execPath)/views/layouts/csts.xaml" )
			$this.window.FindName('btnHostExpand').add_Click({
				[GUI]::Get().expandHost();
			})
			$this.window.findName('sbarRole').Text = $global:csts.Role;
			$this.window.findName('rgrpSpace').Width = $this.window.Width - 175;
			
			$this.window.add_SizeChanged( { 
				[GUI]::Get().window.findName('rgrpSpace').Width = $_.NewSize.width - 175 
			} )
		}
		
		[object] parseXaml( $xamlPath ){
			$xaml =  [xml]( iex ('@"' + "`n" + ( (gc $xamlPath ) -replace "{{{pwd}}}",$global:csts.execPath ) + "`n" + '"@') )
			return ( Get-XAML( $xaml ) );
		}
		
		[GUI] static Get(  ){
			if( [GUI]::GUI -eq $null -or $global:csts.isActive -eq $false){
				[GUI]::GUI = [GUI]::new( );
			}

			return [GUI]::GUI
		}

		[void] showMessage($msg){
			[System.Windows.MessageBox]::Show($msg);
		}
		
		[void] changeTheme($theme){
			$theme = [GUI]::Get().parseXaml( "$($global:csts.execPath)\views\themes\$($theme)" )
			
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
			$uc = [GUI]::Get().parseXaml( "$($global:csts.execpath)/$($path)" )
			
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
		
		[void] cboSelectItem($cbo, $item){
			$i = 0
			$cbo.Items | % {
				if($item -eq $_.id){
					$cbo.selectedIndex = $i
				}
				$i++
			}
		}
		
		[void] ShowContent($path, $viewModel){
			
			if($viewModel -ne $null){
				[GUI]::Get().window.DataContext = $viewModel
			}
			$uc = [GUI]::Get().parseXaml( "$($global:csts.execpath)/$($path)" )
			
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
		
		[void] showModalObject($obj){
			switch($obj.Type){
				"Progress" {
					[GUI]::Get().window.findName('modalPanel').Height += 35
					$pbar = new-object "system.windows.controls.ProgressBar"
					$pbar.height = 15
					$pbar.width = 500
					$pbar.value = $obj.Progress
					$pbar.margin = "0,0,0,10"
					[GUI]::Get().window.findName('modalPanel').child.children.Add($pbar)
					
					$textBlock = new-object "system.windows.controls.textblock"
					$textBlock.FontSize = 14
					$textBlock.Text = $obj.Text
					$textBlock.Name = $obj.Name
					[GUI]::Get().window.findName('modalPanel').child.children.Add($textBlock)
				}
				"Textbox" {
					[GUI]::Get().window.findName('modalPanel').Height += 35
					$grid = new-object "system.windows.controls.grid"
					$grid.Margin = 4
					$grid.width = 590
					
					$gc1 = new-object "system.windows.controls.ColumnDefinition"
					$gc1.Width = 100
					$gc2 = new-object "system.windows.controls.ColumnDefinition"
					$gc2.Width = 470
					$grid.ColumnDefinitions.Add($gc1)
					$grid.ColumnDefinitions.Add($gc2)
					
					$label = new-object "system.windows.controls.label"
					$label.width = "100"
					
					$label.Content = $obj.label
					$label.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
					
					$grid.Children.Add($label)
					
					$Textbox = new-object "system.windows.controls.Textbox"
					$Textbox.FontSize = 14
					$Textbox.Text = $obj.Text
					$Textbox.Name = $obj.Name
					$Textbox.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
					
					
					$grid.Children.Add($Textbox)
					[GUI]::Get().window.findName('modalPanel').child.children.Add($grid)
				}
				"Actions" {
					[GUI]::Get().window.findName('modalPanel').Height += 35
					$grid = new-object "system.windows.controls.grid"
					$grid.Margin = 4
					$grid.width = 575
					
					$gc1 = new-object "system.windows.controls.ColumnDefinition"
					$gc1.Width = '*'
					$gc2 = new-object "system.windows.controls.ColumnDefinition"
					$gc2.Width = 'Auto'
					$grid.ColumnDefinitions.Add($gc1)
					$grid.ColumnDefinitions.Add($gc2)
					
					$stack = new-object "system.windows.controls.stackpanel"
					$stack.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
					$stack.Orientation = 'Horizontal'
					
					$btnExec = new-object "system.windows.controls.button"
					$btnExec.Style = [GUI]::Get().window.findName('UC').FindResource("btnPrimary")
					$btnExec.HorizontalAlignment="Right"
					
					$btnExec.FontSize = 14
					if( $obj.Execute -ne $null ){
						$btnExec.add_click( ($obj.Execute) )
					}
					$btnExec.Width = 150
					$btnExec.Content = "Execute"
					$btnExec.Name = "modalWindowExec"
					$btnExec.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
					$stack.Children.Add($btnExec)
					
					$btnCancel = new-object "system.windows.controls.button"
					$btnCancel.Style = [GUI]::Get().window.findName('UC').FindResource("btnDefault")
					$btnCancel.HorizontalAlignment="Right"
					$btnCancel.Width = 150
					$btnCancel.FontSize = 14
					$btnCancel.Content = "Cancel"
					$btnCancel.Name = "modalWindowExec"
					$btnCancel.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
					
					$btnCancel.add_click({[GUI]::Get().hideModal()})
					$stack.Children.Add($btnCancel)
					$grid.Children.Add($stack)
					
					[GUI]::Get().window.findName('modalPanel').child.children.Add($grid)
				}
				
				"ComboBox" {
					[GUI]::Get().window.findName('modalPanel').Height += 35
					$grid = new-object "system.windows.controls.grid"
					$grid.Margin = 4
					$grid.width = 590
					
					$gc1 = new-object "system.windows.controls.ColumnDefinition"
					$gc1.Width = 100
					$gc2 = new-object "system.windows.controls.ColumnDefinition"
					$gc2.Width = 470
					$grid.ColumnDefinitions.Add($gc1)
					$grid.ColumnDefinitions.Add($gc2)
					
					$label = new-object "system.windows.controls.label"
					$label.width = "100"
					
					$label.Content = $obj.label
					$label.SetValue([Windows.Controls.Grid]::ColumnProperty,0)
					
					$grid.Children.Add($label)
					
					$ComboBox = new-object "system.windows.controls.ComboBox"
					$comboBox.Name = $obj.Name
					$comboBox.IsEditable = $true
					$ComboBox.FontSize = 14
					
					$obj.Values | % { 
						$item = new-object "system.windows.controls.ComboboxItem"
						$item.Content = $_.text
						$item.tag = $_.value
						if($item.tag -eq $obj.Selected){
							$item.IsSelected = $true;
						}
						$ComboBox.Items.Add( $item ) 
					}
					
					$ComboBox.SetValue([Windows.Controls.Grid]::ColumnProperty,1)
					$grid.Children.Add($ComboBox)

					[GUI]::Get().window.findName('modalPanel').child.children.Add($grid)
				}
			}
		}
		
		[Object[]] findChildren($obj){
		
			$children = @()
			$obj.child.children | % { $children += $_ }

			$children | % {
				$_.children | % { $children += $_ }
			}
			
			return $children
		}
		
		[void] showModal([System.Object[]]$msg, [String]$header){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Collapsed'
			}
			
			[GUI]::Get().window.findName('modalHeader').Text = $header
			[GUI]::Get().window.findName('modalPanel').child.children.clear()
			[GUI]::Get().window.findName('modalPanel').Height = 15
			$msg | % { $this.showModalObject( $_ ) }
				
			[GUI]::Get().window.findName('modalFooter').Text = $header
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] showModal([System.Object[]]$msg, [String]$header, [String]$footer){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Collapsed'
			}
			
			[GUI]::Get().window.findName('modalHeader').Text = $header
			[GUI]::Get().window.findName('modalPanel').child.children.clear()
			[GUI]::Get().window.findName('modalPanel').Height = 15
			$msg | % { $this.showModalObject( $_ ) }
			
			[GUI]::Get().window.findName('modalFooter').Text = $footer
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
			
			[GUI]::Get().window.findName('modalHeader').Text = "Please Wait..."
			[GUI]::Get().window.findName('modalPanel').child.children.clear()
			[GUI]::Get().window.findName('modalPanel').Height = 15
			$msg | % { $this.showModalObject( $_ ) }
			
			[GUI]::Get().window.findName('modalFooter').Text = "Please Wait..."
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
			[GUI]::Get().window.findName('modalHeader').Text = "Please Wait..."
			[GUI]::Get().window.findName('modalBody').Text = $msg
			[GUI]::Get().window.findName('modalFooter').Text = "Please Wait..."
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] showModal([String]$msg, [String]$header){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Collapsed'
			}
			[GUI]::Get().window.findName('modalHeader').Text = $header
			[GUI]::Get().window.findName('modalBody').Text = $msg
			[GUI]::Get().window.findName('modalFooter').Text = $header
			[System.Windows.Forms.Application]::DoEvents()  | out-null
		}
		
		[void] showModal([String]$msg, [String]$header, [String]$footer){
			if( [GUI]::Get().window.findName('modalDialog').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalDialog').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalBody').Visibility -ne 'Visible'){
				[GUI]::Get().window.findName('modalBody').Visibility = 'Visible'
			}
			if( [GUI]::Get().window.findName('modalPanel').Visibility -eq 'Visible'){
				[GUI]::Get().window.findName('modalPanel').Visibility = 'Collapsed'
			}
			[GUI]::Get().window.findName('modalHeader').Text = $header
			[GUI]::Get().window.findName('modalBody').Text = $msg
			[GUI]::Get().window.findName('modalFooter').Text = $footer
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