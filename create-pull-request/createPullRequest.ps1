#-------------------------------------------------------------------------------[Parameters]-------------------------------------------------------------------------------
param(
    [Parameter(Mandatory)]
    [string]
    $token,
    [Parameter(Mandatory)]
    [string]
    $owner,
    [Parameter(Mandatory)]
    [string]
    $repo,
    [Parameter(Mandatory)]
    [string]
    $baseBranch,
    [Parameter(Mandatory)]
    [string]
    $headBranch,
    [string]
    $title,
    [string]
    $body,
    [string]
    $modify,
    [string]
    $assignees,
    [string]
    $reviewers,
    [string]
    $teamReviewers
)
#-------------------------------------------------------------------------------[Functions]-------------------------------------------------------------------------------
function ConvertTo-Array{
    param (
        # Parameter help description
        [string]
        $inputString
    )
    if([string]::IsNullOrEmpty($inputString)){
        return @()
    }
    $list = $inputString -split "\s+"| Where-Object { $_ -ne "" }
    return $list
}
function Invoke-GitHubAPI{
    param (
        [string]
        $uri,
        [string]
        $method,
        [hashtable]
        $header,
        [hashtable]
        $body,
        [string]
        $contentType
    )
    [string]::$jsonHeader= $header | ConvertTo-Json -Depth 3
    [string]::$jsonBody = $body | ConvertTo-Json -Depth 3
    $response = Invoke-RestMethod -Uri $uri -Method $method -Headers $jsonHeader -Body $jsonBody -ContentType $contentType
    Write-Output($response)
    return $response
}
#------------------------------------------------------------------------------[Dot-Sourcing]-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------[Execution]-------------------------------------------------------------------------------
$Script:listAssignees
$Script:listReviewers
$Script:listTeamReviewers

if ([string]::IsNullOrEmpty($title)) {
    $title = "Merge $baseBranch branch into the $headBranch branch"
}
if (($modify -ne "true") -and  ($modify -ne "false")) {
    [string]$error = @'
Houston, we have a problem. 
---------------------------------------------
Error Message:
    The modify parameter should be set on true or false.
'@
    Write-Error -Message $error  -ErrorAction Stop
}
$modifyBoolean = [System.Convert]::ToBoolean($modify) 
$Script:listAssignees = ConvertTo-Array -inputString $assignees
$Script:listReviewers = ConvertTo-Array -inputString $reviewers
$Script:listTeamReviewers = ConvertTo-Array -inputString $teamReviewers
$Script:Uri = "https://api.github.com/repos/$owner/$repo/pulls"

$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}
$APIbody = @{
    "title" = $title
    "head" = $headBranch
    "base" = $baseBranch
    "body"= $body
    "maintainer_can_modify"=  $modifyBoolean
}
$jsonBody = ($APIbody | ConvertTo-Json)
Write-Output $jsonBody
$response = Invoke-GitHubAPI `
    -uri $Script:Uri `
    -method Post `
    -header $headers `
    -body $APIbody `
    -contentType "application/json"

foreach($assignee in $Script:listAssignees){
    Write-Output "----"
    Write-Output "Assign:$assignee"
}

foreach($reviewer in $listReviewers){
    Write-Output "----"
    Write-Output "Reviewer:$reviewer"
}
# try {
# $result = [System.Convert]::ToBoolean($a) 
# } catch [FormatException] {
# $result = $false
# } 
# write-output $result

