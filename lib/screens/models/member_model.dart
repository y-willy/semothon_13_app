class MemberModel {
  final int id;
  final String name;
  final String studentId;

  const MemberModel({
    required this.id,
    required this.name,
    required this.studentId,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
    };
  }

  MemberModel copyWith({
    int? id,
    String? name,
    String? studentId,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
    );
  }
}
