$v="2025.0"

$Env:CC="icx"
$Env:FC="ifx"
$Env:CXX="icx"

& $Env:COMSPEC /c "`"${Env:ProgramFiles(x86)}\Intel\oneAPI\$v\oneapi-vars.bat`" && pwsh"
