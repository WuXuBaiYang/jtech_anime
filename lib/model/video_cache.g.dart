// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVideoCacheCollection on Isar {
  IsarCollection<VideoCache> get videoCaches => this.collection();
}

const VideoCacheSchema = CollectionSchema(
  name: r'VideoCache',
  id: -348583634610943629,
  properties: {
    r'cacheTime': PropertySchema(
      id: 0,
      name: r'cacheTime',
      type: IsarType.long,
    ),
    r'playUrl': PropertySchema(
      id: 1,
      name: r'playUrl',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 2,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _videoCacheEstimateSize,
  serialize: _videoCacheSerialize,
  deserialize: _videoCacheDeserialize,
  deserializeProp: _videoCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'url': IndexSchema(
      id: -5756857009679432345,
      name: r'url',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _videoCacheGetId,
  getLinks: _videoCacheGetLinks,
  attach: _videoCacheAttach,
  version: '3.1.0+1',
);

int _videoCacheEstimateSize(
  VideoCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.playUrl.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _videoCacheSerialize(
  VideoCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cacheTime);
  writer.writeString(offsets[1], object.playUrl);
  writer.writeString(offsets[2], object.url);
}

VideoCache _videoCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VideoCache();
  object.cacheTime = reader.readLong(offsets[0]);
  object.id = id;
  object.playUrl = reader.readString(offsets[1]);
  object.url = reader.readString(offsets[2]);
  return object;
}

P _videoCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _videoCacheGetId(VideoCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _videoCacheGetLinks(VideoCache object) {
  return [];
}

void _videoCacheAttach(IsarCollection<dynamic> col, Id id, VideoCache object) {
  object.id = id;
}

extension VideoCacheByIndex on IsarCollection<VideoCache> {
  Future<VideoCache?> getByUrl(String url) {
    return getByIndex(r'url', [url]);
  }

  VideoCache? getByUrlSync(String url) {
    return getByIndexSync(r'url', [url]);
  }

  Future<bool> deleteByUrl(String url) {
    return deleteByIndex(r'url', [url]);
  }

  bool deleteByUrlSync(String url) {
    return deleteByIndexSync(r'url', [url]);
  }

  Future<List<VideoCache?>> getAllByUrl(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return getAllByIndex(r'url', values);
  }

  List<VideoCache?> getAllByUrlSync(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'url', values);
  }

  Future<int> deleteAllByUrl(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'url', values);
  }

  int deleteAllByUrlSync(List<String> urlValues) {
    final values = urlValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'url', values);
  }

  Future<Id> putByUrl(VideoCache object) {
    return putByIndex(r'url', object);
  }

  Id putByUrlSync(VideoCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'url', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUrl(List<VideoCache> objects) {
    return putAllByIndex(r'url', objects);
  }

  List<Id> putAllByUrlSync(List<VideoCache> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'url', objects, saveLinks: saveLinks);
  }
}

extension VideoCacheQueryWhereSort
    on QueryBuilder<VideoCache, VideoCache, QWhere> {
  QueryBuilder<VideoCache, VideoCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VideoCacheQueryWhere
    on QueryBuilder<VideoCache, VideoCache, QWhereClause> {
  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> idBetween(
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

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> urlEqualTo(
      String url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'url',
        value: [url],
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterWhereClause> urlNotEqualTo(
      String url) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [url],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'url',
              lower: [],
              upper: [url],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VideoCacheQueryFilter
    on QueryBuilder<VideoCache, VideoCache, QFilterCondition> {
  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> cacheTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition>
      cacheTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> cacheTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> cacheTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition>
      playUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> playUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition>
      playUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension VideoCacheQueryObject
    on QueryBuilder<VideoCache, VideoCache, QFilterCondition> {}

extension VideoCacheQueryLinks
    on QueryBuilder<VideoCache, VideoCache, QFilterCondition> {}

extension VideoCacheQuerySortBy
    on QueryBuilder<VideoCache, VideoCache, QSortBy> {
  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByCacheTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheTime', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByCacheTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheTime', Sort.desc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByPlayUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playUrl', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByPlayUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playUrl', Sort.desc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension VideoCacheQuerySortThenBy
    on QueryBuilder<VideoCache, VideoCache, QSortThenBy> {
  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByCacheTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheTime', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByCacheTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheTime', Sort.desc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByPlayUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playUrl', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByPlayUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playUrl', Sort.desc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }
}

extension VideoCacheQueryWhereDistinct
    on QueryBuilder<VideoCache, VideoCache, QDistinct> {
  QueryBuilder<VideoCache, VideoCache, QDistinct> distinctByCacheTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheTime');
    });
  }

  QueryBuilder<VideoCache, VideoCache, QDistinct> distinctByPlayUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VideoCache, VideoCache, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }
}

extension VideoCacheQueryProperty
    on QueryBuilder<VideoCache, VideoCache, QQueryProperty> {
  QueryBuilder<VideoCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VideoCache, int, QQueryOperations> cacheTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheTime');
    });
  }

  QueryBuilder<VideoCache, String, QQueryOperations> playUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playUrl');
    });
  }

  QueryBuilder<VideoCache, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }
}