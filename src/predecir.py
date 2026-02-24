import skops.io as sio

def load_model(path: str):
    try:
        return sio.load(path, trusted=["numpy.dtype"])
    except Exception as e:
        raise RuntimeError(f"Error al cargar el modelo: {e}") 


def predict(model, features: list):
    try:
        return model.predict([features])[0]
    except Exception as e:
        raise RuntimeError(f"Error al realizar la predicción: {e}")