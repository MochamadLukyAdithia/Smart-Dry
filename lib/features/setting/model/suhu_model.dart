class SuhuModel {
  int? id_suhu;
  int? id_user;
  int? batasan_suhu;
  int? current_temperature;

  SuhuModel({
    this.id_suhu,
    this.id_user,
    this.batasan_suhu,
    this.current_temperature,
  });
  factory SuhuModel.fromJson(Map<String, dynamic> json) {
    return SuhuModel(
      id_suhu: json['id_suhu'] as int?,
      id_user: json['id_user'] as int?,
      batasan_suhu: json['batasan_suhu'] as int?,
      current_temperature: json['current_temperature'] as int?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_suhu': id_suhu,
      'id_user': id_user,
      'batasan_suhu': batasan_suhu,
      'current_temperature': current_temperature,
    };
  }
}
