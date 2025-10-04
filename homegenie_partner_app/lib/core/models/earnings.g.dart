// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) =>
    EarningsSummary(
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      pendingAmount: (json['pending_amount'] as num).toDouble(),
      withdrawnAmount: (json['withdrawn_amount'] as num).toDouble(),
      availableForWithdrawal:
          (json['available_for_withdrawal'] as num).toDouble(),
      totalJobs: json['total_jobs'] as int,
      completedJobs: json['completed_jobs'] as int,
      averageRating: (json['average_rating'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningsSummaryToJson(EarningsSummary instance) =>
    <String, dynamic>{
      'total_earnings': instance.totalEarnings,
      'pending_amount': instance.pendingAmount,
      'withdrawn_amount': instance.withdrawnAmount,
      'available_for_withdrawal': instance.availableForWithdrawal,
      'total_jobs': instance.totalJobs,
      'completed_jobs': instance.completedJobs,
      'average_rating': instance.averageRating,
    };

EarningsTransaction _$EarningsTransactionFromJson(Map<String, dynamic> json) =>
    EarningsTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      jobId: json['job_id'] as String?,
      jobName: json['job_name'] as String?,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
    );

Map<String, dynamic> _$EarningsTransactionToJson(
        EarningsTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'job_id': instance.jobId,
      'job_name': instance.jobName,
      'description': instance.description,
      'transaction_date': instance.transactionDate.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
    };

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    WithdrawalRequest(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      bankAccountNumber: json['bank_account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      upiId: json['upi_id'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      rejectionReason: json['rejection_reason'] as String?,
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'status': instance.status,
      'bank_account_number': instance.bankAccountNumber,
      'ifsc_code': instance.ifscCode,
      'upi_id': instance.upiId,
      'requested_at': instance.requestedAt.toIso8601String(),
      'processed_at': instance.processedAt?.toIso8601String(),
      'rejection_reason': instance.rejectionReason,
    };
