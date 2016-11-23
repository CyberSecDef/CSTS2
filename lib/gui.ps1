[CmdletBinding()]param()
begin{
	Class GUI{
		[String] test(){
			return "test"
		}
		[String] renderTpl($tpl, $vars){
		
			$vars['pwd'] = $pwd
				
			$html = ( (gc "$($pwd)\views\$($tpl)") -join "`r`n" ) -replace '@""','@"'

			while($html -like '*$[a-zA-Z]*' -or $html -like "*`{`{[a-zA-Z]*`}`}*" -or $html -like '*\[\[(.+?)\]\]*' ){

				$html = $global:ExecutionContext.InvokeCommand.ExpandString( $html )

				#get page includes
				$html -match '\[\[([a-zA-Z0-9\.\\/]+?)\]\]' | out-null;
				if($matches){
					[regex]::matches( $html, '\[\[([a-zA-Z0-9\.\\/]+?)\]\]' ) | %{
						$html = $html.replace("[[$($_.groups[1].value)]]", ( (gc "$(pwd)\$($_.groups[1].value)") -join "`r`n") )
					}
				}
				
				$html = $html -replace '{{([a-zA-Z0-9_\.]+?)}}', '`$(`$vars[''$1''])'
			}			
			return $html
		}
		
	}
}
Process{
	$global:GUI = [GUI]::new()
}
End{

}