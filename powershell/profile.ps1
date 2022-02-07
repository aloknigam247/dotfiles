# Auto Update
cd ~/dotfiles
git pull
$git_status = git status

if ($git_status) {
    $dt = Get-Date -Format "dd-MM-yyyy"
    git add .
    git commit -m "$dt updates"
    git push
}

cd -

# Aliases
Set-Alias -Name v -Value nvim