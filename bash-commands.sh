# get open ports on local network
netstat -ap tcp

# -i4 means only show ipv4 address on Internet and ports -P and -n fast output
lsof -Pn -i4

# TCP in LISTEN state
lsof -Pi TCP -s tcp:listen

# check if a tcp port is being listened
lsof -Pi tcp:8000 -s tcp:listen

# on macOS, add '' after -i
# or brew install gnu-sed and use gsed
sed -i '' 's/app\.services\.orms\.orm_base/\.orm_base/' *.py

sed -i ''  -e 's/\(__tablename__ = \".*\)\"/\1\_v2"/' *.py

# delete 4 lines and the matched line
(g)sed '/Set table arguments/,+4 d' orm_bank_accounts.py

# replace the next line after the pattern 'Unix' with 'hi':
sed '/Unix/{n;s/.*/hi/}' file
sed -r '/db.ForeignKey(/{n;s/\"([\w_])\./\1hi/}' orm_bank_accounts.py
(g)sed -e '/db\.ForeignKey(/{n;s/\(column\=\"\)\(.*\)\./\1\2_v2\./}' orm_bank_accounts.py

# add extra at the end of line:
(g)sed -i 's/$/*.py/' bad_revisions.txt

# add a line with leading space escaped after a hint:
sed '/anchor/a \  \extra: line' $f

# multiline search with awk for not containing v2
awk "/db.ForeignKey/,/column/" orm_*.py | grep -v v2

# fold long lines
fold -w 60 a.file
# or
cat a.file | fold -w 60
# or in vim
:%!fold -w 60
# pipe with other tools
source config.sh
envsubst < template.yml | base64 | fold -w 60

# https://blog.mozilla.org/webdev/2015/10/27/eradicating-those-nasty-pyc-files/
find . -name '*.pyc' -delete

# side note: to prevent pyc, run
export PYTHONDONTWRITEBYTECODE=1

# After a token has been reoked, updated, you may see 403 when push, you need to reset token
# To do this , reset user name even this may not have changed. On Mac, try clean cache from keychain.
# https://docs.github.com/en/get-started/getting-started-with-git/updating-credentials-from-the-macos-keychain

# We may need this when using multiple account:
git config --global credential.useHttpPath true


# To change locally for just one repository
git config credential.username "new_username"

# To change globally use
git config credential.username --global "new_username"

#git graph in terminal
git log --graph --decorate --pretty=oneline --abbrev-commit

# Rebase local branch with remote branch
# useful before merge back to remote branch
git pull --rebase origin branch

# diff without details but only files
git diff --compact-summary gl_feed_v2..CML-11

# track a new remote branch
git fetch --all
git checkout -b ip origin/ip
# or full statement
git checkout --track origin/ip
# or for weird ones change remote to make sure origin fetches from *, not a particular branch
[remote "origin"]
    url = https://github.com/WERID_ONES.git
    fetch = +refs/heads/*:refs/remotes/origin/*

# stash untracked files:
git stash -u (a_file)
#git stash selected files
git stash push file_list...

# search for an introduced string 
git log -S "A string"
git log -S "A string" --since=2009.1.1 --until=2010.1.1 -- path

# git tags
# delete a tag
git tag -d tag_name  # locally
git push <remote> :refs/tags/tag_name # remotely

# remove files listed in a file: one on every line
rm $(cat bad_revisions.txt)

# for loop
for i in {0..10..2}
  do
     echo "Welcome $i times"
 done

# check weak ciphers using namp:
# https://www.owasp.org/index.php/Testing_for_Weak_SSL/TLS_Ciphers,_Insufficient_Transport_Layer_Protection_(OTG-CRYPST-001)
nmap --script ssl-cert,ssl-enum-ciphers -p 443 api.com

# do a scan:
nmap -sV -sC -o nmapinitial ip_to_scan

# kill a recent background job
kill %1

# pip install packages one by one, useful when requirements.txt contains -r another.txt
grep -v "^#" requirements-dev.txt  | xargs -n 1 -L 1 pip install

# decode urlsafe base64 string: from '-' to '+', '_' to '/'.
echo $encoded_string | tr '_-' '/+' | base64 -d > string

# download and extract tar.gz either by curl or wget
curl https://github.com/google/trillian/archive/v1.3.11.tar.gz | tar -xz
wget -c https://github.com/google/trillian/archive/v1.3.11.tar.gz && tar -xzf v1.3.11.tar.gz
wget -c https://github.com/google/trillian/archive/v1.3.11.tar.gz -O - | tar -xz

