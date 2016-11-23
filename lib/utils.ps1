[CmdletBinding()]param()
begin{
	Class Utils{
		static [system.diagnostics.stopWatch] $timer
	
		static [TimeSpan] elapsedTimer(){
			return [Utils]::timer.elapsed;
		}
		
		static [void] startTimer(){
			[Utils]::timer = [system.diagnostics.stopWatch]::startNew()
		}
		
		static [void] stopTimer(){
			[Utils]::timer.Stop() | out-null
		}
		
		static [object] parseIni( $filePath ){
			$ini = @{}
			$CommentCount = 0
			$section = ""
			$name = ""
			switch -regex -file $filePath{
				"^\[(.+)\]" { # Section
					$section = $matches[1]
					$ini[$section] = @{}
					$CommentCount = 0
				}
				"^(;.*)$" { # Comment
					$value = $matches[1]
					$CommentCount = $CommentCount + 1
					$name = "Comment" + $CommentCount
					$ini[$section][$name] = $value
				} 
				"(.+?)\s*=(.*)" { # Key
					$name,$value = $matches[1..2]
					$ini[$section][$name] = $value
				}
			}
			return $ini
		}
		
	
		static [bool] IsFileLocked($filePath){
			$errs=$null;
			Rename-Item $filePath $filePath -ErrorVariable errs -ErrorAction SilentlyContinue
			return ($errs.Count -ne 0)
		}
	
	
		static [string] decodeProductKey( $data ){
			$productKey = $null

			$binArray = ($data)[52..66]
			$charsArray = "B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9"
			
			For ($i = 24; $i -ge 0; $i--) {
				$k = 0
				For ($j = 14; $j -ge 0; $j--) {
					$k = $k * 256 -bxor $binArray[$j]
					$binArray[$j] = [math]::truncate($k / 24)
					$k = $k % 24
				}
				$productKey = $charsArray[$k] + $productKey
				If (($i % 5 -eq 0) -and ($i -ne 0)) {
					$productKey = "-" + $productKey
				}
			}
						
			return $productKey
		}
		
		static [object[]] getEnums($type){
			return [System.Enum].GetValues($type)
		}
	
		static [bool] ContainsAny( [string]$s, [string[]]$items ){
			$matchingItems = @($items | ? { $s.Contains( $_ ) })
			return [bool]$matchingItems
		}
	
		static [string] toPrettyXml($xml){
			$stringWriter = new-object System.IO.StringWriter
			$xmlWriter = new-object System.xml.xmlTextWriter $stringWriter
			$xmlWriter.formatting = 'indented'
			$xmlWriter.indentation = 4
			$xml.WriteContentTo($xmlWriter)
			$xmlWriter.flush()
			$stringWriter.flush()
			return $StringWriter.ToString()
		}
		
		static [string] toTitleCase($val){
			$results = ""
			$val -split " " | % {
				$results += $_.substring(0,1).toUpper()+$_.substring(1)
			}
			return $results			
		}
		
		static [boolean] isBlank($val){
			if($val -eq "" -or $val -eq $null -or $val.getType() -like '*DBNULL*'){
				return $true
			}else{
				return $false
			}
		}
		
		static [string] processXslt( [string]$xmlPath,  [string] $xslPath, $argParms ){

			if($argParms -ne $null){
				$arglist = new-object System.Xml.Xsl.XsltArgumentList
				
				$argParms.keys | % {
					$arglist.AddParam($_, "", $argParms.$_);
				}
				
			}else{
				$arglist = $null;
			}
			
			$xmlContent = [string](gc $xmlPath)
			
			$inputstream = new-object System.IO.MemoryStream
			$xmlvar = new-object System.IO.StreamWriter($inputstream)
			$xmlvar.Write( $xmlContent)
			$xmlvar.Flush()
			$inputstream.position = 0
			$xmlObj = new-object System.Xml.XmlTextReader($inputstream)
			$output = New-Object System.IO.MemoryStream
			$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
			
			$reader = new-object System.IO.StreamReader($output)
			
			$resolver = New-Object System.Xml.XmlUrlResolver
			$xslSettings = New-Object System.Xml.Xsl.XsltSettings($false,$true)
			$xslSettings.EnableDocumentFunction = $true
			$xslt.Load($xslPath,$xslSettings, $resolver)
					
			$xslt.Transform($xmlObj, $arglist, $output)
			$output.position = 0
			$transformed = [string]$reader.ReadToEnd()
			$reader.Close()
			return $transformed
		}
		
		static getWebFile(
				[string] $url,
				[string] $outFile
			){
			
			$path = (split-path $outFile)
			if( (test-path $path) -eq $false){
				New-Item -ItemType Directory -Path $path -Force
			}
			if( (test-path $outfile) -eq $true){
				remove-item $outfile
			}
			(new-object system.net.webclient).DownloadFile($url,$outfile)
		}
		
		static [string] getFolderHash($folder){
			
			$files = dir $folder -Recurse |? { -not $_.psiscontainer }
		
			$allBytes = new-object System.Collections.Generic.List[byte]
			foreach ($file in $files){
				$allBytes.AddRange([System.IO.File]::ReadAllBytes($file.FullName))
				$allBytes.AddRange([System.Text.Encoding]::UTF8.GetBytes($file.Name))
			}
			$hasher = [System.Security.Cryptography.SHA1]::Create()
			$ret = [string]::Join("",$($hasher.ComputeHash($allBytes.ToArray()) | %{"{0:x2}" -f $_}))
			
			return $ret
		}
	
	}
}
Process{
		$global:Utils = [Utils]::new()
}
End{

}