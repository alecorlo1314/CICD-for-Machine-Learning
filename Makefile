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

    echo "## Matriz de Confusion" >> reporte.md
    echo "![Matriz de Confusion](./Resultados/matriz_confusion.png)" >> reporte.md

    cml comment create reporte.md