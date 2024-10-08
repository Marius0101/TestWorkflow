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
    [string[]]
    $assignees,
    [string[]]
    $reviewers,
    [string[]]
    $teamReviewers
)
#-------------------------------------------------------------------------------[Functions]-------------------------------------------------------------------------------
#------------------------------------------------------------------------------[Dot-Sourcing]-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------[Execution]-------------------------------------------------------------------------------
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

foreach($assignee in $assignees){
    Write-Output "----"
    Write-Output "Assign:$assignee"
}

foreach($reviewer in $reviewers){
    Write-Output "----"
    Write-Output "Reviewer:$reviewer"
}


