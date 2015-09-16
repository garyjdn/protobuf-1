// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of protobuf;

/**
 * Per-message type setup.
 */
class BuilderInfo {
  final String messageName;
  final Map<int, FieldInfo> fieldInfo = new Map<int, FieldInfo>();
  final Map<String, FieldInfo> byTagAsString = <String, FieldInfo>{};
  final Map<String, FieldInfo> byName = <String, FieldInfo>{};
  bool hasExtensions = false;
  bool hasRequiredFields = true;

  BuilderInfo(this.messageName);

  void add(int tagNumber, String name, int fieldType,
           dynamic defaultOrMaker,
           CreateBuilderFunc subBuilder,
           ValueOfFunc valueOf) {
    addField(new FieldInfo(
      name, tagNumber, fieldType, defaultOrMaker, subBuilder, valueOf));
  }

  void addRepeated(int tagNumber, String name, int fieldType,
                   CheckFunc check,
                   CreateBuilderFunc subBuilder,
                   ValueOfFunc valueOf) {
    addField(new FieldInfo.repeated(
        name, tagNumber, fieldType, check, subBuilder, valueOf));
  }

  void addField(FieldInfo fi) {
    fieldInfo[fi.tagNumber] = fi;
    byTagAsString["${fi.tagNumber}"] = fi;
    byName[fi.name] = fi;
  }

  void a(int tagNumber, String name, int fieldType,
         [dynamic defaultOrMaker,
          CreateBuilderFunc subBuilder,
          ValueOfFunc valueOf]) {
    add(tagNumber, name, fieldType,
        defaultOrMaker, subBuilder, valueOf);
  }

  // Enum.
  void e(int tagNumber, String name, int fieldType,
         dynamic defaultOrMaker, ValueOfFunc valueOf) {
    add(tagNumber, name, fieldType,
        defaultOrMaker, null, valueOf);
  }

  // Repeated message.
  // TODO(skybrian): migrate to pp() and remove.
  void m(int tagNumber, String name,
         CreateBuilderFunc subBuilder, MakeDefaultFunc makeDefault) {
    add(tagNumber, name, PbFieldType._REPEATED_MESSAGE,
        makeDefault, subBuilder, null);
  }

  // Repeated, not a message, group, or enum.
  void p(int tagNumber, String name, int fieldType) {
    assert(!_isGroupOrMessage(fieldType) && !_isEnum(fieldType));
    addRepeated(tagNumber, name, fieldType,
        getCheckFunction(fieldType), null, null);
  }

  // Repeated message, group, or enum.
  void pp(int tagNumber, String name, int fieldType, CheckFunc check,
         [CreateBuilderFunc subBuilder, ValueOfFunc valueOf]) {
    assert(_isGroupOrMessage(fieldType) || _isEnum(fieldType));
    addRepeated(tagNumber, name, fieldType, check, subBuilder, valueOf);
  }

  bool containsTagNumber(int tagNumber) => fieldInfo.containsKey(tagNumber);

  defaultValue(int tagNumber) {
    MakeDefaultFunc func = makeDefault(tagNumber);
    return func == null ? null : func();
  }

  // Returns the field name for a given tag number, for debugging purposes.
  String fieldName(int tagNumber) {
    FieldInfo i = fieldInfo[tagNumber];
    return i != null ? i.name : null;
  }

  int fieldType(int tagNumber) {
    FieldInfo i = fieldInfo[tagNumber];
    return i != null ? i.type : null;
  }

  MakeDefaultFunc makeDefault(int tagNumber) {
    FieldInfo i = fieldInfo[tagNumber];
    return i != null ? i.makeDefault : null;
  }

  CreateBuilderFunc subBuilder(int tagNumber) {
    FieldInfo i = fieldInfo[tagNumber];
    return i != null ? i.subBuilder : null;
  }

  int tagNumber(String fieldName) {
    FieldInfo i = byName[fieldName];
    return i != null ? i.tagNumber : null;
  }

  ValueOfFunc valueOfFunc(int tagNumber) {
    FieldInfo i = fieldInfo[tagNumber];
    return i != null ? i.valueOf : null;
  }
}
