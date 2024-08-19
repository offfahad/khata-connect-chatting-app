class TransactionFirebase {
  TransactionFirebase({
    required this.toId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.fromId,
    required this.updateBy,
    required this.updateTimestamp,
  });

  late final String toId;
  late final String type;
  late final double amount;
  late final String description;
  late final String status;
  late final String timestamp;
  late final String fromId;
  late final String updateBy;
  late final String updateTimestamp;

  TransactionFirebase.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    type = json['type'].toString();
    amount = double.parse(json['amount'].toString());
    description = json['description'].toString();
    status = json['status'].toString();
    timestamp = json['timestamp'].toString();
    fromId = json['fromId'].toString();
    updateBy = json['updateBy']?.toString() ?? 'Unknown'; // Handle null
    updateTimestamp = json['updateTimestamp']?.toString() ?? ''; // Handle null
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['type'] = type;
    data['amount'] = amount;
    data['description'] = description;
    data['status'] = status;
    data['timestamp'] = timestamp;
    data['fromId'] = fromId;
    data['updateBy'] = updateBy;
    data['updateTimestamp'] = updateTimestamp; // Correct field name
    return data;
  }
}
