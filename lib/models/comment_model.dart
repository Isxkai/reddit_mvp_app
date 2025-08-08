
class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String username;
  final String profilepic;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.username,
    required this.profilepic,
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? username,
    String? profilepic,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilepic: profilepic ?? this.profilepic,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'id': id});
    result.addAll({'text': text});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    result.addAll({'postId': postId});
    result.addAll({'username': username});
    result.addAll({'profilepic': profilepic});
  
    return result;
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      profilepic: map['profilepic'] ?? '',
    );
  }

  

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilepic: $profilepic)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Comment &&
      other.id == id &&
      other.text == text &&
      other.createdAt == createdAt &&
      other.postId == postId &&
      other.username == username &&
      other.profilepic == profilepic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      postId.hashCode ^
      username.hashCode ^
      profilepic.hashCode;
  }
}
