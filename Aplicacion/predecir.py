import skops.io as sio


def load_model():
    return sio.load("Modelo/pipeline.skops", trusted=["numpy.dtype"])


def predict(model, data):
    return model.predict([data])[0]
