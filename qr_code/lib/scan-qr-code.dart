import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScanQrCode extends StatefulWidget {
  const ScanQrCode({super.key});

  @override
  State<ScanQrCode> createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  String qrResult='Scanned Data will appear hear';
  Future<void> scanQR()async{
    try{
      final qrCode= await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
      if(!mounted)return;
      setState(() {
        this.qrResult=qrCode.toString();
      });
    }on PlatformException{
      qrResult='Fail to read qr code';
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR code scanner'),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Text('$qrResult',style:TextStyle(color: Colors.blue)),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: scanQR, child: Text('Scan the QR code')),
          ],
        ),
      ),

    );
  }
}