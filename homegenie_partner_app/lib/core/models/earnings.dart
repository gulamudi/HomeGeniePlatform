import 'package:json_annotation/json_annotation.dart';

part 'earnings.g.dart';

@JsonSerializable()
class EarningsSummary {
  final double totalEarnings;
  final double pendingAmount;
  final double withdrawnAmount;
  final double availableForWithdrawal;
  final int totalJobs;
  final int completedJobs;
  final double averageRating;

  EarningsSummary({
    required this.totalEarnings,
    required this.pendingAmount,
    required this.withdrawnAmount,
    required this.availableForWithdrawal,
    required this.totalJobs,
    required this.completedJobs,
    required this.averageRating,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EarningsSummaryToJson(this);
}

@JsonSerializable()
class EarningsTransaction {
  final String id;
  final String type; // 'job_payment', 'withdrawal', 'bonus', 'deduction'
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final String? jobId;
  final String? jobName;
  final String? description;
  final DateTime transactionDate;
  final DateTime? completedAt;

  EarningsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.jobId,
    this.jobName,
    this.description,
    required this.transactionDate,
    this.completedAt,
  });

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      _$EarningsTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$EarningsTransactionToJson(this);
}

@JsonSerializable()
class WithdrawalRequest {
  final String id;
  final double amount;
  final String status; // 'pending', 'processing', 'completed', 'failed'
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? upiId;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? rejectionReason;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.status,
    this.bankAccountNumber,
    this.ifscCode,
    this.upiId,
    required this.requestedAt,
    this.processedAt,
    this.rejectionReason,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);
}
