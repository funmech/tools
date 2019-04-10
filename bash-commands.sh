# get open ports on local network
netstat -ap tcp

# -i4 means only show ipv4 address and ports -P and -n fast output
lsof -Pn -i4

# TCP in LISTEN state
lsof -PiTCP -sTCP:LISTEN

# check if a port is open
lsof -Pi :8814 -sTCP:LISTEN

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

# multiline search with awk for not containing v2
awk "/db.ForeignKey/,/column/" orm_*.py | grep -v v2
