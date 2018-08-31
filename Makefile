CFG_PATH ?= config/georef.cfg
UTILS_PY = service.management.utils_script
TIMEOUT ?= 320

.PHONY: docs

docs:
	mkdocs build
	$(BROWSER) site/index.html

servedocs:
	mkdocs serve

check_config_file:
	@test -f $(CFG_PATH) || \
		(echo "No existe el archivo de configuración $(CFG_PATH)." && exit 1)

index: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m $(UTILS_PY) -m index -t $(TIMEOUT)

index_forced: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m $(UTILS_PY) -m index -t $(TIMEOUT) -f

print_index_stats: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m $(UTILS_PY) -m index_stats -t $(TIMEOUT) -i

load_sql: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m $(UTILS_PY) -m run_sql -s service/management/function_geocodificar.sql

start_dev_server: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	FLASK_APP=service/__init__.py \
	FLASK_ENV=development \
	flask run

start_gunicorn_dev_server: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	gunicorn service:app -w 1 --log-config=config/logging.ini -b 127.0.0.1:5000

test_live: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m unittest tests/test_search_*

test_mock: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m unittest tests/test_mock_*

test_custom: check_config_file
	GEOREF_CONFIG=$(CFG_PATH) \
	python -m unittest tests/$(TEST_FILES) # Variable de entorno definida por el usuario

test_all: test_live test_mock

code_style:
	flake8 tests service

doctoc: ## generate table of contents, doctoc command line tool required
        ## https://github.com/thlorenz/doctoc
	doctoc --maxlevel 3 --github --title " " docs/quick_start.md
	bash fix_github_links.sh docs/quick_start.md
	doctoc --maxlevel 3 --github --title " " docs/spreadsheet_integration.md
	bash fix_github_links.sh docs/spreadsheet_integration.md
	doctoc --maxlevel 3 --github --title " " docs/python_usage.md
	bash fix_github_links.sh docs/python_usage.md
	doctoc --maxlevel 3 --github --title " " docs/jwt-token.md
	bash fix_github_links.sh docs/jwt-token.md
	doctoc --maxlevel 3 --github --title " " docs/developers/georef-api-development.md
	bash fix_github_links.sh docs/developers/georef-api-development.md
	doctoc --maxlevel 3 --github --title " " docs/developers/python3.6.md
	bash fix_github_links.sh docs/developers/python3.6.md
	doctoc --maxlevel 3 --github --title " " docs/developers/georef-api-data.md
	bash fix_github_links.sh docs/developers/georef-api-data.md
