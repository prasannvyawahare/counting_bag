import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serial Port Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SerialPortExample(),
    );
  }
}

class SerialPortExample extends StatefulWidget {
  @override
  _SerialPortExampleState createState() => _SerialPortExampleState();
}

class _SerialPortExampleState extends State<SerialPortExample> {
  List<String> availablePorts = [];
  SerialPort? selectedPort;
  String receivedData = "";
  SerialPortReader? portReader;

  @override
  void initState() {
    super.initState();
    _listAvailablePorts();
  }

  void _listAvailablePorts() {
    final ports = SerialPort.availablePorts;
    setState(() {
      availablePorts = ports;
    });
  }

  void _connectToPort(String portName) {
    try {
      final port = SerialPort(portName);
      if (!port.openReadWrite()) {
        throw Exception(SerialPort.lastError);
      }

      // Set port properties
      port.config.baudRate = 9600;
      port.config.bits = 8;
      port.config.stopBits = 1;
      port.config.parity = SerialPortParity.none;

      // Start reading data
      portReader = SerialPortReader(port);
      portReader!.stream.listen((data) {
        setState(() {
          receivedData += String.fromCharCodes(data);
        });
      });

      setState(() {
        selectedPort = port;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to $portName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to $portName: $e')),
      );
    }
  }

  void _disconnectPort() {
    portReader?.close();
    selectedPort?.close();
    setState(() {
      selectedPort = null;
      receivedData = "";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disconnected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Serial Port Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Serial Ports:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...availablePorts.map((port) {
              return ListTile(
                title: Text(port),
                trailing: selectedPort?.name == port
                    ? ElevatedButton(
                  onPressed: _disconnectPort,
                  child: Text('Disconnect'),
                )
                    : ElevatedButton(
                  onPressed: () => _connectToPort(port),
                  child: Text('Connect'),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              'Received Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 200,
              child: SingleChildScrollView(
                child: Text(receivedData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disconnectPort();
    super.dispose();
  }
}
