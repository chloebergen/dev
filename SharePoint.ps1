Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    
#Function to Get Permissions Applied on a particular Object, such as: Web or List
Function Get-Permissions([Microsoft.SharePoint.Client.SecurableObject]$Object)
{
    #Determine the type of the object
    Switch($Object.TypedObject.ToString())
    {
        "Microsoft.SharePoint.Client.Web"  { $ObjectType = "Site" ; $ObjectURL = $Object.URL; $ObjectTitle = $Object.Title }
        "Microsoft.SharePoint.Client.ListItem"
        {
            If($Object.FileSystemObjectType -eq "Folder")
            {
                $ObjectType = "Folder"
                #Get the URL of the Folder
                $Object.Retrieve("Folder")
                $Ctx.ExecuteQuery()
                $ObjectTitle = $Object.Folder.Name
                $ObjectURL = $("{0}{1}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''),$Object.Folder.ServerRelativeUrl)
            }
            Else #File or List Item
            {
                #Get the URL of the Object
                $Object.Retrieve("File")
                $Ctx.ExecuteQuery()
                If($Object.File.Name -ne $Null)
                {
                    $ObjectType = "File"
                    $ObjectTitle = $Object.File.Name
                    $ObjectURL = $("{0}{1}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''),$Object.File.ServerRelativeUrl)
                }
                else
                {
                    $ObjectType = "List Item"
                    $ObjectTitle = $Object["Title"]
                    #Get the URL of the List Item
                    $Object.ParentList.Retrieve("DefaultDisplayFormUrl")
                    $Ctx.ExecuteQuery()
                    $DefaultDisplayFormUrl = $Object.ParentList.DefaultDisplayFormUrl
                    $ObjectURL = $("{0}{1}?ID={2}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''), $DefaultDisplayFormUrl,$Object.ID)
                }
            }
        }
        Default
        {
            $ObjectType = "List or Library"
            $ObjectTitle = $Object.Title
            #Get the URL of the List or Library
            $Ctx.Load($Object.RootFolder)
            $Ctx.ExecuteQuery()           
            $ObjectURL = $("{0}{1}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''), $Object.RootFolder.ServerRelativeUrl)
        }
    }
   
    #Check if Object has unique permissions
    $Object.Retrieve("HasUniqueRoleAssignments")
    $Ctx.ExecuteQuery()
    $HasUniquePermissions = $Object.HasUniqueRoleAssignments
   
    #Get permissions assigned to the object
    $RoleAssignments = $Object.RoleAssignments
    $Ctx.Load($RoleAssignments)
    $Ctx.ExecuteQuery()
    
    #Loop through each permission assigned and extract details
    $PermissionCollection = @()
    Foreach($RoleAssignment in $RoleAssignments)
    {
        $Ctx.Load($RoleAssignment.Member)
        $Ctx.executeQuery()
    
        #Get the Principal Type: User, SP Group, AD Group
        $PermissionType = $RoleAssignment.Member.PrincipalType
    
        #Get the Permission Levels assigned
        $Ctx.Load($RoleAssignment.RoleDefinitionBindings)
        $Ctx.ExecuteQuery()
        $PermissionLevels = $RoleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name
 
        #Remove Limited Access
        $PermissionLevels = ($PermissionLevels | Where { $_ -ne "Limited Access"}) -join ","
        If($PermissionLevels.Length -eq 0) {Continue}
 
        #Get SharePoint group members
        If($PermissionType -eq "SharePointGroup")
        {
            #Get Group Members
            $Group = $Ctx.web.SiteGroups.GetByName($RoleAssignment.Member.LoginName)
            $Ctx.Load($Group)
            $GroupMembers= $Group.Users
            $Ctx.Load($GroupMembers)
            $Ctx.ExecuteQuery()
            If($GroupMembers.count -eq 0){Continue}
            $GroupUsers = ($GroupMembers | Select -ExpandProperty Title) -join ","
 
            #Add the Data to Object
            $Permissions = New-Object PSObject
            $Permissions | Add-Member NoteProperty Object($ObjectType)
            $Permissions | Add-Member NoteProperty Title($ObjectTitle)
            $Permissions | Add-Member NoteProperty URL($ObjectURL)
            $Permissions | Add-Member NoteProperty HasUniquePermissions($HasUniquePermissions)
            $Permissions | Add-Member NoteProperty Users($GroupUsers)
            $Permissions | Add-Member NoteProperty Type($PermissionType)
            $Permissions | Add-Member NoteProperty Permissions($PermissionLevels)
            $Permissions | Add-Member NoteProperty GrantedThrough("SharePoint Group: $($RoleAssignment.Member.LoginName)")
            $PermissionCollection += $Permissions
        }
        Else
        {
            #Add the Data to Object
            $Permissions = New-Object PSObject
            $Permissions | Add-Member NoteProperty Object($ObjectType)
            $Permissions | Add-Member NoteProperty Title($ObjectTitle)
            $Permissions | Add-Member NoteProperty URL($ObjectURL)
            $Permissions | Add-Member NoteProperty HasUniquePermissions($HasUniquePermissions)
            $Permissions | Add-Member NoteProperty Users($RoleAssignment.Member.Title)
            $Permissions | Add-Member NoteProperty Type($PermissionType)
            $Permissions | Add-Member NoteProperty Permissions($PermissionLevels)
            $Permissions | Add-Member NoteProperty GrantedThrough("Direct Permissions")
            $PermissionCollection += $Permissions
        }
    }
    #Export Permissions to CSV File
    $PermissionCollection | Export-CSV $ReportFile -NoTypeInformation -Append
}
   
#Function to get sharepoint online site permissions report
Function Generate-SPOSitePermissionRpt()
{   
[cmdletbinding()]
 
    Param 
    (   
        [Parameter(Mandatory=$false)] [String] $SiteURL,
        [Parameter(Mandatory=$false)] [String] $ReportFile,        
        [Parameter(Mandatory=$false)] [switch] $Recursive,
        [Parameter(Mandatory=$false)] [switch] $ScanItemLevel,
        [Parameter(Mandatory=$false)] [switch] $IncludeInheritedPermissions       
    ) 
    Try {
        #Get Credentials to connect
        $Cred= Get-Credential
    
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
   
        #Get the Web & Root Web
        $Web = $Ctx.Web
        $RootWeb = $Ctx.Site.RootWeb
        $Ctx.Load($Web)
        $Ctx.Load($RootWeb)
        $Ctx.ExecuteQuery()
   
        Write-host -f Yellow "Getting Site Collection Administrators..."
        #Get Site Collection Administrators
        $SiteUsers= $RootWeb.SiteUsers
        $Ctx.Load($SiteUsers)
        $Ctx.ExecuteQuery()
        $SiteAdmins = $SiteUsers | Where { $_.IsSiteAdmin -eq $true}
         
        $SiteCollectionAdmins = ($SiteAdmins | Select -ExpandProperty Title) -join ","
        #Add the Data to Object
        $Permissions = New-Object PSObject
        $Permissions | Add-Member NoteProperty Object("Site Collection")
        $Permissions | Add-Member NoteProperty Title($RootWeb.Title)
        $Permissions | Add-Member NoteProperty URL($RootWeb.URL)
        $Permissions | Add-Member NoteProperty HasUniquePermissions("TRUE")
        $Permissions | Add-Member NoteProperty Users($SiteCollectionAdmins)
        $Permissions | Add-Member NoteProperty Type("Site Collection Administrators")
        $Permissions | Add-Member NoteProperty Permissions("Site Owner")
        $Permissions | Add-Member NoteProperty GrantedThrough("Direct Permissions")
               
        #Export Permissions to CSV File
        $Permissions | Export-CSV $ReportFile -NoTypeInformation
   
        #Function to Get Permissions of All List Items of a given List
        Function Get-SPOListItemsPermission([Microsoft.SharePoint.Client.List]$List)
        {
            Write-host -f Yellow "`t `t Getting Permissions of List Items in the List:"$List.Title
  
            $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
            $Query.ViewXml = "<View Scope='RecursiveAll'><Query><OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy></Query><RowLimit Paged='TRUE'>$BatchSize</RowLimit></View>"
  
            $ItemCounter = 0
            #Batch process list items - to mitigate list threshold issue on larger lists
            Do { 
                #Get items from the list
                $ListItems = $List.GetItems($Query)
                $Ctx.Load($ListItems)
                $Ctx.ExecuteQuery()
            
                $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
   
                #Loop through each List item
                ForEach($ListItem in $ListItems)
                {
                    #Get Objects with Unique Permissions or Inherited Permissions based on 'IncludeInheritedPermissions' switch
                    If($IncludeInheritedPermissions)
                    {
                        Get-Permissions -Object $ListItem
                    }
                    Else
                    {
                        $ListItem.Retrieve("HasUniqueRoleAssignments")
                        $Ctx.ExecuteQuery()
                        If($ListItem.HasUniqueRoleAssignments -eq $True)
                        {
                            #Call the function to generate Permission report
                            Get-Permissions -Object $ListItem
                        }
                    }
                    $ItemCounter++
                    Write-Progress -PercentComplete ($ItemCounter / ($List.ItemCount) * 100) -Activity "Processing Items $ItemCounter of $($List.ItemCount)" -Status "Searching Unique Permissions in List Items of '$($List.Title)'"
                }
            } While ($Query.ListItemCollectionPosition -ne $null)
        }
 
        #Function to Get Permissions of all lists from the web
        Function Get-SPOListPermission([Microsoft.SharePoint.Client.Web]$Web)
        {
            #Get All Lists from the web
            $Lists = $Web.Lists
            $Ctx.Load($Lists)
            $Ctx.ExecuteQuery()
   
            #Exclude system lists
            $ExcludedLists = @("Access Requests","App Packages","appdata","appfiles","Apps in Testing","Cache Profiles","Composed Looks","Content and Structure Reports","Content type publishing error log","Converted Forms",
            "Device Channels","Form Templates","fpdatasources","Get started with Apps for Office and SharePoint","List Template Gallery", "Long Running Operation Status","Maintenance Log Library", "Images", "site collection images"
            ,"Master Docs","Master Page Gallery","MicroFeed","NintexFormXml","Quick Deploy Items","Relationships List","Reusable Content","Reporting Metadata", "Reporting Templates", "Search Config List","Site Assets","Preservation Hold Library"
            "Site Pages", "Solution Gallery","Style Library","Suggested Content Browser Locations","Theme Gallery", "TaxonomyHiddenList","User Information List","Web Part Gallery","wfpub","wfsvc","Workflow History","Workflow Tasks", "Pages")
             
            $Counter = 0
            #Get all lists from the web  
            ForEach($List in $Lists)
            {
                #Exclude System Lists
                If($List.Hidden -eq $False -and $ExcludedLists -notcontains $List.Title)
                {
                    $Counter++
                    Write-Progress -PercentComplete ($Counter / ($Lists.Count) * 100) -Activity "Processing Lists $Counter of $($Lists.Count) in $($Web.URL)" -Status "Exporting Permissions from List '$($List.Title)'"
 
                    #Get Item Level Permissions if 'ScanItemLevel' switch present
                    If($ScanItemLevel)
                    {
                        #Get List Items Permissions
                        Get-SPOListItemsPermission -List $List
                    }
 
                    #Get Lists with Unique Permissions or Inherited Permissions based on 'IncludeInheritedPermissions' switch
                    If($IncludeInheritedPermissions)
                    {
                        Get-Permissions -Object $List
                    }
                    Else
                    {
                        #Check if List has unique permissions
                        $List.Retrieve("HasUniqueRoleAssignments")
                        $Ctx.ExecuteQuery()
                        If($List.HasUniqueRoleAssignments -eq $True)
                        {
                            #Call the function to check permissions
                            Get-Permissions -Object $List
                        }
                    }
                }
            }
        }
   
        #Function to Get Web's Permissions from given URL
        Function Get-SPOWebPermission([Microsoft.SharePoint.Client.Web]$Web)
        {
            #Get all immediate subsites of the site
            $Ctx.Load($web.Webs) 
            $Ctx.executeQuery()
    
            #Call the function to Get permissions of the web
            Write-host -f Yellow "Getting Permissions of the Web: $($Web.URL)..." 
            Get-Permissions -Object $Web
   
            #Get List Permissions
            Write-host -f Yellow "`t Getting Permissions of Lists and Libraries..."
            Get-SPOListPermission($Web)
 
            #Recursively get permissions from all sub-webs based on the "Recursive" Switch
            If($Recursive)
            {
                #Iterate through each subsite in the current web
                Foreach ($Subweb in $web.Webs)
                {
                    #Get Webs with Unique Permissions or Inherited Permissions based on 'IncludeInheritedPermissions' switch
                    If($IncludeInheritedPermissions)
                    {
                        Get-SPOWebPermission($Subweb)
                    }
                    Else
                    {
                        #Check if the Web has unique permissions
                        $Subweb.Retrieve("HasUniqueRoleAssignments")
                        $Ctx.ExecuteQuery()
   
                        #Get the Web's Permissions
                        If($Subweb.HasUniqueRoleAssignments -eq $true)
                        {
                            #Call the function recursively                           
                            Get-SPOWebPermission($Subweb)
                        }
                    }
                }
            }
        }
   
        #Call the function with RootWeb to get site collection permissions
        Get-SPOWebPermission $Web
   
        Write-host -f Green "`n*** Site Permission Report Generated Successfully!***"
     }
    Catch {
        write-host -f Red "Error Generating Site Permission Report!" $_.Exception.Message
   }
}
   
#region ***Parameters***
$SiteURL="https://crescent.sharepoint.com/sites/marketing"
$ReportFile="C:\Temp\SitePermissionRpt.csv"
$BatchSize = 500
#endregion
 
#Call the function to generate permission report
Generate-SPOSitePermissionRpt -SiteURL $SiteURL -ReportFile $ReportFile
#Generate-SPOSitePermissionRpt -SiteURL $SiteURL -ReportFile $ReportFile -Recursive -ScanItemLevel -IncludeInheritedPermissions


#Read more: https://www.sharepointdiary.com/2018/09/sharepoint-online-site-collection-permission-report-using-powershell.html#ixzz89Kaki0ZM