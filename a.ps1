# Parameters
$commitList = @(
    "21d9a2e",
    "a1b9bb1",
    "5799288"
)
$newAuthorName = "Alok Nigam"
$newAuthorEmail = "aloknigam@microsoft.com"

# Function to change author for a single commit
function Change-GitCommitAuthor {
    param (
        [string]$CommitHash,
        [string]$AuthorName,
        [string]$AuthorEmail
    )

    git rebase -i $CommitHash^
    # In the editor, change 'pick' to 'edit' for the target commit, save and exit

    git commit --amend --author="$AuthorName <$AuthorEmail>" --no-edit
    git rebase --continue
}

# Loop through each commit hash and update author
foreach ($commit in $commitList) {
    Write-Host "Processing commit $commit"
    Change-GitCommitAuthor -CommitHash $commit -AuthorName $newAuthorName -AuthorEmail $newAuthorEmail
}

Write-Host "All specified commits processed. If you have already pushed, force-push is required:"
Write-Host "git push --force-with-lease"
