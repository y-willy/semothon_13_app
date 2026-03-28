import 'package:flutter/material.dart';

class ScheduleModel {
  final int id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ScheduleModel({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: _parseTime(json['startTime'] as String),
      endTime: _parseTime(json['endTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': _dateOnly(date),
      'startTime': _timeOfDayToString(startTime),
      'endTime': _timeOfDayToString(endTime),
    };
  }

  ScheduleModel copyWith({
    int? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _timeOfDayToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
