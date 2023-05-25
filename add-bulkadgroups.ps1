# This is simple script that takes in two columns from the clipboard, 
# Column A of SamAccountNames and Column B of AD Security Groups, 
# and grants the corresponding group from B to A

$sheet = Get-Clipboard
$sheet = $sheet -split "`n"
foreach ($row in $sheet) {
    $row = $row -split '\s',2
    Add-ADGroupMember -Identity $row[1].ToString() -Members $row[0].ToString() -Verbose 
    "Added " + $row[0] + " to the group " + $row[1] 
    " "
}   