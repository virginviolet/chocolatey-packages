function Test-ValueNameBool($p, $n) {
    return [bool](Get-ItemProperty -Path $p -Name $n -ea 0)
}