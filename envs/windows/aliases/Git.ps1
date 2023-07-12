# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

<#
.SYNOPSIS
	Get current git branch.
#>
function Get-Git-CurrentBranch {
  end {
    git symbolic-ref --quiet HEAD *> $null

    if ($LASTEXITCODE -eq 0) {
      return git rev-parse --abbrev-ref HEAD
    }

    return
  }
}

function Get-Git-MainBranch {
  end {
    git rev-parse --git-dir *> $null

    if ($LASTEXITCODE -ne 0) {
      return
    }

    $Branches = @('main', 'trunk')

    foreach ($Branch in $Branches) {
      & git show-ref -q --verify refs/heads/$Branch

      if ($LASTEXITCODE -eq 0) {
        return $Branch
      }
    }

    return 'master'
  }
}

function Format-AliasDefinition {
  param (
    [Parameter(Mandatory = $true)][string]$Definition
  )

  process {
    $DefinitionLines = $Definition.Trim() -split "`n" | ForEach-Object {
      $Line = $_.TrimEnd()

      # Trim 1 indent
      if ($_ -match "^`t") {
        return $Line.Substring(1)
      }
      elseif ($_ -match '^    ') {
        return $Line.Substring(4)
      }

      return $Line
    }
  }

  end {
    return $DefinitionLines -join "`n"
  }
}

<#
.SYNOPSIS
	Get git aliases' definition.
.DESCRIPTION
	Get definition of all git aliases or specific alias.
.EXAMPLE
	PS C:\> Get-Git-Aliases
	Get definition of all git aliases.
.EXAMPLE
	PS C:\> Get-Git-Aliases -Alias gst
	Get definition of `gst` alias.
#>
function Get-Git-Aliases([string]$Alias) {
  $esc = [char] 27
  $green = 32
  $magenta = 35

  $Alias = $Alias.Trim()
  $blacklist = @(
    'Get-Git-CurrentBranch',
    'Remove-Alias',
    'Format-AliasDefinition',
    'Get-Git-Aliases'
  )
  $aliases = Get-Command -Module git-aliases | Where-Object { $_ -notin $blacklist }

  if (-not ([string]::IsNullOrEmpty($Alias))) {
    $foundAliases = $aliases | Where-Object -Property Name -Value $Alias -EQ

    if ($foundAliases -is [array]) {
      return Format-AliasDefinition($foundAliases[0].Definition)
    }
    else {
      return Format-AliasDefinition($foundAliases.Definition)
    }
  }

  $aliases = $aliases | ForEach-Object {
    $name = $_.Name
    $definition = Format-AliasDefinition($_.Definition)
    $definition = "$definition`n" # Add 1 line break for some row space

    return [PSCustomObject]@{
      Name       = $name
      Definition = $definition
    }
  }

  $cols = @(
    @{
      Name       = 'Name'
      Expression = {
        # Print alias name in green
        "$esc[$($green)m$($_.Name)$esc[0m"
      }
    },
    @{
      Name       = 'Definition'
      Expression = {
        # Print alias definition in yellow
        "$esc[$($magenta)m$($_.Definition)$esc[0m"
      }
    }
  )

  return Format-Table -InputObject $aliases -AutoSize -Wrap -Property $cols
}

# Prevent conflict with built-in aliases
Remove-Alias gc -Force -ErrorAction SilentlyContinue
Remove-Alias gcb -Force -ErrorAction SilentlyContinue
Remove-Alias gcm -Force -ErrorAction SilentlyContinue
Remove-Alias gcs -Force -ErrorAction SilentlyContinue
Remove-Alias gl -Force -ErrorAction SilentlyContinue
Remove-Alias gm -Force -ErrorAction SilentlyContinue
Remove-Alias gp -Force -ErrorAction SilentlyContinue
Remove-Alias gpv -Force -ErrorAction SilentlyContinue

function ga {
  git add $args
}

function gaa {
  git add --all $args
}

function gapa {
  git add --patch $args
}

function gau {
  git add --update $args
}

function gb {
  git branch $args
}

function gba {
  git branch -a $args
}

