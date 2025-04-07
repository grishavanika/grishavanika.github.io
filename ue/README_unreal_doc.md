For docs:

0. Go to docs (https://dev.epicgames.com/documentation/en-us/unreal-engine/)
1. Get all the links by expanding all sections in the side menu:
   This script should do the trick:

```
var btns = document.getElementsByClassName('btn btn-expander')
for (var i = 0; i < btns.length; ++i) {
    var btn = btns[i];  
    btn.click()
}
```

2. Clear console, run:

```
document.querySelectorAll('.contents-table-link').forEach((element) => console.log(element.href))
```

3. Save output to list.txt, make sure there is unique link per line
4. Have chrome.exe, run unreal_docs_download_pdfs.ps1 (see hardcoded code there)
5. Have pdftotext.exe (https://www.xpdfreader.com/download.html), run unreal_docs_convert_to_txt.ps1

For Learnings:

0. Go to [Learn Unreal Engine](https://dev.epicgames.com/community/unreal-engine/learning?source=epic_games&sort_by=first_published_at)/Epic Games/Published On
1. Run

```
document.querySelectorAll('.learning-list-link').forEach((element) => console.log(element.href))
```
