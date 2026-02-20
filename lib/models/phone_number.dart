class PhoneNumber {
  final String id;
  final String name;
  final String number;
  final bool isPrimary;

  PhoneNumber({
    required this.id,
    required this.name,
    required this.number,
    required this.isPrimary,
  });

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      isPrimary: json['isPrimary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'isPrimary': isPrimary,
    };
  }
}
