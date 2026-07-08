import 'package:json_annotation/json_annotation.dart';

part 'integrazione_dto.g.dart';

/// The backend returns ids as either strings or ints; normalize to string.
String _idFromJson(Object? value) => value?.toString() ?? '';
String? _nullableIdFromJson(Object? value) => value?.toString();

/// DTO for a `kit_products` row: one phase of the user's kit and the
/// supplements bundled in it (via the `products_with_duration` junction).
@JsonSerializable()
class KitProductDto {
  const KitProductDto({
    required this.id,
    this.sort,
    this.onlyForGender,
    this.phase,
    this.productsWithDuration = const [],
  });

  factory KitProductDto.fromJson(Map<String, dynamic> json) =>
      _$KitProductDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  final int? sort;

  @JsonKey(name: 'only_for_gender')
  final String? onlyForGender;

  final PhaseDto? phase;

  @JsonKey(name: 'products_with_duration')
  final List<ProductDurationJunctionDto> productsWithDuration;

  Map<String, dynamic> toJson() => _$KitProductDtoToJson(this);
}

/// DTO for `product_phases`.
@JsonSerializable()
class PhaseDto {
  const PhaseDto({required this.id, this.sort, this.translations = const []});

  factory PhaseDto.fromJson(Map<String, dynamic> json) =>
      _$PhaseDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  /// `product_phases.sort` is the authoritative order; it may be null on some
  /// rows, so callers should fall back gracefully.
  final int? sort;

  final List<PhaseTranslationDto> translations;

  Map<String, dynamic> toJson() => _$PhaseDtoToJson(this);
}

@JsonSerializable()
class PhaseTranslationDto {
  const PhaseTranslationDto({this.languagesCode, this.title});

  factory PhaseTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$PhaseTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;
  final String? title;

  Map<String, dynamic> toJson() => _$PhaseTranslationDtoToJson(this);
}

@JsonSerializable()
class LanguageCodeDto {
  const LanguageCodeDto({this.code});

  factory LanguageCodeDto.fromJson(Map<String, dynamic> json) =>
      _$LanguageCodeDtoFromJson(json);

  final String? code;

  Map<String, dynamic> toJson() => _$LanguageCodeDtoToJson(this);
}

/// Wrapper of the `products_with_duration` M2M junction row; the actual
/// product+duration lives under `kit_products_duration_id`.
@JsonSerializable()
class ProductDurationJunctionDto {
  const ProductDurationJunctionDto({this.durationEntry});

  factory ProductDurationJunctionDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDurationJunctionDtoFromJson(json);

  @JsonKey(name: 'kit_products_duration_id')
  final ProductDurationDto? durationEntry;

  Map<String, dynamic> toJson() => _$ProductDurationJunctionDtoToJson(this);
}

/// DTO for `kit_products_duration`: a product with its planned duration/quantity.
@JsonSerializable()
class ProductDurationDto {
  const ProductDurationDto({
    required this.id,
    this.duration,
    this.quantity,
    this.product,
  });

  factory ProductDurationDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDurationDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  /// Planned intake duration, in days.
  final int? duration;
  final int? quantity;
  final ProductDto? product;

  Map<String, dynamic> toJson() => _$ProductDurationDtoToJson(this);
}

/// DTO for `products` (subset used by integrazione).
@JsonSerializable()
class ProductDto {
  const ProductDto({
    required this.id,
    this.title,
    this.useForBarcodeCheck = false,
    this.asset,
    this.translations = const [],
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String? title;

  @JsonKey(name: 'use_for_barcode_check')
  final bool useForBarcodeCheck;

  final ProductAssetDto? asset;
  final List<ProductTranslationDto> translations;

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);
}

/// DTO for `products_translations` (usage instructions, dosage, warnings).
@JsonSerializable()
class ProductTranslationDto {
  const ProductTranslationDto({
    this.languagesCode,
    this.instructions,
    this.timing,
    this.description,
    this.avvertenze,
  });

  factory ProductTranslationDto.fromJson(Map<String, dynamic> json) =>
      _$ProductTranslationDtoFromJson(json);

  @JsonKey(name: 'languages_code')
  final LanguageCodeDto? languagesCode;
  final String? instructions;
  final String? timing;
  final String? description;
  final String? avvertenze;

  Map<String, dynamic> toJson() => _$ProductTranslationDtoToJson(this);
}

/// DTO for a `user_integratori` row (intake tracking).
@JsonSerializable()
class UserIntegratoreDto {
  const UserIntegratoreDto({
    required this.id,
    this.product,
    this.tookDates = const [],
    this.startedOn,
    this.endedOn,
    this.expectedToEndOn,
    this.delayDays,
  });

  factory UserIntegratoreDto.fromJson(Map<String, dynamic> json) =>
      _$UserIntegratoreDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  final ProductRefDto? product;

  @JsonKey(name: 'took_dates', fromJson: _tookDatesFromJson)
  final List<DateTime> tookDates;

  @JsonKey(name: 'started_on')
  final DateTime? startedOn;
  @JsonKey(name: 'ended_on')
  final DateTime? endedOn;
  @JsonKey(name: 'expected_to_end_on')
  final DateTime? expectedToEndOn;
  @JsonKey(name: 'delay_days')
  final String? delayDays;

  Map<String, dynamic> toJson() => _$UserIntegratoreDtoToJson(this);
}

/// Minimal product reference (id) used to correlate tracking to a product.
@JsonSerializable()
class ProductRefDto {
  const ProductRefDto({required this.id});

  factory ProductRefDto.fromJson(Map<String, dynamic> json) =>
      _$ProductRefDtoFromJson(json);

  @JsonKey(fromJson: _idFromJson)
  final String id;

  Map<String, dynamic> toJson() => _$ProductRefDtoToJson(this);
}

/// `took_dates` is a JSON array of ISO date strings; tolerate nulls/garbage.
List<DateTime> _tookDatesFromJson(Object? value) {
  if (value is! List) return const [];
  final dates = <DateTime>[];
  for (final item in value) {
    final parsed = DateTime.tryParse(item.toString());
    if (parsed != null) dates.add(parsed);
  }
  return dates;
}

@JsonSerializable()
class ProductAssetDto {
  const ProductAssetDto({this.id});

  factory ProductAssetDto.fromJson(Map<String, dynamic> json) =>
      _$ProductAssetDtoFromJson(json);

  @JsonKey(fromJson: _nullableIdFromJson)
  final String? id;

  Map<String, dynamic> toJson() => _$ProductAssetDtoToJson(this);
}
