# sed works line by line. Cannot do multiple line replacement

# BSD sed has lots of hoops to jump through
# GNU sed generally better
$ echo -e "Dog\nFox\nCat\nSnake\n" | sed -e '1h;2,$H;$!d;g' -re 's/([^\n]*)\n([^\n]*)\n/Quick \2\nLazy \1\n/g'

# cheat sheet:
# :  # label
# =  # line_number
# a  # append_text_to_stdout_after_flush
# b  # branch_unconditional             
# c  # range_change                     
# d  # pattern_delete_top/cycle          
# D  # pattern_ltrunc(line+nl)_top/cycle 
# g  # pattern=hold                      
# G  # pattern+=nl+hold                  
# h  # hold=pattern                      
# H  # hold+=nl+pattern                  
# i  # insert_text_to_stdout_now         
# l  # pattern_list                       
# n  # pattern_flush=nextline_continue   
# N  # pattern+=nl+nextline              
# p  # pattern_print                     
# P  # pattern_first_line_print          
# q  # flush_quit                        
# r  # append_file_to_stdout_after_flush 
# s  # substitute                                          
# t  # branch_on_substitute              
# w  # append_pattern_to_file_now         
# x  # swap_pattern_and_hold             
# y  # transform_chars     

$!N # if the last line, exclude Next line

# Use regex
sed -E 's/"authentication",\s+"v1",\s+"oauth",\s+"token"/junc\r/' dev/

# accumulate a few lines and change the lines to sdsdsd
sed -n '/path/{N; /authentication/ N; /v1/ N; /oauth/ N; /v1/ N; /token/ s//sdsdsd/; p;}' dev/test.txt
sed -n '/authentication/{N; N; N; p;}' test/acuit-aggregator.json 

# act on a block of lines, e.g. insert # symbol to a block of lines at the beginning
sed '/path/,/token/s/^/# /g' dev/test.txt
# here is an example us n to work on the last finding
sed '/path/,/token/{n;s/^/# /g;}' dev/test.txt
sed '/path/,/token/{n;d;}' dev/test.txt

# use change command
sed -n '/authentication/,/"token"/{c; "my things are here";}' test/acuit-aggregator.json 

# if a beginning pattern found it will delete from the point to the end if the end pattern not found!!!
sed '/authentication/,/"token"/d' dev/acuit-aggregator.json 

# this fixes the problem of range search, but will leave concated contents as a side effect: "authentication","v2","passwordtoken"],
sed -n '/authentication/{N;N;N; s/\n//g; s/[[:space:]]//g; s/"authentication","v1","oauth","token"/"authorization","v2","passwordtoken"/; p;}' test/acuit-aggregator.json

# single-line form via a Bash/Ksh/Zsh ANSI C-quoted string using $'...'
# BSD sed requires a \ followed by an actual newline to pass the text to append.
# The same applies to the related i (insert) and c (delete and insert) functions.
# It is weird that the last new line \n does not need to be escaped as \\\n as at the beginning and middle

# How to append, may work or not? Use one line style is not the best solution
# the command will be repeated for every line found in the block
sed -e '/authentication/,/"token"/{d;}' -e $'1 a\\\nappended text' dev/test.txt
sed -e $'/authentication/,/"token"/{d; a\\\nappended text\n;}' dev/test.txt
sed -e $'/authentication/,/"token"/{;a\\\nappended text\n; d;}' dev/test.txt

# Do not use function list if they are not related
sed -e $'/authentication/,/"token"/c\\\nappended text\n' test/acuit-aggregator.json 
sed -i -e $'/authentication/,/"token"/c\\\n"authorization","v2","passwordtoken"' test/acuit-aggregator.json 
sed -i -e $'/authentication/,/"token"/c\\\n"authorization",\\\n"v2",\\\n"passwordtoken"\n' test/acuit-aggregator.json
sed -e $'/authentication/,/"token"/c\\\n"authorization","v2","passwordtoken"\n;' -e $'s/,/,\\\n/; s/^/    /' test/acuit-aggregator.json

# out test file
cat > alpha.txt
This is
a test
Please do not
be alarmed

sed '/^a test$/{$!{N;s/^a test\nPlease do not$/not a test\nBe/;ty;P;D;:y}}' alpha.txt
# saddly BSD sed does not work this way
sed 's/^a test$/something else/' alpha.txt 
sed '/^a test$/{n;s/^a test\nPlease do not$/not a test\nBe/;}' alpha.txt 

# perl is easier to use when multi-line actions are needed
perl -i -pe 's/a test\nPlease do not/not a test\nBe/igs' alpha.txt

# perl -0: use the null character (ASCII NUL character (character code 0)) as the separator for record separator ($/). 
# Because the file does not contains null character, so it means read the whold file at once, instead of line by line.
# So it acts like values above 0400, or the formal 0777 for this purpose.
perl -p0e 's/"authentication",\n\s+"v1",\n\s+"oauth",\n\s+"token"\n/"authorization","v2","passwordtoken"/g' test/acuit-aggregator.json

perl -p0e 's/a test\nPlease do not/not a test\nBe/igs' alpha.txt

# delete everyline except we want to keep: be alarmed
sed -e '1,${/be alarmed/!d;}' alpha.txt
sed -e '1,${h;}' -e '{/be alarmed/!d;}' alpha.txt

# remove the leading space: BSD sed does not support \s which is in the enhanced collection
sed 's/^[[:space:]]*//' alpha.txt

# Add leading space to a line with the anchor
sed '/This/s/^/        /' alpha.txt 

# multiple line file
line 1,
line 2,
line 3

# remove new line to make it a one-line string, otherwise, N has not effect
sed '1{N;N; s/\n//g; p;}' list2.txt 
sed '1{N;N; s/\n//g; s/.*/go away/;}' list2.txt

# use like grep but operate on range
# 2nd line of anchor key.*:.*grant_type
sed -n '/key.*:.*grant_type/{n;n;p;}' dev/acuit-aggregator.json
# as above and append content
sed -n $'/key.*:.*grant_type/{n;n;a\\\n{\"key": \"state\",\\\n "value": \"mystate\"},\n;p;}' dev/acuit-aggregator.json
