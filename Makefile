# Makefile for common automation

.PHONY: help deploy-func build-func zip-func

FUNC_DIR=functions/func-simiriki-leadscore
FUNC_NAME?=func-simiriki-leadscore
AZ_RG?=rg-simiriki-core

help:
	@echo "Targets:"
	@echo "  build-func   - Install deps and prepare zip"
	@echo "  zip-func     - Create function zip"
	@echo "  deploy-func  - Deploy zip to Azure Function App ($(FUNC_NAME))"

build-func:
	python3 -m venv $(FUNC_DIR)/.venv || true
	. $(FUNC_DIR)/.venv/bin/activate && pip install -r $(FUNC_DIR)/requirements.txt

zip-func:
	cd $(FUNC_DIR) && rm -f ../$(FUNC_NAME).zip && zip -r ../$(FUNC_NAME).zip . -x "*.venv*" "__pycache__/*"

deploy-func: build-func zip-func
	az functionapp deployment source config-zip -g $(AZ_RG) -n $(FUNC_NAME) --src $(FUNC_DIR)/../$(FUNC_NAME).zip
	@echo "Deployed $(FUNC_NAME)."

