
# try Both mathod as your output i have modified according to first one and comment that for json one try both for ur reqiurements


from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pickle
import pandas as pd

# Load pipeline models (which include preprocessing)
with open("best_classifier.pkl", "rb") as f:
    clf_model = pickle.load(f)

app = FastAPI()

# Define input schema with fields corresponding to the original feature columns
class InputData(BaseModel):
    Coliform_Presence: int
    Turbidity_NTU: float
    Nitrate_mg_L: float
    Ammonia_mg_L: float
    pH: float
    Temperature_C: float
    Humidity_: float

@app.post("/predict_classification")
async def predict_class(data: InputData):
    try:
        # Convert Pydantic model to DataFrame with original column ordering
        features = pd.DataFrame([data.dict()])
        prediction = clf_model.predict(features)
        outbreak_prediction = int(prediction[0])

        outbreak_percentage = None
        if hasattr(clf_model, "predict_proba"):
            probas = clf_model.predict_proba(features)
            outbreak_percentage = round(float(probas[0][1]) * 100, 2)

        return {
            "outbreak_prediction": outbreak_prediction,
            "outbreak_probability_percentage": outbreak_percentage
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



# # Define feature columns exactly as in your training data
# feature_columns = [
#   'Coliform_Presence',
#   'Turbidity_NTU',
#   'Nitrate_mg_L',
#   'Ammonia_mg_L',
#   'pH',
#   'Temperature_C',
#   'Humidity_%'
# ]

# @app.post("/predict_classification")
# async def predict_class(request: Request):
#     try:
#         data = await request.json()
#         features = pd.DataFrame([data["input"]], columns=feature_columns)
#         prediction = clf_model.predict(features)
#         # Convert to native int
#         outbreak_prediction = int(prediction[0])

#         # Optional: get probability if desired
#         if hasattr(clf_model, "predict_proba"):
#             probas = clf_model.predict_proba(features)
#             outbreak_prob = float(probas[0][1])  # Convert numpy float32 to native float
#             outbreak_percentage = round(outbreak_prob * 100, 2)
#         else:
#             outbreak_percentage = None

#         return {
#             "outbreak_prediction": outbreak_prediction,
#             "outbreak_probability_percentage": outbreak_percentage
#         }
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

