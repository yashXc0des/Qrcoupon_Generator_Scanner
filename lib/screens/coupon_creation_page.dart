import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CouponCreationPage extends StatefulWidget {
  @override
  _CouponCreationPageState createState() => _CouponCreationPageState();
}

class _CouponCreationPageState extends State<CouponCreationPage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _validityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _generateCoupons() async {
    int numberOfCoupons = int.tryParse(_numberController.text) ?? 0;
    DateTime validityDate = DateTime.parse(_validityController.text);
    String serialPrefix = 'COUPON';

    if (numberOfCoupons > 0) {
      for (int i = 1; i <= numberOfCoupons; i++) {
        String uniqueID = Uuid().v4();
        String serialNumber = '$serialPrefix-$i';

        await _firestore.collection('coupons').add({
          'serialNumber': serialNumber,
          'uniqueID': uniqueID,
          'validity': validityDate.toIso8601String(),
          'claimed': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coupons generated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid number of coupons')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Coupons')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Coupons'),
            ),
            TextField(
              controller: _validityController,
              decoration: InputDecoration(labelText: 'Validity Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateCoupons,
              child: Text('Generate Coupons'),
            ),
          ],
        ),
      ),
    );
  }
}
