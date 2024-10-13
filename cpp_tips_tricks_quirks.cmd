call pandoc -s --toc --toc-depth=4 ^
  --standalone ^
  --number-sections ^
  --highlight=kate ^
  --from markdown --to=html5 ^
  --lua-filter=anchor-links.lua ^
  cpp_tips_tricks_quirks.md ^
  -o cpp_tips_tricks_quirks.html
