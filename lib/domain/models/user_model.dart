class UserModel {
  final String id;
  final String email;
  final String name;
  final String nickname;
  final String? branch;
  final Map<String, dynamic> stats;
  final double percentile;
  final int rank;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.nickname = '',
    this.branch,
    this.stats = const {},
    this.percentile = 0.0,
    this.rank = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nickname': nickname,
      'branch': branch,
      'stats': stats,
      'percentile': percentile,
      'rank': rank,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'] ?? '',
      branch: map['branch'],
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      percentile: (map['percentile'] ?? 0.0).toDouble(),
      rank: (map['rank'] ?? 0).toInt(),
    );
  }
}
