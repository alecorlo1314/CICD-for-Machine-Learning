
install:
	pip install --upgrade pip &&\
	pip install -r requirements.txt

format-check:
	black --check .

train:
	python -m train

lint:
	flake8 --ignore E203 --max-line-length 100 src Aplicacion

eval:
	test -f ./Resultados/metricas.txt
	echo "## Metricas del Modelo" > reporte.md
	cat ./Resultados/metricas.txt >> reporte.md
	echo '\n## Matriz de Confusion' >> reporte.md
	echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)' >> reporte.md
	cml comment create reporte.md


update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

hf-login:
	git fetch origin
	git switch -c update --track origin/update || git switch update
	pip install -U "huggingface_hub[cli]"
	git config --global credential.helper store
	hf auth login --token $(HF) --add-to-git-credential
	hf auth whoami

push-hub:
	hf upload alecorlo1234/Clasificacion-Medicinas ./Aplicacion/drug_app.py /drug_app.py --repo-type space --commit-message="Sincronizando drug_app.py"
	hf upload alecorlo1234/Clasificacion-Medicinas ./Modelo /Modelo --repo-type space --commit-message="Sincronizando Modelo"
	hf upload alecorlo1234/Clasificacion-Medicinas ./Resultados /Metricas --repo-type=space --commit-message="Sincronizando Metricas"

deploy: hf-login push-hub
