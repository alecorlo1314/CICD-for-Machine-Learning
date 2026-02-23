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
	pip install -r requerimientos.txt


# ------------------------------------------------------------
# FORMAT: Formatea el codigo fuente automaticamente
# ------------------------------------------------------------
# Usa Black, el formateador estandar de Python, para aplicar
# un estilo consistente a todos los archivos .py del proyecto.
# Beneficio: elimina discusiones de estilo y mantiene el codigo
# limpio sin esfuerzo manual.
format:
	black *.py


# ------------------------------------------------------------
# TRAIN: Entrena el modelo de Machine Learning
# ------------------------------------------------------------
# Ejecuta train.py, que contiene toda la logica de
# entrenamiento. Al finalizar, genera los archivos de
# resultados que seran usados en la etapa de evaluacion.
train:
	python train.py


# ------------------------------------------------------------
# EVAL: Evalua el modelo y genera un reporte automatico
# ------------------------------------------------------------
# Construye un archivo reporte.md con las metricas y graficos
# del modelo, luego lo publica en GitHub via CML.
eval:
	# --- Construccion del reporte Markdown ---

	# Crea reporte.md con el encabezado principal (> sobreescribe)
	echo "## Metricas del Modelo" > reporte.md

	# Agrega las metricas guardadas en metricas.txt (>> agrega sin sobreescribir)
	# Ejemplo de contenido: Accuracy, F1-Score, Precision, Recall
	cat ./Resultados/metricas.txt >> reporte.md

	# Agrega el titulo de la seccion de la matriz de confusion
	echo '\n## Matriz de Confusion' >> reporte.md

	# Inserta la imagen de la matriz como figura Markdown
	echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)' >> reporte.md

	# --- Publicacion del reporte en GitHub via CML ---
	# CML (Continuous Machine Learning) toma el reporte.md
	# y lo publica como comentario automatico en el Pull Request
	# o commit activo. Resultado: metricas visibles directamente
	# en la interfaz de GitHub sin abrir archivos manualmente.
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
	git commit -am "Actualizacion con nuevos resultados"
	git push --force origin HEAD:update


# ------------------------------------------------------------
# HF-LOGIN: Autentica en Hugging Face Hub
# ------------------------------------------------------------
# 1. Trae los ultimos cambios de la rama 'update'.
# 2. Cambia a esa rama.
# 3. Instala la CLI de Hugging Face (version actualizada).
# 4. Agrega el PATH local para poder usar el binario recien
#    instalado en la misma sesion del shell.
# 5. Inicia sesion con el token HF (variable de entorno secreta)
#    y lo guarda en las credenciales de Git para operaciones
#    posteriores sin re-autenticacion.
hf-login:
    git pull origin update
    git switch update
    pip install -U "huggingface_hub[cli]"
    export PATH="$$PATH:$$HOME/.local/bin" && huggingface-cli login --token ${HUGGING_FACE} --add-to-git-credential

# ------------------------------------------------------------
# PUSH-HUB: Sube archivos al Space de Hugging Face
# ------------------------------------------------------------
# Sincroniza tres carpetas del repositorio con el Space
# 'kingabzpro/Drug-Classification' en Hugging Face:
#
#   ./Aplicacion  --> raiz del Space    (archivos de la app)
#   ./Modelo      --> carpeta /Modelo   (modelo entrenado)
#   ./Resultados  --> carpeta /Metricas (graficos y metricas)
#
# Nota: $$HOME es necesario en Makefile para escapar el signo $
# (un solo $ es interpretado como variable de Make).
push-hub:
    export PATH="$$PATH:$$HOME/.local/bin" && \
    huggingface-cli upload kingabzpro/Drug-Classification ./App --repo-type=space --commit-message="Sync App files" && \
    huggingface-cli upload kingabzpro/Drug-Classification ./Model /Model --repo-type=space --commit-message="Sync Model" && \
    huggingface-cli upload kingabzpro/Drug-Classification ./Results /Metrics --repo-type=space --commit-message="Sync Metrics"

deploy: hf-login push-hub

# ------------------------------------------------------------
# DEPLOY: Despliega la aplicacion completa en Hugging Face
# ------------------------------------------------------------
# Objetivo compuesto que ejecuta en orden:
#   1. hf-login  --> autentica en Hugging Face
#   2. push-hub  --> sube todos los archivos al Space
#
# Uso: make deploy HF="hf_tuTokenAqui"
deploy: hf-login push-hub
