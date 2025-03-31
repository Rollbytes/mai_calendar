import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 行事曆事件模型
class CalendarEvent extends Equatable {
  /// 事件標題
  final String title;

  /// 事件描述
  final String? description;

  /// 開始時間
  final DateTime startTime;

  /// 結束時間
  final DateTime endTime;

  /// 是否為全天事件
  final bool isAllDay;

  /// 事件顏色
  final Color? color;

  /// 創建行事曆事件
  const CalendarEvent({
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.color,
  });

  @override
  List<Object?> get props => [title, description, startTime, endTime, isAllDay, color];
}
