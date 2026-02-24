import pandas as pd
import skops.io as sio
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn.impute import SimpleImputer
from sklearn.metrics import accuracy_score, f1_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OrdinalEncoder, StandardScaler
#Cargar datos desde src/data.py
from src.data import load_data
from src.train import train_model

from src.train import build_pipeline

medicamentos_df = load_data("Datos/drug200.csv")
## Loading the Data
#medicamentos_df = pd.read_csv("Datos/drug200.csv")
medicamentos_df = medicamentos_df.sample(frac=1)

## Train Test Split
from sklearn.model_selection import train_test_split

X = medicamentos_df.drop("Drug", axis=1).values
y = medicamentos_df.Drug.values

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=125
)

#Contruir el pipeline
pipe = build_pipeline()

#Entrenamiento del modelo
pipe.fit(X_train, y_train)

## Model Evaluation
from src.evaluate import evaluate_model
accuracy, f1, predictions = evaluate_model(pipe, X_test, y_test)

print("Accuracy:", str(round(accuracy, 2) * 100) + "%", "F1:", round(f1, 2))


## Confusion Matrix Plot
import matplotlib.pyplot as plt
from sklearn.metrics import ConfusionMatrixDisplay, confusion_matrix

predictions = pipe.predict(X_test)
cm = confusion_matrix(y_test, predictions, labels=pipe.classes_)
disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=pipe.classes_)
disp.plot()
plt.savefig("./Resultados/matriz_confusion.png", dpi=120)

## Write metrics to file
with open("./Resultados/metricas.txt", "w") as outfile:
    outfile.write(f"\nAccuracy = {round(accuracy, 2)}, F1 Score = {round(f1, 2)}")

## Saving the model file
sio.dump(pipe, "./Modelo/pipeline.skops")
