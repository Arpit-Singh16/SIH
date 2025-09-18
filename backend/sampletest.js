const axios = require("axios");

const ML_URL = "http://localhost:8000"; // FastAPI ML service

// Two different test inputs
// 173.6	24	6.2	8.53	12.7	Well	Kamrup	11	1
const sample1 = {
  rainfall_mm: 173.6,
  temperature_c: 24,
  ph: 6.2,
  turbidity: 8.53,
  nitrate_mg_per_l: 12.7,
  water_source: "Well",
  district: "Kamrup"
};

const sample2 = {
  rainfall_mm: 200,
  temperature_c: 35,
  ph: 6.5,
  turbidity: 15.0,
  nitrate_mg_per_l: 40.0,
  water_source: "River",
  district: "Guwahati"
};

async function testML() {
  try {
    console.log("🔹 Sending outbreak request (sample1)...");
    const outbreak1 = await axios.post(`${ML_URL}/predict_classification`, 
      sample1,);
    console.log("Outbreak sample1:", outbreak1.data);

    console.log("🔹 Sending outbreak request (sample2)...");
    const outbreak2 = await axios.post(`${ML_URL}/predict_classification`, 
     sample2,
    );
    console.log("Outbreak sample2:", outbreak2.data);

    console.log("🔹 Sending regression request (sample1)...");
    const reg1 = await axios.post(`${ML_URL}/predict_regression`, 
       sample1,
    );
    console.log("Regression sample1:", reg1.data);

    console.log("🔹 Sending regression request (sample2)...");
    const reg2 = await axios.post(`${ML_URL}/predict_regression`, 
       sample2,
    );
    console.log("Regression sample2:", reg2.data);

  } catch (err) {
    console.error("❌ ML service error:", err.response?.data || err.message);
  }
}

testML();