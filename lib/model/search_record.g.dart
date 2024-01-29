// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchRecordCollection on Isar {
  IsarCollection<SearchRecord> get searchRecords => this.collection();
}

const SearchRecordSchema = CollectionSchema(
  name: r'SearchRecord',
  id: 5686413277232449711,
  properties: {
    r'heat': PropertySchema(
      id: 0,
      name: r'heat',
      type: IsarType.long,
    ),
    r'keyword': PropertySchema(
      id: 1,
      name: r'keyword',
      type: IsarType.string,
    )
  },
  estimateSize: _searchRecordEstimateSize,
  serialize: _searchRecordSerialize,
  deserialize: _searchRecordDeserialize,
  deserializeProp: _searchRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'keyword': IndexSchema(
      id: 5840366397742622134,
      name: r'keyword',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'keyword',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _searchRecordGetId,
  getLinks: _searchRecordGetLinks,
  attach: _searchRecordAttach,
  version: '3.1.0+1',
);

int _searchRecordEstimateSize(
  SearchRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.keyword.length * 3;
  return bytesCount;
}

void _searchRecordSerialize(
  SearchRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.heat);
  writer.writeString(offsets[1], object.keyword);
}

SearchRecord _searchRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchRecord();
  object.heat = reader.readLong(offsets[0]);
  object.id = id;
  object.keyword = reader.readString(offsets[1]);
  return object;
}

P _searchRecordDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchRecordGetId(SearchRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _searchRecordGetLinks(SearchRecord object) {
  return [];
}

void _searchRecordAttach(
    IsarCollection<dynamic> col, Id id, SearchRecord object) {
  object.id = id;
}

extension SearchRecordQueryWhereSort
    on QueryBuilder<SearchRecord, SearchRecord, QWhere> {
  QueryBuilder<SearchRecord, SearchRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SearchRecordQueryWhere
    on QueryBuilder<SearchRecord, SearchRecord, QWhereClause> {
  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> keywordEqualTo(
      String keyword) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'keyword',
        value: [keyword],
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterWhereClause> keywordNotEqualTo(
      String keyword) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyword',
              lower: [],
              upper: [keyword],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyword',
              lower: [keyword],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyword',
              lower: [keyword],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'keyword',
              lower: [],
              upper: [keyword],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SearchRecordQueryFilter
    on QueryBuilder<SearchRecord, SearchRecord, QFilterCondition> {
  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> heatEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heat',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      heatGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heat',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> heatLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heat',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> heatBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyword',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyword',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyword',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyword',
        value: '',
      ));
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterFilterCondition>
      keywordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyword',
        value: '',
      ));
    });
  }
}

extension SearchRecordQueryObject
    on QueryBuilder<SearchRecord, SearchRecord, QFilterCondition> {}

extension SearchRecordQueryLinks
    on QueryBuilder<SearchRecord, SearchRecord, QFilterCondition> {}

extension SearchRecordQuerySortBy
    on QueryBuilder<SearchRecord, SearchRecord, QSortBy> {
  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> sortByHeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heat', Sort.asc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> sortByHeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heat', Sort.desc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> sortByKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.asc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> sortByKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.desc);
    });
  }
}

extension SearchRecordQuerySortThenBy
    on QueryBuilder<SearchRecord, SearchRecord, QSortThenBy> {
  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenByHeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heat', Sort.asc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenByHeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heat', Sort.desc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenByKeyword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.asc);
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QAfterSortBy> thenByKeywordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'keyword', Sort.desc);
    });
  }
}

extension SearchRecordQueryWhereDistinct
    on QueryBuilder<SearchRecord, SearchRecord, QDistinct> {
  QueryBuilder<SearchRecord, SearchRecord, QDistinct> distinctByHeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heat');
    });
  }

  QueryBuilder<SearchRecord, SearchRecord, QDistinct> distinctByKeyword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keyword', caseSensitive: caseSensitive);
    });
  }
}

extension SearchRecordQueryProperty
    on QueryBuilder<SearchRecord, SearchRecord, QQueryProperty> {
  QueryBuilder<SearchRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchRecord, int, QQueryOperations> heatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heat');
    });
  }

  QueryBuilder<SearchRecord, String, QQueryOperations> keywordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keyword');
    });
  }
}