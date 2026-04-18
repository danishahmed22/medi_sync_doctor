import 'package:equatable/equatable.dart';

class VendorEntity extends Equatable {
  const VendorEntity({
    required this.vendorId,
    required this.name,
    required this.phone,
    required this.clinicId,
  });

  final String vendorId;
  final String name;
  final String phone;
  final String clinicId;

  @override
  List<Object?> get props => [vendorId, name, phone, clinicId];
}
