import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanCouponPage extends StatefulWidget {
  @override
  _ScanCouponPageState createState() => _ScanCouponPageState();
}

class _ScanCouponPageState extends State<ScanCouponPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _cameraController = MobileScannerController();

  void _claimCoupon(String code) async {
    var snapshot = await _firestore.collection('coupons').where('uniqueID', isEqualTo: code).get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first;
      await doc.reference.update({'claimed': true});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coupon claimed successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coupon not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan or Enter Coupon')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _cameraController,
              onDetect: (barcodeCapture) {
                final barcode = barcodeCapture.barcodes.first;
                final rawValue = barcode.rawValue;

                if (rawValue != null) {
                  _claimCoupon(rawValue);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to scan the barcode. Please try again.')),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Enter Coupon Code',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _claimCoupon(_codeController.text),
            child: Text('Claim Coupon'),
          ),
        ],
      ),
    );
  }
}
