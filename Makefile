.PHONY: build

install:
	pip install -U -r build-requirements.txt
	python setup.py develop

test:
	py.test --cov=formica tests/unit

check-code:
	pycodestyle .
	pyflakes .

integration-test:
	py.test -s tests/integration

build-dev:
	docker-compose build formica

dev: build-dev
	docker-compose run formica bash

clean:
	rm -fr dist

build: build-dev
	docker-compose run formica python setup.py sdist bdist_wheel
	docker-compose run formica pandoc --from=markdown --to=rst --output=build/README.rst README.md

release-pypi: build-dev build
	docker-compose run formica twine upload dist/*

release-docker:
	docker build --no-cache -t flomotlik/formica -f Dockerfile.release .
	docker push flomotlik/formica

release: release-pypi release-docker

whalebrew:
	docker build -t flomotlik/formica:whalebrew -f Dockerfile.whalebrew .
	whalebrew install -f flomotlik/formica:whalebrew