class ReviewSelection {
  final int id;
  final String name;
  final int order;

  ReviewSelection({required this.order, required this.id, required this.name});

  ReviewSelection.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        order = json['order'];
}
