$servidor = '192.168.1.1' 
$folder = '\\$servidor\send\'
$logOld = '\\$servidor\LogsDeScripts\Zip-LOGOLD.txt'
$log = '\\$servidor\LogsDeScripts\Zip-LOG.txt'
$tmp = '\\$servidor\LogsDeScripts\Zip\temp.txt'
$extension = '.zip'
$zipmove = '\\$servidor\LogsDeScripts\Zip\'
$date =  Get-date
$cont = 0

if ( Test-Path $log ){
	Get-Content($log) | Out-File $logOld
	$log | del
}

# Convert size bytes, KB, MB, GB, TB
function to-kmg {
	param ($bytes,$precision='0')
	foreach ($i in ("Bytes","KB","MB","GB","TB")) {
		if (($bytes -lt 1000) -or ($i -eq "TB")){
			$bytes = ($bytes).tostring("F0" + "$precision")
			return $bytes + " $i"
		}
		else {
			$bytes /= 1KB
		}
	}
}

$comandoLog = Get-ChildItem -Path $folder -Recurse -File | `
where {$_.extension -eq $extension} | `
sort length –Descending |`
ft   @{Name="Size";Expression={to-kmg  $_.Length  }},@{Name='Nome';Expression={$_.FullName}} -HideTableHeaders

if ( Test-Path $logOld ){
	echo "_____________________________________________________________________________________________________" | Out-File $logOld -append
	echo "Move date : $date" | Out-File $logOld -append
	if ($comandoLog -eq $null){
		echo "File not found" | Out-File $logOld -append
	}else{
		$cont = 1
		$comandoLog | Out-File $logOld -append
	}
}else {
	echo "List identified files:"| Out-File $logOld 
	echo "#####################################################################################################" | Out-File $logOld -append
	echo "Moving Date : $date" | Out-File $logOld -append
	if ($comandoLog -eq $null){
		echo "File not found" | Out-File $logOld -append
	}else{
		$cont = 1
		$comandoLog | Out-File $logOld -append
	}
}

if ( Test-Path $logOld ){
	$content = Get-Content($logOld)
	$content = $content |? {$_.trim() -ne "" }
	$content | Out-File $log
}
$zipmoveDate = $zipmove + $date.Day + "-" + $date.Month + "-" + $date.Year +"\"

if ($cont -ieq 1){
	mkdir $zipmoveDate
}

$lineBaseValueCont = 3
$null = ''
$comandoTmp = Get-ChildItem -Path $folder -Recurse -File | where {$_.extension -eq $extension} | `
sort length -Descending | ft @{Name='Nome';Expression={$_.FullName}} 
$comandoTmp > $tmp
$tmpMove = get-content $tmp | select-object -index $lineBaseValueCont

while ($tmpMove -ne $null){
	$arquivoMove = get-content $tmp | select-object -index $lineBaseValueCont 
	if ( Test-Path $arquivoMove ){ 
		Move-Item -Path $arquivoMove -Destination $zipmoveDate 
	}
	$lineBaseValueCont++
	$tmpMove = get-content $tmp | select-object -index $lineBaseValueCont
}

if ( Test-Path $tmp ){ 
	$tmp | del 
}

if ( Test-Path $logOld ){ 
	$logOld | del 
}

$cont = 0
