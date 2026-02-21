install:
    pip install --upgrade pip &&\
        pip install black &&\
        pip install -r requerimientos.txt

format:
    black *.py

train:
    python train.py

eval:
    echo "## Model Metrics" > reporte.md
    cat ./Resultados/metricas.txt >> reporte.md
   
    echo '\n## Confusion Matrix Plot' >> reporte.md
    echo '![Confusion Matrix](./Resultados/matriz_confusion.png)' >> reporte.md
   
    cml comment create reporte.md