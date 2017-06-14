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

# get number of columns based on header row
set ncols = `awk 'BEGIN {FS="\t"} ; /^Value/ || /^ElementNumber/ {print NF}' $file`

# determine if we need to link to external tables
set extTable = `grep "ExternalTable"  $file | wc -l`

# print out rows
echo "digraph $tablename {" > ${tablename}.gv
echo "node [color=white]" >> ${tablename}.gv
echo $tablename '[label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="2" COLOR="BLACK">' >> ${tablename}.gv
echo '<TR><TD COLSPAN="'$ncols'" ALIGN="left"># Table: '$tablename'</TD></TR>' >> ${tablename}.gv
echo '<TR><TD COLSPAN="'$ncols'" ALIGN="left"># URL: https://github.com/DavidBerryNOC/C3S_311a_CDM/blob/master/tables/tsv/'$tablename'.tsv</TD></TR>' >> ${tablename}.gv
awk -v ncols="$ncols" '\
BEGIN { FS="\t"  } ; \
  /^#/ {print "<TR><TD ALIGN=\"left\" COLSPAN=\""ncols"\">"$0"</TD></TR>"} \
  /^Value/ || /^ElementNumber/ {{printf "<TR>"};{for(i=1;i<=NF;i++){printf "<TD BGCOLOR=\"GRAY\">%s<\/TD>", $i };printf "<\/TR>\n" }} \
  /^[^#]/ && /^[^Value]/ && /^[^ElementNumber]/ { \
      {printf "<TR>"};{ \
      printf "<TD>%s</TD>", $1 \
      for(i=2;i<=NF;i++){ \
        printf "<TD>"; \
        nwords = split( $i, words, " "); \
        for(j = 1; j <= nwords ; j++){ \
          printf "%s ", words[j]  \
          if( j % 10 == 0)printf "<BR/>" \
        }; \
        printf "</TD>"\
        } \
      printf "<\/TR>\n" \
      }}' $file >> ${tablename}.gv

# end table / node
echo "</TABLE>>];" >> ${tablename}.gv
echo "}" >> ${tablename}.gv


# now replace special characters (move to awk commands)
# ohm Ω
# degree
cat ${tablename}.gv | sed 's/°/\&deg;/g;s/Ω/\&#8486;/g' > tmp.gv
mv tmp.gv ${tablename}.gv
