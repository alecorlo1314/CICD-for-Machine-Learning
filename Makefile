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
    echo '![Matriz de Confusion](./Resultados/matriz_confusion.png)'' >> reporte.md

    cml comment create reporte.md

update-branch:
    git config --global user.name $(USER_NAME)
    git config --global user.email $(USER_EMAIL)
    git commit -am "Actualizacion con nuevos resultados"
    git push --force origin HEAD:update