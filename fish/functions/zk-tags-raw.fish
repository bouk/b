function zk-tags-raw
  rg --only-matching --no-filename --no-line-number  '#[\w\-]{3,}' -t md $ZK_DIR | awk ' { tot[$0]++ } END { for (i in tot) print tot[i], "\t", i } ' | sort -k1,2 -r --numeric-sort
end
