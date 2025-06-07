
# -----------------
#    POWERSHELL
# -----------------
function list-my-aliases{
    Get-Alias | Where { $_.HelpUri -notmatch 'microsoft' } |  Sort-Object -Property Name
}
function list-my-aliases-by-letter {
     list-my-aliases | Group-Object -Property { $_.Name.Substring(0, 1) }
}
function list-my-alias-pretty{
    foreach ($let in list-my-aliases-by-letter) { 
        $letter = $let.Name.ToUpper()
        $concat = "";
        foreach ($als in $let.Group){
            $concat = "$concat $als,"
        }
        echo "    $letter      $concat"
    }
}


