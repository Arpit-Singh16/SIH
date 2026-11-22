import 'package:flutter/material.dart';

class CampRequestForm extends StatefulWidget {
  const CampRequestForm({super.key});

  @override
  State<CampRequestForm> createState() => _CampRequestFormState();
}

class _CampRequestFormState extends State<CampRequestForm> {
  // Controllers
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _contactController = TextEditingController();
  final _justificationController = TextEditingController();
  final _venueController = TextEditingController();

  String? _campType;
  DateTime? _preferredDate;

  // Store submitted requests locally
  List<Map<String, dynamic>> requests = [];

  // Function to pick date
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_nameController.text.isEmpty ||
        _villageController.text.isEmpty ||
        _campType == null ||
        _preferredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
      return;
    }

    setState(() {
      requests.add({
        "ashaName": _nameController.text,
        "village": _villageController.text,
        "contact": _contactController.text,
        "campType": _campType,
        "justification": _justificationController.text,
        "venue": _venueController.text,
        "preferredDate": _preferredDate.toString().split(" ")[0],
        "status": "Pending",
      });
    });

    // Clear form
    _nameController.clear();
    _villageController.clear();
    _contactController.clear();
    _justificationController.clear();
    _venueController.clear();
    _campType = null;
    _preferredDate = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Request submitted successfully!")),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5EC), // soft green background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Camp Request Form",style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0F2E05), // dark green
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Fields
            _buildTextField(_nameController, "ASHA Worker Name *"),
            const SizedBox(height: 12),

            _buildTextField(_villageController, "Village/Area *"),
            const SizedBox(height: 12),

            _buildTextField(_contactController, "Contact Number",
                type: TextInputType.phone),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Type of Camp *",
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: _campType,
              items: [
                "General Health Check-up",
                "Maternal & Child Health",
                "Immunization",
                "Eye Check-up",
                "Dental Camp",
                "NCD Screening",
                "TB/Malaria Screening",
                "Adolescent Health",
                "Family Planning",
                "Hygiene & Sanitation",
              ].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) => setState(() => _campType = val),
            ),
            const SizedBox(height: 12),

            _buildTextField(_justificationController, "Justification/Need",
                maxLines: 3),
            const SizedBox(height: 12),

            _buildTextField(_venueController, "Venue"),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _preferredDate == null
                        ? "📅 No Date Chosen"
                        : "📅 Preferred Date: ${_preferredDate!.toString().split(" ")[0]}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2E05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Pick Date",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Submit Request",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const Text(
              "📌 Submitted Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.medical_services,
                        color: Colors.green),
                    title: Text("${req["campType"]} (${req["status"]})"),
                    subtitle: Text(
                      "Village: ${req["village"]}\nDate: ${req["preferredDate"]}\nReason: ${req["justification"]}",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
