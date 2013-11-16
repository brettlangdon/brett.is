WINTERSMITH = ./node_modules/.bin/wintersmith
ARTICLE_DIR = ./contents/is/writing/about

build:
	@$(WINTERSMITH) build

clean:
	@rm -rf build

preview:
	@$(WINTERSMITH) preview

add_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	mkdir -p $(ARTICLE_DIR)/$$dir;\
	cat base.md | sed "s/{title}/$$title/g" | sed s/{date}/`date "+%Y-%m-%d"`/g> $(ARTICLE_DIR)/$$dir/index.md;\
	emacs $(ARTICLE_DIR)/$$dir/index.md

remove_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	rm -rf $(ARTICLE_DIR)/$$dir

.PHONY: build clean preview add_article remove_article
