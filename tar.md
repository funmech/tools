
# Use `tar` to back up files
There are several handy ways to create a tarball of selected files and save it to another folder in Bash. Below are common patterns with examples, plus tips to avoid path headaches.


## 1) List the files explicitly
If you already know the paths, just list them:
```shell
tar -cvf /path/to/dest/archive.tar \
  /path/to/file1 \
  /path/to/file2 \
  /another/path/file3
```

- `-c` create, `-v` verbose (optional), `-f` output file.
- Add compression: 
    - gzip: tar -czvf /path/to/dest/archive.tar.gz ...
    - bzip2: tar -cjvf /path/to/dest/archive.tar.bz2 ...
    - xz: tar -cJvf /path/to/dest/archive.tar.xz ...

Tip: Use quotes if paths contain spaces.


## 2) Use -C to control how paths are stored
If you want the tar to contain relative paths (cleaner on extract), combine `-C` with relative file names:
```shell
tar -czvf /path/to/dest/archive.tgz \
  -C /project \
  src/main.py \
  README.md \
  -C docs \
```

This stores `src/main.py`, `README.md`, and `guide.pdf` relative to those directories instead of absolute paths.


## 3) From a list file (--files-from / -T)
Put selected file paths into a text file, one per line:
```shell
# files.list
/path/a/foo.txt
/path/b/bar.log
/path/c/sub/thing.json
```
Then:
```shell
tar -czvf /path/to/dest/archive.tgz -T files.list
```

For paths with special characters or spaces, prefer null-delimited:
```shell
# Create a null-delimited list
printf '%s\0' "/path/a/foo.txt" "/path/b/bar.log" "/path/c/sub/thing.json" > files.null

# Use --null
tar -czvf /path/to/dest/archive.tgz --null -T files.null
```


## 4) Use find to select files programmatically
Select files by pattern, size, age, etc., and pipe to tar:

### a) Safe null-delimited pipeline (recommended for any unusual filenames):
```shell
find /root -type f -name '*.log' -print0 \
  | tar --null -czvf /path/to/dest/logs.tgz -T -
```
### b) Store relative paths by switching directories first:
```shell
cd /project
find . -type f -name '*.py' -print0 \
  | tar --null -czvf /path/to/dest/py-src.tgz -T -
```
### c) Using -C within tar instead of cd:
```shell
find /project -type f -name '*.py' -printf '%P\0' \
  | tar -C /project --null -czvf /path/to/dest/py-src.tgz -T -
```
Here `%P` prints paths relative to /project.


## 5) Globs and brace expansion (simple, when patterns are known)
```shell
tar -czvf /path/to/dest/archive.tgz \
  /var/log/*.log \
  /etc/{hosts,hostname,resolv.conf}
```

Note: globs are expanded by the shell; ensure they match what you expect (use echo to preview).


## 6) Excluding files you don’t want
You can include broad directories and then exclude specifics:
```shell
tar -czvf /path/to/dest/archive.tgz /project \
  --exclude='/project/node_modules' \
  --exclude='*.tmp' \
  --exclude-vcs
```

`--exclude-vcs` ignores `.git`, `.svn`, etc.

You can stack multiple --exclude patterns.


## 7) Preserve/normalize metadata

Default `tar` preserves permissions, owners, timestamps. If sharing across systems and you want portability: 
- `--numeric-owner` Always use numbers for user/group names. Only use it when extract and ownership needs to be maintained.
- `--same-owner`: Try to preserve ownership  (default for superuser).
- `--no-same-owner`: Ignore ownership, use current user. (default for ordinary users).
- `--same-permissions`: Preserve permissions (default for superuser).
- `--no-same-permissions`: Apply umask (default for ordinary users).
- `--transform`: Use `sed` replace EXPRESSION to transform file names (adjust path names).
```shell
tar -czvf /path/to/dest/archive.tgz \
  -C /project \
  src/main.py \
  --transform='s,^src/,app-src/,'
```


## 8) Verify and inspect
List contents without extracting:
```shell
tar -tvf /path/to/dest/archive.tgz
```

Test extraction to a temp dir:
```shell
mkdir /tmp/test_extract
tar -xvf /path/to/dest/archive.tgz -C /tmp/test_extract
```


## 9) Common patterns tailored for “selected files” → “another folder”
Example A: Selected files across different folders, clean relative paths
```shell
tar -czvf /backup/selected.tgz \
  -C /etc hosts hostname \
  -C /var/log syslog \
  -C /home/gene projects/ids-tools/README.md
```

Example B: Selected by find, saved elsewhere
```shell
find /data/reports -type f -name '2025-*.csv' -print0 \
  | tar --null -czvf /backup/reports-2025.tgz -T -
```

Example C: From a prebuilt list
```shell
tar -czvf /mnt/archives/app-configs.tgz -T config-files.list
```


## Gotchas & Tips

Absolute paths: Using absolute paths can cause extraction to write to absolute locations if `--absolute-names` was used. Avoid that; prefer `-C` and relative paths.

Special characters / spaces: Use null-delimited (`-print0` + `--null`) to be safe.

Compression choice: 
- -z (gzip): fast, widely compatible.
- -j (bzip2): better compression than gzip, slower.
- -J (xz): best compression, slowest.

Large archives: consider `pigz` (parallel gzip) if installed: `tar -I pigz -cvf archive.tar.gz ....`

Reproducibility (CI/builds): add `--sort=name --mtime=<fixed> --owner=0 --group=0 --numeric-owner`.
