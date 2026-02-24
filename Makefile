# ============================================================
# MAKEFILE - Pipeline CI/CD para Proyecto de Machine Learning
# ============================================================
# Uso: make <objetivo>
# Ejemplo: make install | make train | make deploy
# ============================================================


# ------------------------------------------------------------
# INSTALL: Prepara el entorno de trabajo
# ------------------------------------------------------------
# 1. Actualiza pip a la ultima version disponible.
# 2. Instala todas las dependencias del proyecto listadas
#    en requerimientos.txt.
# El operador &&\ encadena comandos: el segundo solo se ejecuta
# si el primero finalizo exitosamente (codigo de salida 0).
install:
	pip install --upgrade pip &&\
	pip install -r requirements.txt

# ------------------------------------------------------------
# FORMAT: Formatea el codigo fuente automaticamente
# ------------------------------------------------------------
# Usa Black, el formateador estandar de Python, para aplicar
# un estilo consistente a todos los archivos .py del proyecto.
# Beneficio: elimina discusiones de estilo y mantiene el codigo
# limpio sin esfuerzo manual.
format-check:
	black --check .

# ------------------------------------------------------------
# TRAIN: Entrena el modelo de Machine Learning
# ------------------------------------------------------------
# Ejecuta train.py, que contiene toda la logica de
# entrenamiento. Al finalizar, genera los archivos de
# resultados que seran usados en la etapa de evaluacion.
train:
	python -m train


lint:
	flake8 --ignore E203 --max-line-length 100 src Aplicacion

test:
	pytest

# ------------------------------------------------------------
# EVAL: Evalua el modelo y genera un reporte automatico
# ------------------------------------------------------------
# Construye un archivo reporte.md con las metricas y graficos
# del modelo, luego lo publica en GitHub via CML.
eval:
	test -f ./Resultados/metricas.txt
	echo "## Metricas del Modelo" > reporte.md
	cat ./Resultados/metricas.txt >> reporte.md
	echo '\n## Matriz de Confusion' >> reporte.md
	echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)' >> reporte.md
	cml comment create reporte.md

# ------------------------------------------------------------
# UPDATE-BRANCH: Sube los resultados a la rama 'update'
# ------------------------------------------------------------
# Configura la identidad de Git usando variables de entorno
# (USER_NAME y USER_EMAIL deben pasarse al invocar make).
# Hace commit de todos los cambios y los sube forzadamente
# a la rama remota 'update' para que CD pueda tomarlos.
#
# Uso: make update-branch USER_NAME="Tu Nombre" USER_EMAIL="tu@email.com"
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git add .
	git diff --cached --quiet || git commit -m "Actualizacion con nuevos resultados"
	git push origin HEAD:update

# ------------------------------------------------------------
# HF-LOGIN: Autentica en Hugging Face Hub
# ------------------------------------------------------------
hf-login:
	git fetch origin
	git switch -c update --track origin/update || git switch update
	pip install -U "huggingface_hub[cli]"
	git config --global credential.helper store
	hf auth login --token $(HF) --add-to-git-credential
	hf auth whoami
# ------------------------------------------------------------
# PUSH-HUB: Sube archivos al Space de Hugging Face
# ------------------------------------------------------------
push-hub:
	hf upload alecorlo1234/Clasificacion-Medicinas ./Aplicacion --repo-type space --commit-message "Sync Archivos de la App"
	hf upload alecorlo1234/Clasificacion-Medicinas ./Modelo /Modelo --repo-type=space --commit-message="Sync Modelo"
	hf upload alecorlo1234/Clasificacion-Medicinas ./Resultados /Metricas --repo-type=space --commit-message="Sync Metricas"

# ------------------------------------------------------------
# DEPLOY: Despliega la aplicacion completa en Hugging Face
# ------------------------------------------------------------
# Objetivo compuesto que ejecuta en orden:
#   1. hf-login  --> autentica en Hugging Face
#   2. push-hub  --> sube todos los archivos al Space
#
# Uso: make deploy HF="hf_tuTokenAqui"
deploy: hf-login push-hub
