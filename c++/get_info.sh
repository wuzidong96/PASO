grep "" result/info/info_* |  \
cut -d '_'  --output-delimiter=',' -f2- | \
cut -d ',' -f1-2,5- | \
sort -g -t ',' -k1 -k2 -k3 \
> info.csv
