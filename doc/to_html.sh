pandoc -c kazoo.css -f mediawiki -t html5 -s updated.mediawiki -o test.html
# To generate text documentation with nice tables:
pandoc -c ../kazoo.css -f mediawiki -t rst+grid_tables --toc -o doc.txt templates_from_wiki
