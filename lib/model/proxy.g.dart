// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProxyRecordCollection on Isar {
  IsarCollection<ProxyRecord> get proxyRecords => this.collection();
}

const ProxyRecordSchema = CollectionSchema(
  name: r'ProxyRecord',
  id: -8008069183298975429,
  properties: {
    r'host': PropertySchema(
      id: 0,
      name: r'host',
      type: IsarType.string,
    ),
    r'port': PropertySchema(
      id: 1,
      name: r'port',
      type: IsarType.long,
    ),
    r'proxy': PropertySchema(
      id: 2,
      name: r'proxy',
      type: IsarType.string,
    )
  },
  estimateSize: _proxyRecordEstimateSize,
  serialize: _proxyRecordSerialize,
  deserialize: _proxyRecordDeserialize,
  deserializeProp: _proxyRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'proxy': IndexSchema(
      id: -3758635435220135751,
      name: r'proxy',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'proxy',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _proxyRecordGetId,
  getLinks: _proxyRecordGetLinks,
  attach: _proxyRecordAttach,
  version: '3.1.0+1',
);

int _proxyRecordEstimateSize(
  ProxyRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.host.length * 3;
  bytesCount += 3 + object.proxy.length * 3;
  return bytesCount;
}

void _proxyRecordSerialize(
  ProxyRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.host);
  writer.writeLong(offsets[1], object.port);
  writer.writeString(offsets[2], object.proxy);
}

ProxyRecord _proxyRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProxyRecord();
  object.host = reader.readString(offsets[0]);
  object.id = id;
  object.port = reader.readLong(offsets[1]);
  object.proxy = reader.readString(offsets[2]);
  return object;
}

P _proxyRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _proxyRecordGetId(ProxyRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _proxyRecordGetLinks(ProxyRecord object) {
  return [];
}

void _proxyRecordAttach(
    IsarCollection<dynamic> col, Id id, ProxyRecord object) {
  object.id = id;
}

extension ProxyRecordByIndex on IsarCollection<ProxyRecord> {
  Future<ProxyRecord?> getByProxy(String proxy) {
    return getByIndex(r'proxy', [proxy]);
  }

  ProxyRecord? getByProxySync(String proxy) {
    return getByIndexSync(r'proxy', [proxy]);
  }

  Future<bool> deleteByProxy(String proxy) {
    return deleteByIndex(r'proxy', [proxy]);
  }

  bool deleteByProxySync(String proxy) {
    return deleteByIndexSync(r'proxy', [proxy]);
  }

  Future<List<ProxyRecord?>> getAllByProxy(List<String> proxyValues) {
    final values = proxyValues.map((e) => [e]).toList();
    return getAllByIndex(r'proxy', values);
  }

  List<ProxyRecord?> getAllByProxySync(List<String> proxyValues) {
    final values = proxyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'proxy', values);
  }

  Future<int> deleteAllByProxy(List<String> proxyValues) {
    final values = proxyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'proxy', values);
  }

  int deleteAllByProxySync(List<String> proxyValues) {
    final values = proxyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'proxy', values);
  }

  Future<Id> putByProxy(ProxyRecord object) {
    return putByIndex(r'proxy', object);
  }

  Id putByProxySync(ProxyRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'proxy', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProxy(List<ProxyRecord> objects) {
    return putAllByIndex(r'proxy', objects);
  }

  List<Id> putAllByProxySync(List<ProxyRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'proxy', objects, saveLinks: saveLinks);
  }
}

extension ProxyRecordQueryWhereSort
    on QueryBuilder<ProxyRecord, ProxyRecord, QWhere> {
  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProxyRecordQueryWhere
    on QueryBuilder<ProxyRecord, ProxyRecord, QWhereClause> {
  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> proxyEqualTo(
      String proxy) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'proxy',
        value: [proxy],
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterWhereClause> proxyNotEqualTo(
      String proxy) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'proxy',
              lower: [],
              upper: [proxy],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'proxy',
              lower: [proxy],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'proxy',
              lower: [proxy],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'proxy',
              lower: [],
              upper: [proxy],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProxyRecordQueryFilter
    on QueryBuilder<ProxyRecord, ProxyRecord, QFilterCondition> {
  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'host',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'host',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> hostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition>
      hostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> portEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> portGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> portLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'port',
        value: value,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> portBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'port',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition>
      proxyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proxy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proxy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proxy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition> proxyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proxy',
        value: '',
      ));
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterFilterCondition>
      proxyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proxy',
        value: '',
      ));
    });
  }
}

extension ProxyRecordQueryObject
    on QueryBuilder<ProxyRecord, ProxyRecord, QFilterCondition> {}

extension ProxyRecordQueryLinks
    on QueryBuilder<ProxyRecord, ProxyRecord, QFilterCondition> {}

extension ProxyRecordQuerySortBy
    on QueryBuilder<ProxyRecord, ProxyRecord, QSortBy> {
  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proxy', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> sortByProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proxy', Sort.desc);
    });
  }
}

extension ProxyRecordQuerySortThenBy
    on QueryBuilder<ProxyRecord, ProxyRecord, QSortThenBy> {
  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByPortDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'port', Sort.desc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByProxy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proxy', Sort.asc);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QAfterSortBy> thenByProxyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proxy', Sort.desc);
    });
  }
}

extension ProxyRecordQueryWhereDistinct
    on QueryBuilder<ProxyRecord, ProxyRecord, QDistinct> {
  QueryBuilder<ProxyRecord, ProxyRecord, QDistinct> distinctByHost(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'host', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QDistinct> distinctByPort() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'port');
    });
  }

  QueryBuilder<ProxyRecord, ProxyRecord, QDistinct> distinctByProxy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proxy', caseSensitive: caseSensitive);
    });
  }
}

extension ProxyRecordQueryProperty
    on QueryBuilder<ProxyRecord, ProxyRecord, QQueryProperty> {
  QueryBuilder<ProxyRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProxyRecord, String, QQueryOperations> hostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'host');
    });
  }

  QueryBuilder<ProxyRecord, int, QQueryOperations> portProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'port');
    });
  }

  QueryBuilder<ProxyRecord, String, QQueryOperations> proxyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proxy');
    });
  }
}
