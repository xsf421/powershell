Set-ItemProperty -path HKCU:\software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name hidefileext -Value 0 -WhatIf
Set-ItemProperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -name hidden -value 0 -WhatIf
Copy-Item '\\mi\dfs\shared\noc team\pmills\TreeSize.exe' 'C:\Support' -WhatIf