function gbda {
  $MainBranch = Get-Git-MainBranch
  $MergedBranchs = $(git branch --merged | Select-String "^(\*|\s*($MainBranch|develop|dev)\s*$)" -NotMatch).Line
  $MergedBranchs | ForEach-Object {
    if ([string]::IsNullOrEmpty($_)) {
      return
    }

    git branch -d $_.Trim()
  }
}

function gbD {
  git branch -D $args
}

function gbl {
  git blame -b -w $args
}

function gbnm {
  git branch --no-merged $args
}

function gbr {
  git branch --remote $args
}

function gbs {
  git bisect $args
}

function gbsb {
  git bisect bad $args
}

function gbsg {
  git bisect good $args
}

function gbsr {
  git bisect reset $args
}

function gbss {
  git bisect start $args
}

function gc {
  git commit -v $args
}

function gc! {
  git commit -v --amend $args
}

function gcn! {
  git commit -v --no-edit --amend $args
}

function gca {
  git commit -v -a $args
}

function gcam {
  git commit -a -m $args
}

function gca! {
  git commit -v -a --amend $args
}

function gcan! {
  git commit -v -a --no-edit --amend $args
}

function gcans! {
  git commit -v -a -s --no-edit --amend $args
}

function gcb {
  git checkout -b $args
}

function gcf {
  git config --list $args
}

function gcl {
  git clone --recursive $args
}

function gclean {
  git clean -df $args
}

function gcm {
  $MainBranch = Get-Git-MainBranch

  git checkout $MainBranch $args
}

function gcd {
  git checkout develop $args
}

function gcmsg {
  git commit -m $args
}

function gco {
  git checkout $args
}

function gcount {
  git shortlog -sn $args
}

function gcp {
  git cherry-pick $args
}

function gcpa {
  git cherry-pick --abort $args
}

function gcpc {
  git cherry-pick --continue $args
}

function gcs {
  git commit -S $args
}

function gd {
  git diff $args
}

function gdca {
  git diff --cached $args
}

function gdt {
  git diff-tree --no-commit-id --name-only -r $args
}

function gdw {
  git diff --word-diff $args
}

function gf {
  git fetch $args
}

function gfa {
  git fetch --all --prune $args
}

function gfo {
  git fetch origin $args
}

function gg {
  git gui citool $args
}

function gga {
  git gui citool --amend $args
}

function ggf {
  $CurrentBranch = Get-Git-CurrentBranch

  git push --force origin $CurrentBranch
}

function ggfl {
  $CurrentBranch = Get-Git-CurrentBranch

  git push --force-with-lease origin $CurrentBranch
}

function ghh {
  git help $args
}

function ggsup {
  $CurrentBranch = Get-Git-CurrentBranch

  git branch --set-upstream-to=origin/$CurrentBranch
}

function gpsup {
  $CurrentBranch = Get-Git-CurrentBranch

  git push --set-upstream origin $CurrentBranch
}

function gignore {
  git update-index --assume-unchanged $args
}

function gignored {
  git ls-files -v | Select-String "^[a-z]" -CaseSensitive
}

function gl {
  git pull $args
}

function glg {
  git log --stat --color $args
}

function glgg {
  git log --graph --color $args
}

function glgga {
  git log --graph --decorate --all $args
}

function glgm {
  git log --graph --max-count=10 $args
}

function glgp {
  git log --stat --color -p $args
}

function glo {
  git log --oneline --decorate --color $args
}

function glog {
  git log --oneline --decorate --color --graph $args
}

function gloga {
  git log --oneline --decorate --color --graph --all $args
}

function glol {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $args
}

function glola {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all $args
}

function gm {
  git merge $args
}

function gmom {
  $MainBranch = Get-Git-MainBranch

  git merge origin/$MainBranch $args
}

function gmt {
  git mergetool --no-prompt $args
}

function gmtvim {
  git mergetool --no-prompt --tool=vimdiff $args
}

function gmum {
  $MainBranch = Get-Git-MainBranch

  git merge upstream/$MainBranch $args
}

function gp {
  git push $args
}

function gpd {
  git push --dry-run $args
}

function gpf {
  git push --force-with-lease $args
}

function gpf! {
  git push --force $args
}

function gpoat {
  git push origin --all
  git push origin --tags
}

