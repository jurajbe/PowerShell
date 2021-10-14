#Created by Juraj Benak juraj@jurajbenak.com

#getting all the groups, filter by searchbase, name or both
$groups = Get-ADGroup -LDAPFilter "(name=*)" -SearchBase "OU=Security Groups,DC=company,DC=local"

$datetime = get-date -UFormat "%B-%d-%H%M"

#placing the file name and its path into a variable
$file = "$datetime ACLreport.csv"
$file

#creating new file to export the report to
New-Item -Path c:\temp -Name $file -ItemType "file" -Value "" -Force

$single_group_member_name = ""

$group_name = "" #Get-ADGroup -Identity $group.samAccountName -Properties Name,Description,managedBy 
$group_owner_name = "" #Get-ADUser -Identity $group_name.managedBy -Properties Name

#creating own object to add each group in
[hashtable]$objectProperty = @{}
$objectProperty.Add('ACL Group Name',$group_name.Name)
$objectProperty.Add('Description',$group_name.Description)
$objectProperty.Add('Members',$group_owner_name.Name)
$objectProperty.Add('Managed By',$group_name.managedBy)
$myObject = New-Object -TypeName psobject -Property $objectProperty 

#loop for each group
foreach ($group in $groups) {
    $group_name = Get-ADGroup -Identity $group.samAccountName -Properties Name,Description,managedBy 
    $group_owner_name = Get-ADUser -Identity $group_name.managedBy -Properties Name
    $group_member = Get-ADGroupMember -Identity $group.SamAccountName

    #loop for each member so I get them all
    foreach ($single_group_member in $group_member) {
          $myObject.Members += $single_group_member.name 
          $myObject.Members += ","

    }
    $myObject.'ACL Group Name' = $group_name.Name
    $myObject.Description = $group_name.Description
    $myObject.'Managed By' = $group_owner_name.Name
   
    #exporting to file
    Write-output $myObject | Export-Csv $file -Append
    
    #resetting values for the next loop
    $single_group_member_name = ""
    $myObject.Members = ""
    $myObject.'Managed By' = "empty"
    $myobject.'ACL Group Name' = ""
    $myObject.Description = ""
    $group_owner_name = ""
}
