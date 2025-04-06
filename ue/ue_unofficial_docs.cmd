call pandoc -s --toc --toc-depth=4 ^
  --standalone ^
  --number-sections ^
  --highlight=kate ^
  --from markdown --to=html5 ^
  ue_unofficial_docs.md ^
  -o ue_unofficial_docs.html

