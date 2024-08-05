import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/coupon.dart';

class CouponListPage extends StatefulWidget {
  const CouponListPage({super.key});

  @override
  _CouponListPageState createState() => _CouponListPageState();
}

class _CouponListPageState extends State<CouponListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  bool _showClaimed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coupon List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(

              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Show Claimed'),
              Switch(
                value: _showClaimed,
                onChanged: (value) {
                  setState(() {
                    _showClaimed = value;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('coupons')
                  .where('uniqueID', isGreaterThanOrEqualTo: _searchQuery)
                  .where('uniqueID', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
                  .where('claimed', isEqualTo: _showClaimed)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No coupons found'));
                }
                var coupons = snapshot.data!.docs.map((doc) => Coupon.fromMap(doc.data() as Map<String, dynamic>)).toList();
                return ListView.builder(
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    var coupon = coupons[index];
                    return ListTile(
                      leading: QrImageView(
                        data: coupon.uniqueID,
                        size: 80.0,
                      ),
                      title: Text('Serial: ${coupon.serialNumber}'),
                      subtitle: Text('Unique ID: ${coupon.uniqueID}\nValidity: ${coupon.validity.toLocal()}'),
                      trailing: Text(coupon.claimed ? 'Claimed' : 'Unclaimed'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
