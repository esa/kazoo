all:
	$(MAKE) -C preprocess
	cp preprocess/output/order.txt .

clean:
	rm -rf preprocess/output/*
	find preprocess/templates/ -type f -delete
