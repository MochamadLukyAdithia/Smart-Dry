class PengeringanModel {
  final int? id_pengeringan;
  final int? id_suhu;
  final bool? status_hujan;
  final bool? status_pemanas;
  final bool? status_kipas;
  final String? mode;

  PengeringanModel({
    this.id_pengeringan,
    this.id_suhu,
    this.status_hujan,
    this.status_pemanas,
    this.status_kipas,
    this.mode,
  });

  // Factory constructor untuk membuat instance dari JSON
  factory PengeringanModel.fromJson(Map<String, dynamic> json) {
    return PengeringanModel(
      id_pengeringan: json['id_pengeringan'] as int?,
      id_suhu: json['id_suhu'] as int?,
      status_hujan: json['status_hujan'] as bool?,
      status_pemanas: json['status_pemanas'] as bool?,
      status_kipas: json['status_kipas'] as bool?,
      mode: json['mode'] as String?,
    );
  }

  // Method untuk convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_pengeringan': id_pengeringan,
      'id_suhu': id_suhu,
      'status_hujan': status_hujan,
      'status_pemanas': status_pemanas,
      'status_kipas': status_kipas,
      'mode': mode,
    };
  }

  // Method untuk membuat copy dengan perubahan
  PengeringanModel copyWith({
    int? id_pengeringan,
    int? id_suhu,
    bool? status_hujan,
    bool? status_pemanas,
    bool? status_kipas,
    String? mode,
  }) {
    return PengeringanModel(
      id_pengeringan: id_pengeringan ?? this.id_pengeringan,
      id_suhu: id_suhu ?? this.id_suhu,
      status_hujan: status_hujan ?? this.status_hujan,
      status_pemanas: status_pemanas ?? this.status_pemanas,
      status_kipas: status_kipas ?? this.status_kipas,
      mode: mode ?? this.mode,
    );
  }

  // Method untuk mendapatkan default/empty model
  factory PengeringanModel.empty() {
    return PengeringanModel(
      id_pengeringan: 1,
      id_suhu: 1,
      status_hujan: false,
      status_pemanas: false,
      status_kipas: false,
      mode: 'auto',
    );
  }

  // Method untuk check apakah sistem aktif
  bool get isSystemActive => (status_hujan ?? false) || (status_pemanas ?? false);

  // Method untuk check apakah dalam mode auto
  bool get isAutoMode => mode == 'auto';

  // Method untuk check apakah dalam mode manual
  bool get isManualMode => mode == 'manual';

  // Override toString untuk debugging
  @override
  String toString() {
    return 'PengeringanModel{id_pengeringan: $id_pengeringan, id_suhu: $id_suhu, status_hujan: $status_hujan, status_pemanas: $status_pemanas, status_kipas: $status_kipas, mode: $mode}';
  }

  // Override equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PengeringanModel &&
        other.id_pengeringan == id_pengeringan &&
        other.id_suhu == id_suhu &&
        other.status_hujan == status_hujan &&
        other.status_pemanas == status_pemanas &&
        other.status_kipas == status_kipas &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    return id_pengeringan.hashCode ^
        id_suhu.hashCode ^
        status_hujan.hashCode ^
        status_pemanas.hashCode ^
        status_kipas.hashCode ^
        mode.hashCode;
  }
}