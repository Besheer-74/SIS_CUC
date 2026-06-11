class AdmissionLookupOption {
  const AdmissionLookupOption({
    required this.id,
    required this.name,
    this.raw = const {},
  });

  final int id;
  final String name;
  final Map<String, dynamic> raw;

  factory AdmissionLookupOption.fromJson(Map<String, dynamic> json) {
    final label = json['name'] ?? json['title'] ?? json['label'] ?? '';

    return AdmissionLookupOption(
      id: _parseInt(json['id']),
      name: label.toString(),
      raw: json,
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
