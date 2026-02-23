#Objetivo: prepara el entorno.
install:
#Actualiza pip a la última versión.
	pip install --upgrade pip &&\

#instala todas las dependencias listadas en requirements.txt.
#El &&\ asegura que el segundo comando solo se ejecute si el primero termina bien.
		pip install -r requerimientos.txt

#Objetivo: formatear el código.
#Usa Black, un formateador automático de Python, para aplicar estilo consistente a todos los archivos .py del proyecto.
#Esto ayuda a mantener un código limpio y estandarizado.
format:
	black *.py

#Objetivo: entrenar el modelo.
#Ejecuta el script train.py, que seguramente contiene la lógica de entrenamiento de tu modelo de machine learning.
#Este paso genera los resultados que luego se evaluarán.
train:
	python train.py

#Objetivo: evaluar y documentar el modelo.
eval:
#Crea un archivo report.md con:
#Encabezado “Metricas del Modelo”.
	echo "## Metricas del Modelo" > reporte.md
#Inserta el contenido de ./Results/metricas.txt (ejemplo métricas como accuracy, F1, etc.).
	cat ./Resultados/metricas.txt >> reporte.md
#Añade un título para la matriz de confusión.
	echo '\n## Matriz de Confusion' >> reporte.md
#Inserta la imagen model_results.png como gráfico.
	echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)' >> reporte.md

#Se usa CML (Continuous Machine Learning) para publicar ese reporte como comentario en el pull request o commit en GitHub.
#Esto significa que cada vez que corra el pipeline, tendrás un informe automático con métricas y visualizaciones directamente en la interfaz de GitHub.
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
