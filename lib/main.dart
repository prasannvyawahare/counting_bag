import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() => runApp(SerialPortApp());

class SerialPortApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ComSetting(),
    );
  }
}

class ComSetting extends StatefulWidget {
  @override
  _ComSettingState createState() => _ComSettingState();
}

class _ComSettingState extends State<ComSetting> {
  final TextEditingController baudRateController =
  TextEditingController(text: "4800");
  final TextEditingController dataBitsController =
  TextEditingController(text: "8");
  final TextEditingController parityController =
  TextEditingController(text: "None");
  final TextEditingController stopBitsController =
  TextEditingController(text: "1");

  List<String> availablePorts = [];
  String? selectedPort;

  @override
  void initState() {
    super.initState();
    fetchAvailablePorts();
  }

  void fetchAvailablePorts() {
    setState(() {
      availablePorts = SerialPort.availablePorts;
      selectedPort = availablePorts.isNotEmpty ? availablePorts.first : null;
    });
  }

  void saveSettings() {
    if (selectedPort == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a port")),
      );
      return;
    }

    final settings = {
      'Port Name': selectedPort,
      'Baud Rate': baudRateController.text,
      'Data Bits': dataBitsController.text,
      'Parity': parityController.text,
      'Stop Bits': stopBitsController.text,
    };

    // Print settings to console or handle them as needed
    print("Serial Port Settings: $settings");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Settings saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configure Serial Port",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 300.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildPortDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField("Baud Rate", baudRateController),
                    const SizedBox(height: 16),
                    _buildTextField("Data Bits", dataBitsController),
                    const SizedBox(height: 16),
                    _buildTextField("Parity", parityController),
                    const SizedBox(height: 16),
                    _buildTextField("Stop Bits", stopBitsController),
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                          ),
                          child: const Text(
                            "SAVE",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Port Name:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        DropdownButton<String>(
          value: selectedPort,
          items: availablePorts
              .map((port) => DropdownMenuItem(
            value: port,
            child: Text(port),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedPort = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 180,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
