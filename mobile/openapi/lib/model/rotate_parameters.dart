//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RotateParameters {
  /// Returns a new [RotateParameters] instance.
  RotateParameters({
    required this.angle,
  });

  /// Rotation angle in degrees
  RotateParametersAngleEnum angle;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RotateParameters &&
    other.angle == angle;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (angle.hashCode);

  @override
  String toString() => 'RotateParameters[angle=$angle]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'angle'] = this.angle;
    return json;
  }

  /// Returns a new [RotateParameters] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RotateParameters? fromJson(dynamic value) {
    upgradeDto(value, "RotateParameters");
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return RotateParameters(
        angle: RotateParametersAngleEnum.parse('${json[r'angle']}'),
      );
    }
    return null;
  }

  static List<RotateParameters> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RotateParameters>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RotateParameters.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RotateParameters> mapFromJson(dynamic json) {
    final map = <String, RotateParameters>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RotateParameters.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RotateParameters-objects as value to a dart map
  static Map<String, List<RotateParameters>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RotateParameters>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RotateParameters.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'angle',
  };
}

/// Rotation angle in degrees
class RotateParametersAngleEnum {
  /// Instantiate a new enum with the provided [value].
  const RotateParametersAngleEnum._(this.value);

  /// The underlying value of this enum member.
  final num value;

  @override
  String toString() => value.toString();

  num toJson() => value;

  static const n0 = RotateParametersAngleEnum._('0');
  static const n90 = RotateParametersAngleEnum._('90');
  static const n180 = RotateParametersAngleEnum._('180');
  static const n270 = RotateParametersAngleEnum._('270');

  /// List of all possible values in this [enum][RotateParametersAngleEnum].
  static const values = <RotateParametersAngleEnum>[
    n0,
    n90,
    n180,
    n270,
  ];

  static RotateParametersAngleEnum? fromJson(dynamic value) => RotateParametersAngleEnumTypeTransformer().decode(value);

  static List<RotateParametersAngleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RotateParametersAngleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RotateParametersAngleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RotateParametersAngleEnum] to num,
/// and [decode] dynamic data back to [RotateParametersAngleEnum].
class RotateParametersAngleEnumTypeTransformer {
  factory RotateParametersAngleEnumTypeTransformer() => _instance ??= const RotateParametersAngleEnumTypeTransformer._();

  const RotateParametersAngleEnumTypeTransformer._();

  num encode(RotateParametersAngleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RotateParametersAngleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RotateParametersAngleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case '0': return RotateParametersAngleEnum.n0;
        case '90': return RotateParametersAngleEnum.n90;
        case '180': return RotateParametersAngleEnum.n180;
        case '270': return RotateParametersAngleEnum.n270;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RotateParametersAngleEnumTypeTransformer] instance.
  static RotateParametersAngleEnumTypeTransformer? _instance;
}


