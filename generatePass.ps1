# Função para gerar os caracteres 
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
# Função para embaralhar os caracteres
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
# Variável para receber os caracteres gerados na função Get-RandomCharacters
$UPW = Get-RandomCharacters -length 3 -characters 'abcdefghikmnprstuvwxyz'
$UPW += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
$UPW += Get-RandomCharacters -length 2 -characters '23456789'
$UPW += Get-RandomCharacters -length 1 -characters '!@#$&'
 
# Variável para embaralhar na função Scramble-String
$UPW = Scramble-String $UPW
$UPWS = ConvertTo-SecureString -String $UPW -AsPlainText -Force
