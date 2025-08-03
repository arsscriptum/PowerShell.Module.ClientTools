

Get-FunctionList .\src\ | select -ExpandProperty Base -Unique | % {
   $id = $_
   $str1 = "`$Functions$id = Get-FunctionList .\src\ | Where Base -match `"\b(?:$id)\b`" | Select -ExpandProperty Name"
   $str1
}


Get-FunctionList .\src\ | select -ExpandProperty Base -Unique | % {
   $id = $_
   $str2 = @"
`$Functions{0}Text = ForEach(`$fn in `$Functions{0}){{
    `$DocUrl= Get-FunctionDocUrl `$fn
    `$DocUrl
}}
"@ -f $id
   $str2
}


Get-FunctionList .\src\ | select -ExpandProperty Base -Unique | % {
   $id = $_
   $str2 = @"

## Functions - {0}
`$Functions{0}Text

"@ -f $id
   $str2
}

