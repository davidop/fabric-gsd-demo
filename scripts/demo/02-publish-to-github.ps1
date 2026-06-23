param(
    [Parameter(Mandatory=$true)][string]$RepoFullName,
    [switch]$Private
)

$visibility = if ($Private) { "--private" } else { "--public" }

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is required. Install gh or use docs/GITHUB_SETUP.md manual instructions."
}

git branch -M main
gh repo create $RepoFullName $visibility --source=. --remote=origin --push
