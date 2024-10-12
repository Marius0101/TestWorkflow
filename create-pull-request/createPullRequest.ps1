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
    [psobject]$jsonBody = $body | ConvertTo-Json
    try{
        $response = Invoke-RestMethod -Uri $uri -Method $method -Headers $header -Body $jsonBody -ContentType $contentType
    }
    catch{
    [string]$errorResponse = @"
    
Houston, this is the problem. Please resolve it before trying again.
=======================================================================
Error Message: 
    $($_.Exception.Message)
=======================================================================
"@
        #Write-Error -Message $errorResponse -Category InvalidResult -ErrorId "APIError" -ErrorAction Stop
        Write-Error -Message $errorResponse -Category InvalidResult -ErrorAction "Stop"
        
        # Optionally, throw the error again if you want to stop execution
    }
    Write-Output "$response"
    return $response
}

# function Write-ScriptError {
#     param (
#         OptionalParameters
#     )
    
# }
#------------------------------------------------------------------------------[Dot-Sourcing]-----------------------------------------------------------------------------
trap{
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
    throw $Script:ErrorMsg
}
#-------------------------------------------------------------------------------[Execution]-------------------------------------------------------------------------------
$Script:listAssignees
$Script:listReviewers
$Script:listTeamReviewers
$Script:test
$Script:ErrorMsg = "The script fail check error mesage above for more information"
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

[hashtable]$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}
[hashtable]$Script:bodyVariables = @{
    "title" = $title
    "head" = $headBranch
    "base" = $baseBranch
    "body"= $body
    "maintainer_can_modify"=  $modifyBoolean
}
$responseCreatePull = Invoke-GitHubAPI `
    -uri $Script:Uri `
    -method Post `
    -header $headers `
    -body $Script:bodyVariables `
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

