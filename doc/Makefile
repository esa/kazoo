all:
	cp templates/templates_from_wiki preprocess # copy the previous one
	rm templates/*   # delete the old templates
	$(MAKE) -C preprocess
	cp preprocess/output/order.txt .
	./kazoo-merge-doc.py

clean:
	rm -rf preprocess/output/*
	find preprocess/templates/ -type f -delete
