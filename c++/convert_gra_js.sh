#usage ./convert_gra_to_js.sh grafilename
awk '{ if($1 ~ /^[a-zA-Z]/ ) printf "strip.pushPoint({lat:%f, lng:%f});\n", $2, $3;}' $1
