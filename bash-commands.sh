# get open ports on local network
netstat -ap tcp

# -i4 means only show ipv4 address and ports -P and -n fast output
lsof -Pn -i4

# TCP in LISTEN state
lsof -PiTCP -sTCP:LISTEN

# check if a port is open
lsof -Pi :8814 -sTCP:LISTEN