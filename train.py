from src.guardar import save_model, save_metrics, save_confusion_matrix
from src.datos import load_data
from src.entrenar import build_pipeline
from src.evaluar import evaluate_model
from sklearn.model_selection import train_test_split


def main():
    medicamentos_df = load_data("Datos/drug200.csv")
    medicamentos_df = medicamentos_df.sample(frac=1)

    X = medicamentos_df.drop("Drug", axis=1).values
    y = medicamentos_df.Drug.values

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.3, random_state=125
    )

    pipe = build_pipeline()
    pipe.fit(X_train, y_train)

    accuracy, f1, predictions = evaluate_model(pipe, X_test, y_test)

    print("Accuracy:", str(round(accuracy, 2) * 100) + "%", "F1:", round(f1, 2))

    save_confusion_matrix(pipe, X_test, y_test)
    save_metrics(accuracy, f1)
    save_model(pipe)


if __name__ == "__main__":
    main()
