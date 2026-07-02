import 'package:equatable/equatable.dart';

/// A Kilocal Point pharmacy, read from the `pharmacies` GraphQL collection.
///
/// The selected pharmacy is sent verbatim as `pharmacy_data` in the survey
/// submit body for the `load_kilocal_points` step (see `wiki/survey.md`).
class Pharmacy extends Equatable {
  const Pharmacy({
    required this.id,
    this.title,
    this.address,
    this.city,
    this.province,
    this.zip,
    this.region,
    this.storeId,
  });

  final String id;
  final String? title;
  final String? address;
  final String? city;
  final String? province;
  final String? zip;
  final String? region;
  final String? storeId;

  /// The object shape backend expects for `pharmacy_data`.
  Map<String, dynamic> toSubmitJson() => {
    'id': int.tryParse(id) ?? id,
    if (title != null) 'title': title,
    if (address != null) 'address': address,
    if (city != null) 'city': city,
    if (province != null) 'province': province,
    if (zip != null) 'zip': zip,
    if (region != null) 'region': region,
    if (storeId != null) 'store_id': storeId,
  };

  @override
  List<Object?> get props => [id, title, address, city, province, zip];
}
