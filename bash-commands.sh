# get open ports on local network
netstat -ap tcp

# -i4 means only show ipv4 address on Internet and ports -P and -n fast output
lsof -Pn -i4

# TCP in LISTEN state
lsof -Pi TCP -s tcp:listen

# check if a tcp port is being listened
lsof -Pi tcp:8000 -s tcp:listen

# convert end of line from CRLF to LF: this is required when adding the line ends on Windows
sed -i 's/\r$//' windows.txt

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

# add content to start and end of lines with | as delimiter, not the / to avoid escaping
sed -i 's|^|<value>|; s|$|</value>|' ids.txt

# add a line with leading space escaped after a hint:
sed '/anchor/a \  \extra: line' $f

# extract a string and clean it:
# give a file contains this line:
# [2021.09.22 09:37:00.458] The analysis id of the new analysis is "14221963".
sed -n 's/.*new analysis is //p' output.txt | sed 's/\"//g; s/\.//'

# replace content in files. Include -I if there are binary files: -rIl
grep -rl --exclude-dir=.git "old_text" ./path | xargs sed -i 's/old_text/new_text/g'

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

# How to tell find where and what to look for:
# 1. Skip descending into ./src/emacs, list everything else.
# both -prune and -print are action return true, use -o (-or), which is short-circuits, to go one or another
#   -path ./src/emacs -prune
#   -print, or -print0 for printing file name with null character. Has the same function of -0 in xargs.
find . -path ./src/emacs -prune -o -print
# 2. Another example:
find ./path -type d \( -name node_modules -o -name .git \) -prune -o \
  -type f -name '*.js' -print0 \
  | xargs -0 sed -i 's/old_text/new_text/g'


# side note: to prevent pyc, run
export PYTHONDONTWRITEBYTECODE=1

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

# back up important files, for example, those [profile files](./firefox-profile-files.txt) of Firefox.
tar -czvf /backup/selected.tgz -T firefox-profile-files.txt

# compression options:
# gzip:  tar -czvf /path/to/dest/archive.tar.gz ...
# bzip2: tar -cjvf /path/to/dest/archive.tar.bz2 ...
# xz:    tar -cJvf /path/to/dest/archive.tar.xz ..

# Use --numeric-owner when extracting archives on systems where user/group names may differ.