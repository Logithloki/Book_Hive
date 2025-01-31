import '../model/subscription.dart';
class SubscriptionController {
  List<SubscriptionPlan> getPlans() {
    return [
      SubscriptionPlan(title: 'BASIC', validity: 'Unlimited', ads: '1', price: '80 LKR'),
      SubscriptionPlan(title: 'BASIC', validity: '60 Days', ads: '10', price: '600 LKR'),
    ];
  }
}