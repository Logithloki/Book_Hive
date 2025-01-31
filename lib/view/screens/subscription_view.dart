// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../controller/subscription_controller.dart';
import '../../model/subscription.dart';

class SubscriptionScreen extends StatelessWidget {
  final SubscriptionController _controller = SubscriptionController();

  @override
  Widget build(BuildContext context) {
    List<SubscriptionPlan> plans = _controller.getPlans();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Subscription', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT THE BEST SUBSCRIPTION FOR YOU',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ...plans.map((plan) => SubscriptionCard(plan: plan)).toList(),
          ],
        ),
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final SubscriptionPlan plan;

  SubscriptionCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Validity: ${plan.validity}'),
            Text('Ads: ${plan.ads}'),
            SizedBox(height: 10),
            Text(plan.price,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle plan selection
                },
                child: Text('Select Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
