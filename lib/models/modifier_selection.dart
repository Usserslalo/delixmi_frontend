class ModifierSelection {
  final int modifierGroupId;
  final int selectedOptionId;

  ModifierSelection({
    required this.modifierGroupId,
    required this.selectedOptionId,
  });

  /// Crear ModifierSelection desde JSON
  factory ModifierSelection.fromJson(Map<String, dynamic> json) {
    return ModifierSelection(
      modifierGroupId: json['modifierGroupId'],
      selectedOptionId: json['selectedOptionId'],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'modifierGroupId': modifierGroupId,
      'selectedOptionId': selectedOptionId,
    };
  }

  /// Convertir a `Map<String, int>` para el CartService
  Map<String, int> toMap() {
    return {
      'modifierGroupId': modifierGroupId,
      'selectedOptionId': selectedOptionId,
    };
  }

  /// Crear lista de ModifierSelection desde lista de `Map<String, int>`
  static List<ModifierSelection> fromMapList(List<Map<String, int>> mapList) {
    return mapList.map((map) => ModifierSelection(
      modifierGroupId: map['modifierGroupId']!,
      selectedOptionId: map['selectedOptionId']!,
    )).toList();
  }

  /// Convertir lista de ModifierSelection a lista de `Map<String, int>`
  static List<Map<String, int>> toMapList(List<ModifierSelection> selections) {
    return selections.map((selection) => selection.toMap()).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModifierSelection &&
        other.modifierGroupId == modifierGroupId &&
        other.selectedOptionId == selectedOptionId;
  }

  @override
  int get hashCode {
    return modifierGroupId.hashCode ^ selectedOptionId.hashCode;
  }

  @override
  String toString() {
    return 'ModifierSelection(groupId: $modifierGroupId, optionId: $selectedOptionId)';
  }
}
