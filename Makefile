build:
	./node_modules/.bin/wintersmith build

clean:
	@ rm -rf build

preview:
	./node_modules/.bin/wintersmith preview

add_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	mkdir -p contents/is/writing/about/$$dir;\
	cat base.md | sed "s/{title}/$$title/g" | sed s/{date}/`date "+%Y-%m-%d"`/g> contents/is/writing/about/$$dir/index.md;\
	emacs contents/is/writing/about/$$dir/index.md

remove_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	rm -rf contents/is/writing/about/$$dir

.PHONY: build clean preview add_article remove_article
