import gradio as gr
import skops.io as sio

pipiline = sio.load("../Modelo/pipeline.skops", trusted=['numpy.dtype'])

def prediccion(age, sex, blood_pressure, cholesterol, na_to_k_ratio):
    """Predice el medicamento basado en las características del paciente

    Args:
        age (int): Edad del paciente
        sex (str): Sexo del paciente (M/F)
        blood_pressure (str): Presión sanguínea del paciente (HIGH/LOW)
        cholesterol (str): Nivel de colesterol del paciente (HIGH/NORMAL)
        na_to_k_ratio (float): Relación sodio/potasio del paciente

    Returns:
        str: Medicamento recomendado para el paciente
    """

    caracteristicas = [age, sex, blood_pressure, cholesterol, na_to_k_ratio]
    medicamento_predicho = pipiline.predict([caracteristicas])[0]

    label = f"El medicamento recomendado para el paciente es: {medicamento_predicho}"
    return label

entradas = [
    gr.Slider(15, 74, step=1, label="Edad"),
    gr.Radio(["M", "F"], label="Sexo"),
    gr.Radio(["HIGH", "LOW", "NORMAL"], label="Presión sanguínea"),
    gr.Radio(["HIGH", "NORMAL"], label="Nivel de colesterol"),
    gr.Slider(6.2, 38.2, step=0.1, label="Relación sodio/potasio"),
]
salida = [gr.Label(num_top_classes=5)]

ejemplos = [
    [23, "M", "HIGH", "HIGH", 25.355],
    [47, "F", "LOW", "HIGH", 13.093],
    [47, "F", "LOW", "HIGH", 10.114],
    [28, "F", "NORMAL", "HIGH", 7.798],
    [61, "M", "HIGH", "NORMAL", 18.043],
]

titulo = "Predicción de Medicamento para Pacientes"
descripcion = "Ingrese las características del paciente para obtener una recomendación de medicamento."
articulo = "Este modelo utiliza un clasificador Random Forest para predecir el medicamento más adecuado para un paciente basado en su edad, sexo, presión sanguínea, nivel de colesterol y relación sodio/potasio."

gr.Interface(
    fn=prediccion,
    inputs=entradas,
    outputs=salida,
    examples=ejemplos,
    title=titulo,
    description=descripcion,
    article=articulo,
    theme=gr.themes.Soft(),
).launch()

"""
Abrir la terminal y ejecutar el siguiente comando para iniciar la aplicación:
python ./Aplicacion/drug_app.py
"""