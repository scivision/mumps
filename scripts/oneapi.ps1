$v="2025.0"

$Env:CC="icx"
$Env:FC="ifx"
$Env:CXX="icx"

& $Env:comspec /c '"%PROGRAMFILES(X86)%\Intel\oneAPI\$v\oneapi-vars.bat" && pwsh'
