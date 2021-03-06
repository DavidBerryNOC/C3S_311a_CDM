#!/bin/csh
if( $#argv == 0)then
  echo "Usage: "
  echo "    process_table.csh <filename>"
  exit
else
  set file = $argv[1]
endif

# get name of table
set tablename = `echo $file | cut -d '.' -f1`
set tablecaption = `echo $file | cut -d '.' -f1 | sed "s/_//g" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2)) }'`

# get number of columns based on header row
set ncols = `awk 'BEGIN {FS="\t"} ; /^index/ || /^element_number/ {print NF}' $file`

set tablepath="/Users/dyb/GitHub/C3S_311a_CDM/tables/"
#set tablepath="/Users/dyb/Documents/Projects/C3S_311a_Lot2/WP2/CDM/github/tables/"

# awk  -v ncols="$ncols" -v tablename="$tablename" -v file="$file" -v tablepath=$"tablepath" '\
awk -v ncols="$ncols" -v tablecaption="$tablecaption" -v tablename="$tablename" -v file="$file" -v tablepath="$tablepath" '\
BEGIN { FS = "\t" ; \
    if( ncols > 4){\
      print "\\begin{landscape}";\
      pagewidth = 8.9;\
    }else{\
      pagewidth = 6.8;\
    }\
    gsub(/_/,"\\_",tablename); \
    colwidth = (pagewidth-3.0) / (ncols - 1.0) ;\
    print "\\pgfplotstabletypeset[";\
    print "    empty header,";\
    print "    begin table=\\begin{longtable},";\
    print "    %every head row/.style={output empty row},";\
    print "    every nth row={1}{before row=\\hline},";\
    print "    every first row/.append style={";\
    print "        before row={%";\
    print "            % Initial caption";\
   printf "            \\caption{%s}\n" , tablename;\
   printf "            \\label{tab:DataTable%s}\\\\\n", tablecaption;\
    print "            % Initial column headers";\
}\
/^index/ || /^element_number/ {\
    printf "            \\hline\\hline " \
    for( i = 1; i < NF ; i ++) { \
        entry = $i;\
        gsub(/_/,"\\_",entry);\
        printf "            \\multicolumn{1} { V{%f in}} { \\textbf{\\seqsplit{%s}}} & \n", colwidth , entry \
    } \
    entry = $i;\
    gsub(/_/,"\\_",entry);\
    printf "            \\multicolumn{1} { V{%f in} } {\\textbf{\\seqsplit{%s}}} \\\\ \\hline\\hline \\endfirsthead\n", 3.0, entry; \
    printf "            \\multicolumn{%d}{c}{Table \\thetable\\ %s (cont.)} \\\\\n", ncols, tablename;\
    print "            % column headers on additional pages";\
    printf "            \\hline\\hline " \
    for( i = 1; i < NF ; i ++) { \
        entry = $i;\
        gsub(/_/,"\\_",entry);\
        printf "            \\multicolumn{1} {V{%f in} } { \\textbf{\\seqsplit{%s}}} & \n", colwidth, entry \
    } \
    entry = $i;\
    gsub(/_/,"\\_",entry);\
    printf "            \\multicolumn{1} { V{%f in} } {\\textbf{\\seqsplit{%s}}} \\\\ \\hline\\hline \\endhead\n",3.0,  entry; \
    print "            % Footer on 1st to penultimate pages";\
    printf "            \\multicolumn{%d}{r}{{Continued on next page}} \\\\\n", ncols;\
    print "            \\endfoot";\
    print "            % Footer on last page of table";\
    print "            \\hline";\
    printf "            \\multicolumn{%d}{r}{{End of table}} \\\\ \n", ncols;\
    print "            \\endlastfoot";\
    print "        }";\
    print "    },";\
    print "    %";\
    print "    end table=\\end{longtable},";\
    print "    col sep=tab,";\
    print "    string type,";\
    for( i = 1 ; i < NF ; i ++){\
        printf "    columns/%s/.style={\n", $i;\
        print "            string type, ";\
        if( $i == "element_name" || $i == "external_table" || $i ~ "name" ){\
          printf "            column type= n{%f in}, \n", colwidth;\
        }else{\
          printf "            column type= V{%f in}, \n", colwidth;\
        }\
        print "            string replace*={_}{\\_}";\
        print "        },";\
    }\
    printf "    columns/%s/.style={\n", $i;\
    print "            string type, ";\
    print "            string replace*={_}{\\_},";\
    printf "            column type = V{%f in}\n", 3.0;\
    print "        }";\
    printf "    ]{%s%s}\n", tablepath, file ;\
} \
END { \
    if( ncols > 4){ \
      print "\\end{landscape}";\
    } \
}\
' $file > $tablename.tex
