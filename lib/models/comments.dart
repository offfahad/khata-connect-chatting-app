class CommentFirebase {
  CommentFirebase({
    required this.commentText,
    required this.read,
    required this.timestamp,
    required this.fromId,
    required this.toId,
  });

  late final String commentText; // Content of the comment
  late final String timestamp; // Timestamp of the comment
  late final String read;
  late final String fromId; // ID of the user who sent comment
  late final String toId; // ID of the user who received comment

  CommentFirebase.fromJson(Map<String, dynamic> json) {
    commentText = json['commentText'].toString();
    timestamp = json['timestamp'].toString();
    read = json['read'].toString();
    fromId = json['fromId'].toString();
    toId = json['toId'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['commentText'] = commentText;
    data['timestamp'] = timestamp;
    data['read'] = read;
    data['fromId'] = fromId;
    data['toId'] = toId;
    return data;
  }
}
