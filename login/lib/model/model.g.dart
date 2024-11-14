// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CommunityAdapter extends TypeAdapter<Community> {
  @override
  final int typeId = 0;

  @override
  Community read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Community(
      id: fields[0] as int,
      name: fields[1] as String,
      lname: fields[2] as String,
      ci: fields[3] as String,
      phone: fields[4] as String,
      email: fields[5] as String,
      address: fields[6] as String,
      birthdate: fields[7] as String,
      age: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Community obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lname)
      ..writeByte(3)
      ..write(obj.ci)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.birthdate)
      ..writeByte(8)
      ..write(obj.age);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommunityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineAdapter extends TypeAdapter<Offline> {
  @override
  final int typeId = 1;

  @override
  Offline read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offline(
      id: fields[0] as int,
      action: fields[1] as String,
      status: fields[3] as String,
      data: fields[2] as String,
      create_at: fields[4] as String,
      update_at: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Offline obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.create_at)
      ..writeByte(5)
      ..write(obj.update_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflinesAdapter extends TypeAdapter<Offlines> {
  @override
  final int typeId = 2;

  @override
  Offlines read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offlines(
      id: fields[0] as int,
      action: fields[1] as String,
      status: fields[3] as String,
      data: fields[2] as String,
      create_at: fields[4] as String,
      update_at: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Offlines obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.create_at)
      ..writeByte(5)
      ..write(obj.update_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflinesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CreatesheetAdapter extends TypeAdapter<Createsheet> {
  @override
  final int typeId = 3;

  @override
  Createsheet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Createsheet(
      id: fields[0] as int,
      cedula: fields[1] as String,
      email: fields[2] as String,
      description: fields[3] as String,
      rol: fields[4] as String,
      name_sheet: fields[5] as String,
      id_sheet: fields[6] as String,
      export_pdf: fields[7] as String,
      export_excel: fields[8] as String,
      export_db: fields[9] as String,
      create_at: fields[10] as String,
      update_at: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Createsheet obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cedula)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.rol)
      ..writeByte(5)
      ..write(obj.name_sheet)
      ..writeByte(6)
      ..write(obj.id_sheet)
      ..writeByte(7)
      ..write(obj.export_pdf)
      ..writeByte(8)
      ..write(obj.export_excel)
      ..writeByte(9)
      ..write(obj.export_db)
      ..writeByte(10)
      ..write(obj.create_at)
      ..writeByte(11)
      ..write(obj.update_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatesheetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
