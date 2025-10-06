class Address {
  final int id;
  final int userId;
  final String alias;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? references;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.alias,
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.references,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      alias: json['alias'] ?? '',
      street: json['street'] ?? '',
      exteriorNumber: json['exteriorNumber'] ?? json['exterior_number'] ?? '',
      interiorNumber: json['interiorNumber'] ?? json['interior_number'],
      neighborhood: json['neighborhood'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? json['zip_code'] ?? '',
      references: json['references'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'alias': alias,
      'street': street,
      'exteriorNumber': exteriorNumber,
      'interiorNumber': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'alias': alias,
      'street': street,
      'exterior_number': exteriorNumber,
      'interior_number': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'alias': alias,
      'street': street,
      'exterior_number': exteriorNumber,
      'interior_number': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Dirección completa formateada
  String get fullAddress {
    final parts = [
      street,
      exteriorNumber,
      if (interiorNumber != null && interiorNumber!.isNotEmpty) 'Int. $interiorNumber',
      neighborhood,
      city,
      state,
      zipCode,
    ];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  /// Dirección corta (calle y número)
  String get shortAddress {
    return '$street $exteriorNumber';
  }

  /// Dirección para mostrar en listas
  String get displayAddress {
    return '$alias - $shortAddress';
  }

  /// Validar si la dirección está completa
  bool get isValid {
    return alias.isNotEmpty &&
        street.isNotEmpty &&
        exteriorNumber.isNotEmpty &&
        neighborhood.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zipCode.isNotEmpty &&
        latitude != 0.0 &&
        longitude != 0.0;
  }

  Address copyWith({
    int? id,
    int? userId,
    String? alias,
    String? street,
    String? exteriorNumber,
    String? interiorNumber,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? references,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alias: alias ?? this.alias,
      street: street ?? this.street,
      exteriorNumber: exteriorNumber ?? this.exteriorNumber,
      interiorNumber: interiorNumber ?? this.interiorNumber,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      references: references ?? this.references,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Address(id: $id, alias: $alias, fullAddress: $fullAddress)';
  }
}

/// Modelo para crear una nueva dirección
class CreateAddressRequest {
  final String alias;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? references;
  final double latitude;
  final double longitude;

  CreateAddressRequest({
    required this.alias,
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.references,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'street': street,
      'exterior_number': exteriorNumber,
      'interior_number': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Validar los datos de la dirección
  String? validate() {
    if (alias.isEmpty) return 'El alias es requerido';
    if (alias.length > 50) return 'El alias no puede tener más de 50 caracteres';
    if (street.isEmpty) return 'La calle es requerida';
    if (street.length > 255) return 'La calle no puede tener más de 255 caracteres';
    if (exteriorNumber.isEmpty) return 'El número exterior es requerido';
    if (exteriorNumber.length > 50) return 'El número exterior no puede tener más de 50 caracteres';
    if (neighborhood.isEmpty) return 'La colonia es requerida';
    if (neighborhood.length > 150) return 'La colonia no puede tener más de 150 caracteres';
    if (city.isEmpty) return 'La ciudad es requerida';
    if (city.length > 100) return 'La ciudad no puede tener más de 100 caracteres';
    if (state.isEmpty) return 'El estado es requerido';
    if (state.length > 100) return 'El estado no puede tener más de 100 caracteres';
    if (zipCode.isEmpty) return 'El código postal es requerido';
    if (!RegExp(r'^\d{5}$').hasMatch(zipCode)) return 'El código postal debe tener 5 dígitos';
    if (references != null && references!.length > 500) {
      return 'Las referencias no pueden tener más de 500 caracteres';
    }
    if (latitude < -90 || latitude > 90) return 'La latitud debe estar entre -90 y 90';
    if (longitude < -180 || longitude > 180) return 'La longitud debe estar entre -180 y 180';
    
    return null;
  }
}

/// Modelo para actualizar una dirección existente
class UpdateAddressRequest {
  final String alias;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? references;
  final double latitude;
  final double longitude;

  UpdateAddressRequest({
    required this.alias,
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.references,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'street': street,
      'exterior_number': exteriorNumber,
      'interior_number': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'references': references,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Validar los datos de la dirección
  String? validate() {
    if (alias.isEmpty) return 'El alias es requerido';
    if (alias.length > 50) return 'El alias no puede tener más de 50 caracteres';
    if (street.isEmpty) return 'La calle es requerida';
    if (street.length > 255) return 'La calle no puede tener más de 255 caracteres';
    if (exteriorNumber.isEmpty) return 'El número exterior es requerido';
    if (exteriorNumber.length > 50) return 'El número exterior no puede tener más de 50 caracteres';
    if (neighborhood.isEmpty) return 'La colonia es requerida';
    if (neighborhood.length > 150) return 'La colonia no puede tener más de 150 caracteres';
    if (city.isEmpty) return 'La ciudad es requerida';
    if (city.length > 100) return 'La ciudad no puede tener más de 100 caracteres';
    if (state.isEmpty) return 'El estado es requerido';
    if (state.length > 100) return 'El estado no puede tener más de 100 caracteres';
    if (zipCode.isEmpty) return 'El código postal es requerido';
    if (!RegExp(r'^\d{5}$').hasMatch(zipCode)) return 'El código postal debe tener 5 dígitos';
    if (references != null && references!.length > 500) {
      return 'Las referencias no pueden tener más de 500 caracteres';
    }
    if (latitude < -90 || latitude > 90) return 'La latitud debe estar entre -90 y 90';
    if (longitude < -180 || longitude > 180) return 'La longitud debe estar entre -180 y 180';
    
    return null;
  }
}
