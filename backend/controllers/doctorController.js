const Prediction=require('../models/Prediction');
const User=require('../models/User');

// =======================
// GET /api/doctor/predictions?district=XYZ
// =======================
// exports.getPredictionsByDistrict=async(req,res)=>{
//     try{
//         const {district}=req.query;
//         if(!district){
//             return res.status(400).json({success:false,message:"District is required"});
//         }
//         const predictions = await Prediction.find({ district })
//       .populate("user", "name email village district") // also return some user info
//       .sort({ createdAt: -1 });

//       res.status(200).json({
//         success: true,
//         district: district,
//         total:predictions.length,
//         data: predictions
//       });
//     }catch (error) {
//     console.error("❌ Doctor dashboard error:", error.message);
//     res.status(500).json({
//       success: false,
//       message: error.message,
//     });
//   }
// }
  

exports.getAllPredictions = async (req, res) => {
  try {
    const predictions = await Prediction.find()
      .populate({ path: "user", select: "name email village district", strictPopulate: false })
      .sort({ createdAt: -1 }); // latest first

    res.status(200).json({
      success: true,
      total: predictions.length,
      data: predictions
    });
  } catch (error) {
    console.error("❌ Error fetching all predictions:", error.message);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

exports.getPredictionsByDistrict = async (req, res) => {
  try {
    let { district } = req.query;

    let filter = {};
    if (district && district.trim() !== "") {
      // Case-insensitive match for the district
      district = district.trim();
      filter.district = { $regex: new RegExp(`^${district}$`, "i") };
    }

    // Fetch predictions
    const predictions = await Prediction.find(filter)
      .populate({ path: "user", select: "name email village district", strictPopulate: false })
      .sort({ createdAt: -1 });

    console.log(`✅ Fetched ${predictions.length} predictions`);

    res.status(200).json({
      success: true,
      district: district || "All",
      total: predictions.length,
      data: predictions,
    });
  } catch (error) {
    console.error("❌ Error fetching predictions:", error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};



// =======================
// GET /api/doctor/predictions/village?village=ABC
// =======================
exports.getPredictionsByVillage = async (req, res) => {
  try {
    const { village } = req.query;

    if (!village) {
      return res.status(400).json({
        success: false,
        message: "Village query parameter is required",
      });
    }

    const predictions = await Prediction.find({ village })
      .populate("user", "name email village district")
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      village,
      total: predictions.length,
      data: predictions,
    });
  } catch (error) {
    console.error("❌ Doctor dashboard error (village):", error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// =======================
// GET /api/doctor/dashboard/summary
// =======================
// Simple summary grouped by district
exports.getDistrictSummary = async (req, res) => {
  try {
    const summary = await Prediction.aggregate([
      {
        $group: {
          _id: "$district",
          totalPredictions: { $sum: 1 },
          latestOutbreak: { $last: "$result.outbreakChance" },
        },
      },
    ]);

    res.status(200).json({
      success: true,
      summary,
    });
  } catch (error) {
    console.error("❌ Doctor summary error:", error.message);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
// =======================
// 📊 Graph-friendly endpoint
// GET /api/doctor/predictions/graph?district=XYZ
// =======================
exports.getGraphDataByDistrict = async (req, res) => {
  try {
    const { district } = req.query;

    if (!district) {
      return res.status(400).json({
        success: false,
        message: "District query parameter is required",
      });
    }

    const graphData = await Prediction.aggregate([
      { $match: { district } },
      {
        $group: {
          _id: {
            date: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }
          },
          avgOutbreakChance: { $avg: "$result.outbreakChance" },
          totalPredictions: { $sum: 1 }
        }
      },
      { $sort: { "_id.date": 1 } } // sort by date
    ]);

    res.status(200).json({
      success: true,
      district,
      graphData
    });
  } catch (error) {
    console.error("❌ Graph data error:", error.message);
    res.status(500).json({ success: false, message: error.message });
  }
};
