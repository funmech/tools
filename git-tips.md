## Track a new remote branch
```shell
git fetch --all
git checkout -b ip origin/ip
# or full statement
git checkout --track origin/ip
# or for weird ones change remote to make sure origin fetches from *, not a particular branch
[remote "origin"]
    url = https://github.com/WERID_ONES.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

## After a token change - macOS
After a token has been revoked, updated, you may see 403 when push, you need to reset token
To do this , reset user name even this may not have changed. On Mac, try clean cache from keychain.
https://docs.github.com/en/get-started/getting-started-with-git/updating-credentials-from-the-macos-keychain

## Have multiple account locally

```shell
# To set git credential to match http path when a credential helper is used
git config --global credential.useHttpPath true

# To set default username for credential helper globally
git config credential.username --global "new_username"

# To set username for credential helper of current repository
git config credential.username "new_username"


# Set up current author of current repository
git config user.name Li-ReDBox
git config user.email Li-ReDBox@users.noreply.github.com
```

## Check commits

```shell
# have a full display to check something like author and committer
git log --format=fuller

# git graph in terminal
git log --graph --decorate --pretty=oneline --abbrev-commit

# diff without details but only files
git diff --compact-summary gl_feed_v2..CML-11

# suppresses diff, add --format=%s to show a line of commit
git show -s

# accessing ancestry references: 
# 1. ^(caret) - parent, ^2: only used when current commit is a merged commit, which is the ref of second parent (merged from commits). NO ^3 ref!
# 2. ~(tilde) - first parent. If the current commit is a merged commit, it's the ref of the direct parent (merged to commits)

* 9f181aa ARCEnrolment can be used to replace ARCExample as a template
*   4cf9349 Merge branch 'cwm-2183-arc-enrolment'
|\
| * 8607777 Reexport from dev to refresh the solution
| * 9a27d2e Get owning team from trigger
| * 6666ce1 Add settings of prod env for ARCEnrolment solution
| * 90b0c77 Test if envrinmonet variable in setting can be simplified
| * 32c10a8 Add settings of uat env for ARCEnrolment solution
* | 0f085c7 Update connectionids of the conn ref to dataverse of reporting flows in test and uat
* | 3d3fbe1 Update connectionid of the conn ref to dataverse of reporting flows in prod
|/

# most comment way to get great-grandparent:
git show -s --oneline HEAD~3
    3d3fbe1 Update connectionid of the conn ref to dataverse of reporting flows in prod
git show -s --oneline HEAD~^~
    3d3fbe1 Update connectionid of the conn ref to dataverse of reporting flows in prod

# from a merged commit
# parent:
git show -s --oneline HEAD~^
    0f085c7 Update connectionids of the conn ref to dataverse of reporting flows in test and uat
# or
git show -s --oneline HEAD~~
    0f085c7 Update connectionids of the conn ref to dataverse of reporting flows in test and uat

# commits from the second parent, merged from commits:
git show -s --oneline HEAD~^2
    8607777 Reexport from dev to refresh the solution

# go back to the commits of the second parent:
git show -s --oneline HEAD~^2^
    9a27d2e Get owning team from trigger

git show -s --oneline HEAD~^2~
    9a27d2e Get owning team from trigger

git show -s --oneline HEAD~2
    0f085c7 Update connectionids of the conn ref to dataverse of reporting flows in test and uat

git show -s --oneline HEAD~^2~4
    32c10a8 Add settings of uat env for ARCEnrolment solution

# search for an introduced string 
git log -S "A string"
git log -S "A string" --since=2009.1.1 --until=2010.1.1 -- path

# Get first 5 commits from every branch, note `tr` to replace * from the default branch
for b in `git branch | tr '*' ' '`; do
    echo Branch: "$b"
    git log -n5 $br
    echo
done

# Reset the author for the last commit
git commit --amend --reset-author
```

## Rebase 
```shell
# against a remote branch, useful when only one branch was checked out
git pull --rebase origin branch
```

## Stash
```shell
# stash untracked files:
git stash -u (a_file)
# stash selected files
git stash push file_list...
```

## Work with tags:
```shell
# git tags
# delete a tag
git tag -d tag_name  # locally
git push <remote> :refs/tags/tag_name # remotely
```

## Get help
```shell
# on Windows
git help -a | select-string credential
# on Linux
git help -a | grep credential-

# By the way, credential is a scriptable interface, not useful for checking or setting directly
git help credential
```

## Restart from an existing local repository
```shell
# if the original default branch is main, new branch can be called master
git checkout --orphan master
git add .
git commit -m Init
git push -u origin master

# on github.com, switch default branch
# remove the old branch
git push -d origin main
git branch -D main
```