# This script is used for adding a member of a github org as a collaborator to a list of repos, 
# a common task performed in bulk when working with outside contractors

$repos = @(clip-list)

$Members = ('tmcgeehan_guest')

Function Confirm-RepoDetails {
    #Helper function for sanitizing input
    [CmdletBinding()]
    Param (
        #Repo to get owner of
        [Parameter(Mandatory=$false, ValueFromPipeline)]
        $Repo,
        #Org, interpretations take precedence
        [Parameter(Mandatory=$false)]
        $Org   = 'shared'  
    )
    if ($Repo -match "github.dummyvalue.com") {
        Write-Verbose "Processing as url"
        if ($Repo -match "https://") {
            Write-Verbose "Full url"
            $repoUrl = $Repo
        }
        else{
            Write-Verbose "Expanding short url"
            $repoUrl = "https://$Repo"
        }
        $repoNameNodes = $repoUrl -split [Regex]::Escape("/")
        $Org   = $repoNameNodes[3]
        $Repo  = $repoNameNodes[4]
    }
    else {
        $repoUrl = "https://github.dummyvalue.com/$Org/$Repo"
    }
    $repoDetails = [PsCustomObject] @{
        Repo    = $Repo
        Org     = $Org
        RepoUrl = $repoUrl
    }
    return $repoDetails
}

$Repos
$RepoDetails = [System.Collections.Generic.List[Object]]::new()
$membersNeedingBaseAccess = [System.Collections.Generic.List[Object]]::new()

foreach ($repo in $Repos) {
   $RepoDetails.Add($(Confirm-RepoDetails $repo))
}

$ToGrant = [System.Collections.Generic.List[Object]]::new()
#only doing the corpsec CL if needed
foreach ($Member in $Members){
   $githubAccess = $null
   
   ##personal Tool required here, could easily be rewritten to just go by EmSam
   $user = entity $Member 
   $githubAccess = $user | Principal | Where-Object {$_.name -match "GH_restricted_group"}
   
   #This is convulted because this script was initially about setting up changelogs
   if (-not($githubAccess)){
       $membersNeedingBaseAccess.Add($Member)
   }
   if ($membersNeedingBaseAccess) {
       Write-Host 'Mike Virginio' -ForegroundColor Magenta
       Get-ChanglelogFormat -Member $Members -Resource $Resources
       "`n`r"
   }
   else{
       foreach ($Repo in $RepoDetails) {
           $setup =  [PSCustomObject] @{
               RepoName       = $Repo.Repo
               RepoURL        = $Repo.RepoUrl
               Collaborators  = "$($repo.RepoUrl)/settings/access"
               uriFragmentPath = "/repos/$($Repo.Org)/$($Repo.Repo)/collaborators/$($user.SamAccountName)"
           }

       foreach ($Member in $Members) {
           Add-Member -inputObject $setup -memberType NoteProperty -name $Member -value $false 
       }
       $ToGrant.Add($setup)
       Invoke-GHRestMethod -Method PUT -UriFragment $setup.uriFragmentPath -Verbose 
       } 
   }
}
