class ScanModel {
  final String result;
  final DateTime createdAt;

  ScanModel({required this.result, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'result': result,
    'createdAt': createdAt,
  };
}
