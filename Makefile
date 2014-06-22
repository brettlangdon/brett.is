WINTERSMITH = ./node_modules/.bin/wintersmith
ARTICLE_DIR = ./contents/writing/about

build:
	@./node_modules/.bin/cleancss ./contents/css/main.css > ./contents/css/main.min.css
	@$(WINTERSMITH) build

clean:
	@rm -rf build

preview:
	@$(WINTERSMITH) preview

add_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g" | tr "[:upper:]" "[:lower:]"`;\
	mkdir -p $(ARTICLE_DIR)/$$dir;\
	cat base.md | sed "s/{title}/$$title/g" | sed s/{date}/`date "+%Y-%m-%d"`/g> $(ARTICLE_DIR)/$$dir/index.md;\
	$$EDITOR $(ARTICLE_DIR)/$$dir/index.md

remove_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	rm -rf $(ARTICLE_DIR)/$$dir

edit_article:
	@echo "Enter Article Title: "
	@read title;\
	dir=`echo $$title | sed "s/ /-/g"`;\
	$$EDITOR $(ARTICLE_DIR)/$$dir/index.md

pull:
	git pull

update: pull build

.PHONY: build clean preview add_article remove_article edit_article pull update
