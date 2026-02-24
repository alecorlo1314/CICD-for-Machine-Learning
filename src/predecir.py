import skops.io as sio

def load_model(path: str):
    return sio.load(path, trusted=["numpy.dtype"])


def predict(model, features: list):
    return model.predict([features])[0]