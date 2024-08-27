class TransactionFirebase {
  TransactionFirebase({
    required this.id,
    required this.toId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.fromId,
    required this.updateBy,
    required this.updateTimestamp,
    required this.backupAmount,
  });

  late final String id;
  late final String toId;
  late final String type;
  late final double amount;
  late final String description;
  late final String status;
  late final String timestamp;
  late final String fromId;
  late final String updateBy;
  late final String updateTimestamp;
  late final double backupAmount;

  // Constructor to create an instance from JSON
  TransactionFirebase.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    toId = json['toId'].toString();
    type = json['type'].toString();
    amount = double.parse(json['amount'].toString());
    description = json['description'].toString();
    status = json['status'].toString();
    timestamp = json['timestamp'].toString();
    fromId = json['fromId'].toString();
    updateBy = json['updateBy']?.toString() ?? 'Unknown'; // Handle null
    updateTimestamp = json['updateTimestamp']?.toString() ?? ''; // Handle null
    backupAmount = double.parse(json['backupAmount'].toString());
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['toId'] = toId;
    data['type'] = type;
    data['amount'] = amount;
    data['description'] = description;
    data['status'] = status;
    data['timestamp'] = timestamp;
    data['fromId'] = fromId;
    data['updateBy'] = updateBy;
    data['updateTimestamp'] = updateTimestamp;
    data['backupAmount'] = backupAmount;
    return data;
  }
}
