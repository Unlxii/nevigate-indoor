import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/app_config.dart';

class BluetoothService {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus();
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  
  final StreamController<List<int>> _dataStreamController = 
      StreamController<List<int>>.broadcast();
  
  Stream<List<int>> get dataStream => _dataStreamController.stream;
  
  bool get isConnected => _connectedDevice != null;
  
  // Request necessary permissions
  Future<bool> requestPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final location = await Permission.locationWhenInUse.request();
    
    return bluetoothScan.isGranted && 
           bluetoothConnect.isGranted && 
           location.isGranted;
  }
  
  // Scan for ESP UWB devices
  Future<List<BluetoothDevice>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Bluetooth permissions not granted');
    }
    
    final devices = <BluetoothDevice>[];
    
    // Start scanning
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );
    
    // Listen to scan results
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        if (result.device.name.startsWith(AppConfig.deviceNamePrefix)) {
          if (!devices.any((d) => d.id == result.device.id)) {
            devices.add(result.device);
          }
        }
      }
    });
    
    // Wait for timeout
    await Future.delayed(timeout);
    
    // Stop scanning
    await FlutterBluePlus.stopScan();
    await subscription.cancel();
    
    return devices;
  }
  
  // Connect to a specific device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: AppConfig.connectionTimeout,
        autoConnect: false,
      );
      
      _connectedDevice = device;
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find the UWB data service and characteristic
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            _dataCharacteristic = characteristic;
            
            // Subscribe to notifications
            await characteristic.setNotifyValue(true);
            
            // Listen for data
            characteristic.value.listen((value) {
              if (value.isNotEmpty) {
                _dataStreamController.add(value);
              }
            });
            
            break;
          }
        }
        if (_dataCharacteristic != null) break;
      }
      
      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }
  
  // Disconnect from device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _dataCharacteristic = null;
    }
  }
  
  // Send command to device
  Future<void> sendCommand(List<int> command) async {
    if (_dataCharacteristic != null && 
        _dataCharacteristic!.properties.write) {
      await _dataCharacteristic!.write(command);
    }
  }
  
  void dispose() {
    disconnect();
    _dataStreamController.close();
  }
}
