grep --color=always --exclude-dir=vendor --exclude-dir=.jekyll-cache --exclude="*.md" --exclude-dir=_site --exclude-dir=.git --exclude=feed.xml -Irn $@

echo
echo "Note: Excludes *.md files and useless directories (e.g., .git, vendor, etc.)"
echo
