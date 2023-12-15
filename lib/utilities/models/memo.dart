class Memo {
  final String id;
  final String content;
  final List<dynamic> images;

  Memo({
    required this.id,
    required this.content,
    required this.images
  });

  factory Memo.fromJson(Map<String, dynamic> data) {
    return Memo(
      id: data["id"],
      content: data["content"],
      images: data["images"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "content": content,
      "images": images
    };
  }
}