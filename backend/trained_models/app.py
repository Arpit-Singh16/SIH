from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pickle
import pandas as pd

# Load pipeline models (with preprocessing)
with open("best_classifier.pkl", "rb") as f:
    clf_model = pickle.load(f)

with open("best_regressor.pkl", "rb") as f:
    reg_model = pickle.load(f)

app = FastAPI()

# Define input schema (7 features)
class InputData(BaseModel):
    rainfall_mm: float
    temperature_c: float
    ph: float
    turbidity: float
    nitrate_mg_per_l: float
    water_source: str
    district: str


@app.post("/predict_classification")
async def predict_class(data: InputData):
    try:
        # Convert Pydantic object -> DataFrame
        features = pd.DataFrame([data.dict()])

        prediction = clf_model.predict(features)
        outbreak_prediction = int(prediction[0])

        outbreak_percentage = None
        if hasattr(clf_model, "predict_proba"):
            probas = clf_model.predict_proba(features)
            outbreak_percentage = round(float(probas[0][1]) * 100, 2)
        print(f"Outbreak Probability: {outbreak_percentage}%")
        return {
            "outbreak_prediction": outbreak_prediction,
            "outbreak_probability_percentage": outbreak_percentage
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict_regression")
async def predict_regression(data: InputData):
    try:
        features = pd.DataFrame([data.dict()])
        prediction = reg_model.predict(features)
        return {"confirmed_waterborne_cases": float(prediction[0])}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



