APP_NAME=searx/searxstats:latest

ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

qa: venv.dev
	./ve/bin/flake8 --max-line-length=120 searxstats tests
	./ve/bin/pylint searxstats tests
	./ve/bin/python -m pytest --cov-report html --cov=searxstats tests -vv

docker-build: # Build the container
	docker build -t $(APP_NAME) .

docker-run: # Run the container
	# instances.json
	mkdir -p $(ROOT_DIR)/html/data
	touch $(ROOT_DIR)/html/data/instances.json
	chgrp 1005 $(ROOT_DIR)/html/data/instances.json
	chmod 664 $(ROOT_DIR)/html/data/instances.json
	# cache
	mkdir -p $(ROOT_DIR)/cache
	chgrp 1005 $(ROOT_DIR)/cache
	chmod 775 $(ROOT_DIR)/cache
	# run
	./docker-run.sh --all

venv:
	python3 -m venv ve
	./ve/bin/pip install -U pip wheel setuptools
	./ve/bin/pip install -r requirements.txt
	. ./ve/bin/activate; \
		./utils/install-geckodriver

venv.dev: venv
	./ve/bin/pip install -r requirements-dev.txt


clean:
	rm -rf ./ve/ ./cache ./html/data

run: venv
	mkdir -p cache
	mkdir -p html/data
	touch html/data/instances.json
	./ve/bin/python -m searxstats --cache ./cache --all

webserver: venv
	cd $(ROOT_DIR)/html; $(ROOT_DIR)/ve/bin/python -m http.server 8889
