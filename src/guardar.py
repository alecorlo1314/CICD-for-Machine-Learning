import os
import skops.io as sio
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay, confusion_matrix


def save_model(model, path="./Modelo/pipeline.skops"):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    sio.dump(model, path)


def save_metrics(accuracy, f1, path="./Resultados/metricas.txt"):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as outfile:
        outfile.write(f"\nAccuracy = {round(accuracy, 2)}, F1 Score = {round(f1, 2)}")


def save_confusion_matrix(
    model, X_test, y_test, path="./Resultados/matriz_confusion.png"
):
    os.makedirs(os.path.dirname(path), exist_ok=True)

    predictions = model.predict(X_test)
    cm = confusion_matrix(y_test, predictions, labels=model.classes_)
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=model.classes_)
    disp.plot()
    plt.savefig(path, dpi=120)
    plt.close()
