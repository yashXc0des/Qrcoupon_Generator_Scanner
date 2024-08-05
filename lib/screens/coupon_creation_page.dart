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

  int _lastSerialNumber = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLastSerialNumber();
  }

  Future<void> _fetchLastSerialNumber() async {
    var lastCouponQuery = await _firestore.collection('coupons')
        .orderBy('serialNumber', descending: true).limit(1).get();
    if (lastCouponQuery.docs.isNotEmpty) {
      var lastCoupon = lastCouponQuery.docs.first.data();
      String lastSerialStr = lastCoupon['serialNumber'];
      _lastSerialNumber = int.parse(lastSerialStr.split('-').last);
    } else {
      _lastSerialNumber = 0; // If no coupons exist, start from 0
    }
  }

  void _generateCoupons() async {
    int numberOfCoupons = int.tryParse(_numberController.text) ?? 0;
    DateTime validityDate;

    try {
      validityDate = DateTime.parse(_validityController.text);
    } catch (e) {
      _showErrorDialog('Invalid date format. Please enter a valid date in YYYY-MM-DD format.');
      return;
    }

    if (numberOfCoupons > 0) {
      setState(() {
        _isLoading = true;
      });

      String serialPrefix = 'COUPON';

      for (int i = 1; i <= numberOfCoupons; i++) {
        String uniqueID = Uuid().v4();
        _lastSerialNumber++; // Increment the last serial number
        String serialNumber = '$serialPrefix-$_lastSerialNumber';

        await _firestore.collection('coupons').add({
          'serialNumber': serialNumber,
          'uniqueID': uniqueID,
          'validity': validityDate.toIso8601String(),
          'claimed': false,
        });
      }

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(numberOfCoupons, validityDate);
    } else {
      _showErrorDialog('invalid number of coupons. Please enter a valid number.');
    }
  }

  void _showSuccessDialog(int numberOfCoupons, DateTime validityDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(
              'Successfully created $numberOfCoupons coupons valid until ${validityDate.toLocal().toString().split(' ')[0]}.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _numberController.clear();
                _validityController.clear();// yhape controller clear krna is good practice
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Coupons')),
      body: Stack(
        children: [
          Padding(
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
