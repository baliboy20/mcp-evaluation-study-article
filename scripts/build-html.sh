#!/usr/bin/env bash
# Regenerate html/ from the repo's Markdown docs. Requires pandoc.
set -euo pipefail
cd "$(dirname "$0")/.."
out=html
mkdir -p "$out"
# Every tracked .md file except those under html/ itself.
mapfile -t files < <(find . -name '*.md' -not -path './html/*' -not -path './.git/*' | sed 's|^\./||' | sort)
items=""
for f in "${files[@]}"; do
  dest="$out/${f%.md}.html"
  [ "$f" = README.md ] && dest="$out/readme.html"
  mkdir -p "$(dirname "$dest")"
  rel=$(realpath --relative-to="$(dirname "$dest")" "$out")
  title=$(grep -m1 '^# ' "$f" | sed 's/^# //' || true); title=${title:-$f}
  # Rewrite links to other .md files so they point at the generated .html.
  sed -E 's/\]\(([^)]+)\.md\)/](\1.html)/g' "$f" |
    pandoc -f gfm -t html5 -s --metadata title="$title" \
      -c "$rel/style.css" \
      -B <(echo "<nav><a href=\"$rel/index.html\">Index</a> · source: <code>$f</code></nav>") \
      -o "$dest"
  items+="<li><a href=\"${dest#$out/}\">$title</a> <code>$f</code></li>"
done
cat > "$out/index.html" <<HTML
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>MCP Evaluation Study – Docs</title><link rel="stylesheet" href="style.css"></head>
<body><h1>MCP Evaluation Study – Docs</h1><p>HTML versions of the repository's Markdown documents. Regenerate with <code>scripts/build-html.sh</code>.</p>
<ul>$items</ul></body></html>
HTML
echo "Built ${#files[@]} page(s) into $out/"