function gpristine {
  git reset --hard
  git clean -dfx
}

function gpu {
  git push upstream $args
}

function gpv {
  git push -v $args
}

function gr {
  git remote $args
}

function gra {
  git remote add $args
}

function grb {
  git rebase $args
}

function grba {
  git rebase --abort $args
}

function grbc {
  git rebase --continue $args
}

function grbi {
  git rebase -i $args
}

function grbm {
  $MainBranch = Get-Git-MainBranch

  git rebase $MainBranch $args
}

function grbs {
  git rebase --skip $args
}

function grh {
  git reset $args
}

function grhh {
  git reset --hard $args
}

function grmv {
  git remote rename $args
}

function grrm {
  git remote remove $args
}

function grs {
  git restore $args
}

function grset {
  git remote set-url $args
}

function grt {
  try {
    $RootPath = git rev-parse --show-toplevel
  }
  catch {
    $RootPath = "."
  }

  Set-Location $RootPath
}

function gru {
  git reset -- $args
}

function grup {
  git remote update $args
}

function grv {
  git remote -v $args
}

function gsb {
  git status -sb $args
}

function gsd {
  git svn dcommit $args
}

function gsh {
  git show $args
}

function gsi {
  git submodule init $args
}

function gsps {
  git show --pretty=short --show-signature $args
}

function gsr {
  git svn rebase $args
}

function gss {
  git status -s $args
}

function gst {
  git status $args
}

function gsta {
  git stash save $args
}

function gstaa {
  git stash apply $args
}

function gstd {
  git stash drop $args
}

function gstl {
  git stash list $args
}

function gstp {
  git stash pop $args
}

function gstc {
  git stash clear $args
}

function gsts {
  git stash show --text $args
}

function gsu {
  git submodule update $args
}

function gsw {
  git switch $args
}

function gts {
  git tag -s $args
}

function gunignore {
  git update-index --no-assume-unchanged $args
}

function gunwip {
  Write-Output $(git log -n 1 | Select-String "--wip--" -Quiet).Count
  git reset HEAD~1
}

function gup {
  git pull --rebase $args
}

function gupv {
  git pull --rebase -v $args
}

function glum {
  $MainBranch = Get-Git-MainBranch

  git pull upstream $MainBranch $args
}

function gvt {
  git verify-tag $args
}

function gwch {
  git whatchanged -p --abbrev-commit --pretty=medium $args
}

function gwip {
  git add -A
  git rm $(git ls-files --deleted) 2> $null
  git commit --no-verify -m "--wip-- [skip ci]"
}

function ggl {
  $CurrentBranch = Get-Git-CurrentBranch

  git pull origin $CurrentBranch
}

function ggp {
  $CurrentBranch = Get-Git-CurrentBranch

  git push origin $CurrentBranch
}

function gfli {
  git flow init $args
}

function gflfs {
  git flow feature start $args
}

function gflff {
  git flow feature finish $args
}

function gflfsu {
  git flow feature publish $args
}

function gflfpu {
  git flow feature pull $args
}

function gflrs {
  git flow release start $args
}

function gflrf {
  git flow release finish $args
}

function gflrsu {
  git flow release publish $args
}

function gflrpu {
  git flow release pull $args
}

function gflhs {
  git flow hotfix start $args
}

function gflhf {
  git flow hotfix finish $args
}

function gflhsu {
  git flow hotfix publish $args
}

function gflhpu {
  git flow hotfix pull $args
}

function gflbs {
  git flow bugfix start $args
}

function gflbf {
  git flow bugfix finish $args
}

function gflbsu {
  git flow bugfix publish $args
}

function gflbpu {
  git flow bugfix pull $args
}

function gflss {
  git flow support start $args
}

function gflsf {
  git flow support finish $args
}

function gflssu {
  git flow support publish $args
}

function gflspu {
  git flow support pull $args
}

function gflc {
  git flow config $args
}

function gfld {
  git flow delete $args
}

function gflr {
  git flow release $args
}

function gflf {
  git flow feature $args
}

function gflh {
  git flow hotfix $args
}

function gflb {
  git flow bugfix $args
}

function gfls {
  git flow support $args
}
