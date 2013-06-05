SITES_PATH = /sites
APP_NAME = tomaguestbook.tomago.ru
PROJECT_ROOT = /$(SITES_PATH)/$(APP_NAME)
NGINX_ROOT = /etc/nginx/

deploy: stop deploy_app start
	service nginx restart

stop:
	su -l www-data -c 'cd $(PROJECT_ROOT); hypnotoad -s ./app.pl'

deploy_app:
	mkdir -p /sites/logs/$(APP_NAME)
	echo "su -l www-data -c 'cd $(PROJECT_ROOT); hypnotoad ./app.pl'" > $(SITES_PATH)/.config/sites-available/$(APP_NAME)
	rm -rf $(PROJECT_ROOT)
	cp -R ./app $(PROJECT_ROOT)
	cp ./nginx.conf $(NGINX_ROOT)/sites-enabled/$(APP_NAME)
	chown -R www-data:www-data $(PROJECT_ROOT)
	chmod -R 777 $(PROJECT_ROOT)/public

start:
	su -l www-data -c 'cd $(PROJECT_ROOT); hypnotoad ./app.pl'

enable:
	ln -s $(SITES_PATH)/.config/sites-available/$(APP_NAME) $(SITES_PATH)/.config/sites-enabled/$(APP_NAME)

disable:
	rm $(SITES_PATH)/.config/sites-enabled/$(APP_NAME)
