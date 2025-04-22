class KadarairModel {
  int? id_kadar_air;
  int? id_user;
  int? kadar_air;
  bool? status_kadar_air;

  KadarairModel({
    this.id_kadar_air,
    this.id_user,
    this.kadar_air,
    this.status_kadar_air,
  });
  factory KadarairModel.fromJson(Map<String, dynamic> json) {
    return KadarairModel(
      id_kadar_air: json['id_kadar_air'] as int?,
      id_user: json['id_user'] as int?,
      kadar_air: json['kadar_air'] as int?,
      status_kadar_air: json['status_kadar_air'] as bool?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_kadar_air': id_kadar_air,
      'id_user': id_user,
      'kadar_air': kadar_air,
      'status_kadar_air': status_kadar_air,
    };
  }
}
