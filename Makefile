install:
	pip install --upgrade pip &&\
		pip install -r requerimientos.txt

format:
	black *.py

train:
	python train.py

eval:
	echo "## Metricas del Modelo" > reporte.md
	cat ./Resultados/metricas.txt >> reporte.md
	echo '\n## Matriz de Confusion' >> reporte.md
	echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)' >> reporte.md
	cml comment create reporte.md

update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Actualizacion con nuevos resultados"
	git push --force origin HEAD:update

hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]" && export PATH="$$HOME/.local/bin:$$PATH" && huggingface-cli login --token $(HF) --add-to-git-credential

push-hub:
	export PATH="$$HOME/.local/bin:$$PATH" && huggingface-cli upload kingabzpro/Drug-Classification ./Aplicacion --repo-type=space --commit-message="Sync App files"
	export PATH="$$HOME/.local/bin:$$PATH" && huggingface-cli upload kingabzpro/Drug-Classification ./Modelo /Modelo --repo-type=space --commit-message="Sync Model"
	export PATH="$$HOME/.local/bin:$$PATH" && huggingface-cli upload kingabzpro/Drug-Classification ./Resultados /Metricas --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub
