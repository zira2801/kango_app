abstract class PaymentContentEvent {}

class LoadPaymentContent extends PaymentContentEvent {
  final String kind;
  LoadPaymentContent(this.kind);
}

class CalculateUSDTAmount extends PaymentContentEvent {
  final double amount;
  CalculateUSDTAmount(this.amount);
}
