# Download current version of go: https://golang.org/doc/install

# Run go get to get tools really useful for offline life
# Recommended to use go get command, even go install works
# https://github.com/golang/tools
go get golang.org/x/tools/cmd/godoc
# /doc is hidden, so to read spec of language type in /doc/go_spec.html

# https://github.com/golang/tour
go get golang.org/x/tour

# Run this `export GO111MODULE=off` before run `tour`, see https://github.com/golang/go/issues/31602
