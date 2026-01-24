// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      alias: json['alias'] as String,
      walletAddress: json['walletAddress'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      yieldSharePercent: (json['yieldSharePercent'] as num).toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'alias': instance.alias,
      'walletAddress': instance.walletAddress,
      'currentBalance': instance.currentBalance,
      'yieldSharePercent': instance.yieldSharePercent,
    };
