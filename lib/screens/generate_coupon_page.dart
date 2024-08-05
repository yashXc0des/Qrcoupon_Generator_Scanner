import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GenerateCouponPage extends StatefulWidget {
  @override
  _GenerateCouponPageState createState() => _GenerateCouponPageState();
}

class _GenerateCouponPageState extends State<GenerateCouponPage> {
  final _numberController = TextEditingController();
  final _validityController = TextEditingController();

  Future<void> _generateCoupons() async {
    final firestore = FirebaseFirestore.instance;
    final numberOfCoupons = int.tryParse(_numberController.text) ?? 0;
    final validity = DateTime.tryParse(_validityController.text);

    if (numberOfCoupons > 0 && validity != null) {
      for (int i = 0; i < numberOfCoupons; i++) {
        final uniqueID = Uuid().v4();
        final serialNumber = i + 1;
        await firestore.collection('coupons').add({
          'uniqueID': uniqueID,
          'serialNumber': serialNumber,
          'validity': validity,
          'claimed': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupons generated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid number and validity date.')),
      );
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
              keyboardType: TextInputType.datetime,
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
