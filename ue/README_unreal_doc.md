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
console.log('done')
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
// document.querySelectorAll('.learning-list-link').forEach((element) => console.log(element.href))
document.querySelectorAll('.card-link').forEach((element) => console.log(element.href))
```

As of 08 November 2025 (ChatGPT):

```

(async () => {
  const startPage = 1;
  const endPage = 82;
  const base = 'https://dev.epicgames.com/community/unreal-engine/learning';
  const params = '?source=epic_games&sort_by=first_published_at';

  function waitForSelector(doc, selector, timeout = 8000) {
    const start = Date.now();
    return new Promise((resolve) => {
      const check = () => {
        try {
          const found = doc.querySelectorAll(selector);
          if (found && found.length) return resolve([...found]);
        } catch (e) {}
        if (Date.now() - start > timeout) return resolve(null);
        setTimeout(check, 200);
      };
      check();
    });
  }

  const iframe = document.createElement('iframe');
  iframe.style.display = 'none';
  document.body.appendChild(iframe);

  const collected = new Set();

  for (let page = startPage; page <= endPage; page++) {
    const url = page === 1
      ? `${base}${params}`
      : `${base}/page/${page}${params}`;

    console.log(`\n=== Page ${page} ===`);
    iframe.src = url;

    await new Promise((res) => {
      const onload = async () => {
        const doc = iframe.contentDocument || iframe.contentWindow.document;
        const nodes = await waitForSelector(doc, '.card-link', 10000);
        if (nodes && nodes.length) {
          const newLinks = new Set();
          nodes.forEach(n => {
            const href = n.href || n.getAttribute('href');
            if (href && !collected.has(href)) {
              collected.add(href);
              newLinks.add(href);
            }
          });
          if (newLinks.size) {
            console.log(`Found ${newLinks.size} new links:`);
            console.log([...newLinks].join('\n'));
          } else {
            console.log('No new links (all duplicates).');
          }
        } else {
          console.log('No .card-link found (timeout).');
        }
        iframe.removeEventListener('load', onload);
        setTimeout(res, 300);
      };
      iframe.addEventListener('load', onload);
    });
  }

  document.body.removeChild(iframe);
})();

```