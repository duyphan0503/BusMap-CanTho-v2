import 'package:cloud_functions/cloud_functions.dart';

class PaymentService {
  Future<void> createPaymentIntent(String amount) async {
    final result = await FirebaseFunctions.instance.httpsCallable('createPaymentIntent').call({
      'amount': amount,
    });
    String clientSecret = result.data['clientSecret'];
  }
}