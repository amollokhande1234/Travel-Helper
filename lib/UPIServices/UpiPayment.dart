import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:travelhelper/FirebaseServices/FirebaseServieces.dart';

class UpiIntegration extends StatefulWidget {
  final String sender;
  final String dividedAmount;
  final String amount;

  const UpiIntegration({
    super.key,
    required this.sender,
    required this.amount,
    required this.dividedAmount,
  });

  @override
  State<UpiIntegration> createState() => _UpiIntegrationState();
}

class _UpiIntegrationState extends State<UpiIntegration> {
  String? _senderUpiId;
  String? _senderName;
  List<ApplicationMeta>? _apps;
  String? _upiAddrError;
  // late int integerDividedAmount;

  @override
  void initState() {
    super.initState();
    // integerDividedAmount = int.parse(widget.dividedAmount);
    // print(widget.dividedAmount);
    // 1. Fetch UPI ID
    getUpiIdFromUid(widget.sender).then((value) {
      setState(() {
        _senderUpiId = value;
      });
    });
    getSenderName(widget.sender).then((value) {
      setState(() {
        _senderName = value;
      });
    });

    // 2. Load installed UPI apps
    UpiPay.getInstalledUpiApplications(
      statusType: UpiApplicationDiscoveryAppStatusType.all,
    ).then((apps) {
      setState(() {
        _apps = apps;
      });
    });
  }

  // Fetch UPI ID from Firestore
  Future<String?> getUpiIdFromUid(String uid) async {
    try {
      final doc = await fireStore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['upiId'];
      }
    } catch (e) {
      print("Error fetching UPI ID: $e");
    }
    return null;
  }

  // SEnders Name
  Future<String?> getSenderName(String uid) async {
    try {
      final doc = await fireStore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['name'];
      }
    } catch (e) {
      print("Error Fetching Name");
    }
    return null;
  }

  // Start transaction
  Future<void> _onTap(ApplicationMeta app) async {
    try {
      if (_senderUpiId == null || _senderUpiId!.isEmpty) {
        setState(() {
          _upiAddrError = "Invalid UPI ID";
        });
        return;
      }

      setState(() => _upiAddrError = null);

      final transactionRef = Random.secure().nextInt(1 << 32).toString();

      final response = await UpiPay.initiateTransaction(
        app: app.upiApplication,
        receiverName: 'Shared Expense',
        receiverUpiAddress: _senderUpiId!,
        transactionRef: transactionRef,
        transactionNote: 'Shared Expense Payment',
        amount: widget.dividedAmount,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_senderUpiId == null || _apps == null) {
      return Scaffold(
        appBar: AppBar(title: Text("UPI Payment")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new), // Change this to any icon you like
        onPressed: () {
          Navigator.pop(context); // Go back
        },
      ),title: Text("Pay to ${_senderName}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _upiDetailsCard(),
            SizedBox(height: 24),
            Text(
              "Choose a UPI App",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            _appsGrid(_apps!),
            if (_upiAddrError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _upiAddrError!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _upiDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade300,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text("UPI ID: $_senderUpiId", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text(
            "₹${widget.dividedAmount}",
            style: TextStyle(
              fontSize: 25,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort(
      (a, b) => a.upiApplication.getAppName().compareTo(
        b.upiApplication.getAppName(),
      ),
    );
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children:
          apps.map((app) {
            return InkWell(
              onTap: () => _onTap(app),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  app.iconImage(48),
                  SizedBox(height: 6),
                  Text(
                    app.upiApplication.getAppName(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
