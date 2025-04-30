import 'package:scan_barcode_app/data/models/content_payment/content_payment_model.dart';

abstract class PaymentContentState {}

class PaymentContentInitial extends PaymentContentState {}

class PaymentContentLoading extends PaymentContentState {}

class PaymentContentLoaded extends PaymentContentState {
  final PaymentContentModel content;
  final double? calculatedAmount;

  PaymentContentLoaded(this.content, {this.calculatedAmount});
}

class PaymentContentError extends PaymentContentState {
  String message;
  PaymentContentError(this.message);
}
