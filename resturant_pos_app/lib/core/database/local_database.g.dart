// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalRestaurantsTable extends LocalRestaurants
    with TableInfo<$LocalRestaurantsTable, LocalRestaurant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRestaurantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _currencySymbolMeta = const VerificationMeta(
    'currencySymbol',
  );
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
    'currency_symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('\$'),
  );
  static const VerificationMeta _taxPercentageMeta = const VerificationMeta(
    'taxPercentage',
  );
  @override
  late final GeneratedColumn<double> taxPercentage = GeneratedColumn<double>(
    'tax_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptHeaderMeta = const VerificationMeta(
    'receiptHeader',
  );
  @override
  late final GeneratedColumn<String> receiptHeader = GeneratedColumn<String>(
    'receipt_header',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptFooterMeta = const VerificationMeta(
    'receiptFooter',
  );
  @override
  late final GeneratedColumn<String> receiptFooter = GeneratedColumn<String>(
    'receipt_footer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kitchenBypassMeta = const VerificationMeta(
    'kitchenBypass',
  );
  @override
  late final GeneratedColumn<bool> kitchenBypass = GeneratedColumn<bool>(
    'kitchen_bypass',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kitchen_bypass" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paymentMethodsMeta = const VerificationMeta(
    'paymentMethods',
  );
  @override
  late final GeneratedColumn<String> paymentMethods = GeneratedColumn<String>(
    'payment_methods',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Cash,Card'),
  );
  static const VerificationMeta _planNameMeta = const VerificationMeta(
    'planName',
  );
  @override
  late final GeneratedColumn<String> planName = GeneratedColumn<String>(
    'plan_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasKitchenMeta = const VerificationMeta(
    'hasKitchen',
  );
  @override
  late final GeneratedColumn<bool> hasKitchen = GeneratedColumn<bool>(
    'has_kitchen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_kitchen" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hasStaffMeta = const VerificationMeta(
    'hasStaff',
  );
  @override
  late final GeneratedColumn<bool> hasStaff = GeneratedColumn<bool>(
    'has_staff',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_staff" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hasInventoryMeta = const VerificationMeta(
    'hasInventory',
  );
  @override
  late final GeneratedColumn<bool> hasInventory = GeneratedColumn<bool>(
    'has_inventory',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_inventory" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startingBillNumberMeta =
      const VerificationMeta('startingBillNumber');
  @override
  late final GeneratedColumn<int> startingBillNumber = GeneratedColumn<int>(
    'starting_bill_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    currency,
    currencySymbol,
    taxPercentage,
    logoUrl,
    receiptHeader,
    receiptFooter,
    kitchenBypass,
    paymentMethods,
    planName,
    hasKitchen,
    hasStaff,
    hasInventory,
    startingBillNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_restaurants';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRestaurant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
        _currencySymbolMeta,
        currencySymbol.isAcceptableOrUnknown(
          data['currency_symbol']!,
          _currencySymbolMeta,
        ),
      );
    }
    if (data.containsKey('tax_percentage')) {
      context.handle(
        _taxPercentageMeta,
        taxPercentage.isAcceptableOrUnknown(
          data['tax_percentage']!,
          _taxPercentageMeta,
        ),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('receipt_header')) {
      context.handle(
        _receiptHeaderMeta,
        receiptHeader.isAcceptableOrUnknown(
          data['receipt_header']!,
          _receiptHeaderMeta,
        ),
      );
    }
    if (data.containsKey('receipt_footer')) {
      context.handle(
        _receiptFooterMeta,
        receiptFooter.isAcceptableOrUnknown(
          data['receipt_footer']!,
          _receiptFooterMeta,
        ),
      );
    }
    if (data.containsKey('kitchen_bypass')) {
      context.handle(
        _kitchenBypassMeta,
        kitchenBypass.isAcceptableOrUnknown(
          data['kitchen_bypass']!,
          _kitchenBypassMeta,
        ),
      );
    }
    if (data.containsKey('payment_methods')) {
      context.handle(
        _paymentMethodsMeta,
        paymentMethods.isAcceptableOrUnknown(
          data['payment_methods']!,
          _paymentMethodsMeta,
        ),
      );
    }
    if (data.containsKey('plan_name')) {
      context.handle(
        _planNameMeta,
        planName.isAcceptableOrUnknown(data['plan_name']!, _planNameMeta),
      );
    }
    if (data.containsKey('has_kitchen')) {
      context.handle(
        _hasKitchenMeta,
        hasKitchen.isAcceptableOrUnknown(data['has_kitchen']!, _hasKitchenMeta),
      );
    }
    if (data.containsKey('has_staff')) {
      context.handle(
        _hasStaffMeta,
        hasStaff.isAcceptableOrUnknown(data['has_staff']!, _hasStaffMeta),
      );
    }
    if (data.containsKey('has_inventory')) {
      context.handle(
        _hasInventoryMeta,
        hasInventory.isAcceptableOrUnknown(
          data['has_inventory']!,
          _hasInventoryMeta,
        ),
      );
    }
    if (data.containsKey('starting_bill_number')) {
      context.handle(
        _startingBillNumberMeta,
        startingBillNumber.isAcceptableOrUnknown(
          data['starting_bill_number']!,
          _startingBillNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRestaurant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRestaurant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      currencySymbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_symbol'],
      )!,
      taxPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_percentage'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      receiptHeader: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_header'],
      ),
      receiptFooter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_footer'],
      ),
      kitchenBypass: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kitchen_bypass'],
      )!,
      paymentMethods: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_methods'],
      )!,
      planName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_name'],
      ),
      hasKitchen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_kitchen'],
      )!,
      hasStaff: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_staff'],
      )!,
      hasInventory: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_inventory'],
      )!,
      startingBillNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starting_bill_number'],
      )!,
    );
  }

  @override
  $LocalRestaurantsTable createAlias(String alias) {
    return $LocalRestaurantsTable(attachedDatabase, alias);
  }
}

class LocalRestaurant extends DataClass implements Insertable<LocalRestaurant> {
  final String id;
  final String name;
  final String currency;
  final String currencySymbol;
  final double taxPercentage;
  final String? logoUrl;
  final String? receiptHeader;
  final String? receiptFooter;
  final bool kitchenBypass;
  final String paymentMethods;
  final String? planName;
  final bool hasKitchen;
  final bool hasStaff;
  final bool hasInventory;
  final int startingBillNumber;
  const LocalRestaurant({
    required this.id,
    required this.name,
    required this.currency,
    required this.currencySymbol,
    required this.taxPercentage,
    this.logoUrl,
    this.receiptHeader,
    this.receiptFooter,
    required this.kitchenBypass,
    required this.paymentMethods,
    this.planName,
    required this.hasKitchen,
    required this.hasStaff,
    required this.hasInventory,
    required this.startingBillNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    map['currency_symbol'] = Variable<String>(currencySymbol);
    map['tax_percentage'] = Variable<double>(taxPercentage);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || receiptHeader != null) {
      map['receipt_header'] = Variable<String>(receiptHeader);
    }
    if (!nullToAbsent || receiptFooter != null) {
      map['receipt_footer'] = Variable<String>(receiptFooter);
    }
    map['kitchen_bypass'] = Variable<bool>(kitchenBypass);
    map['payment_methods'] = Variable<String>(paymentMethods);
    if (!nullToAbsent || planName != null) {
      map['plan_name'] = Variable<String>(planName);
    }
    map['has_kitchen'] = Variable<bool>(hasKitchen);
    map['has_staff'] = Variable<bool>(hasStaff);
    map['has_inventory'] = Variable<bool>(hasInventory);
    map['starting_bill_number'] = Variable<int>(startingBillNumber);
    return map;
  }

  LocalRestaurantsCompanion toCompanion(bool nullToAbsent) {
    return LocalRestaurantsCompanion(
      id: Value(id),
      name: Value(name),
      currency: Value(currency),
      currencySymbol: Value(currencySymbol),
      taxPercentage: Value(taxPercentage),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      receiptHeader: receiptHeader == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptHeader),
      receiptFooter: receiptFooter == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptFooter),
      kitchenBypass: Value(kitchenBypass),
      paymentMethods: Value(paymentMethods),
      planName: planName == null && nullToAbsent
          ? const Value.absent()
          : Value(planName),
      hasKitchen: Value(hasKitchen),
      hasStaff: Value(hasStaff),
      hasInventory: Value(hasInventory),
      startingBillNumber: Value(startingBillNumber),
    );
  }

  factory LocalRestaurant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRestaurant(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      taxPercentage: serializer.fromJson<double>(json['taxPercentage']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      receiptHeader: serializer.fromJson<String?>(json['receiptHeader']),
      receiptFooter: serializer.fromJson<String?>(json['receiptFooter']),
      kitchenBypass: serializer.fromJson<bool>(json['kitchenBypass']),
      paymentMethods: serializer.fromJson<String>(json['paymentMethods']),
      planName: serializer.fromJson<String?>(json['planName']),
      hasKitchen: serializer.fromJson<bool>(json['hasKitchen']),
      hasStaff: serializer.fromJson<bool>(json['hasStaff']),
      hasInventory: serializer.fromJson<bool>(json['hasInventory']),
      startingBillNumber: serializer.fromJson<int>(json['startingBillNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'taxPercentage': serializer.toJson<double>(taxPercentage),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'receiptHeader': serializer.toJson<String?>(receiptHeader),
      'receiptFooter': serializer.toJson<String?>(receiptFooter),
      'kitchenBypass': serializer.toJson<bool>(kitchenBypass),
      'paymentMethods': serializer.toJson<String>(paymentMethods),
      'planName': serializer.toJson<String?>(planName),
      'hasKitchen': serializer.toJson<bool>(hasKitchen),
      'hasStaff': serializer.toJson<bool>(hasStaff),
      'hasInventory': serializer.toJson<bool>(hasInventory),
      'startingBillNumber': serializer.toJson<int>(startingBillNumber),
    };
  }

  LocalRestaurant copyWith({
    String? id,
    String? name,
    String? currency,
    String? currencySymbol,
    double? taxPercentage,
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> receiptHeader = const Value.absent(),
    Value<String?> receiptFooter = const Value.absent(),
    bool? kitchenBypass,
    String? paymentMethods,
    Value<String?> planName = const Value.absent(),
    bool? hasKitchen,
    bool? hasStaff,
    bool? hasInventory,
    int? startingBillNumber,
  }) => LocalRestaurant(
    id: id ?? this.id,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    currencySymbol: currencySymbol ?? this.currencySymbol,
    taxPercentage: taxPercentage ?? this.taxPercentage,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    receiptHeader: receiptHeader.present
        ? receiptHeader.value
        : this.receiptHeader,
    receiptFooter: receiptFooter.present
        ? receiptFooter.value
        : this.receiptFooter,
    kitchenBypass: kitchenBypass ?? this.kitchenBypass,
    paymentMethods: paymentMethods ?? this.paymentMethods,
    planName: planName.present ? planName.value : this.planName,
    hasKitchen: hasKitchen ?? this.hasKitchen,
    hasStaff: hasStaff ?? this.hasStaff,
    hasInventory: hasInventory ?? this.hasInventory,
    startingBillNumber: startingBillNumber ?? this.startingBillNumber,
  );
  LocalRestaurant copyWithCompanion(LocalRestaurantsCompanion data) {
    return LocalRestaurant(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      taxPercentage: data.taxPercentage.present
          ? data.taxPercentage.value
          : this.taxPercentage,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      receiptHeader: data.receiptHeader.present
          ? data.receiptHeader.value
          : this.receiptHeader,
      receiptFooter: data.receiptFooter.present
          ? data.receiptFooter.value
          : this.receiptFooter,
      kitchenBypass: data.kitchenBypass.present
          ? data.kitchenBypass.value
          : this.kitchenBypass,
      paymentMethods: data.paymentMethods.present
          ? data.paymentMethods.value
          : this.paymentMethods,
      planName: data.planName.present ? data.planName.value : this.planName,
      hasKitchen: data.hasKitchen.present
          ? data.hasKitchen.value
          : this.hasKitchen,
      hasStaff: data.hasStaff.present ? data.hasStaff.value : this.hasStaff,
      hasInventory: data.hasInventory.present
          ? data.hasInventory.value
          : this.hasInventory,
      startingBillNumber: data.startingBillNumber.present
          ? data.startingBillNumber.value
          : this.startingBillNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRestaurant(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('receiptHeader: $receiptHeader, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('kitchenBypass: $kitchenBypass, ')
          ..write('paymentMethods: $paymentMethods, ')
          ..write('planName: $planName, ')
          ..write('hasKitchen: $hasKitchen, ')
          ..write('hasStaff: $hasStaff, ')
          ..write('hasInventory: $hasInventory, ')
          ..write('startingBillNumber: $startingBillNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    currency,
    currencySymbol,
    taxPercentage,
    logoUrl,
    receiptHeader,
    receiptFooter,
    kitchenBypass,
    paymentMethods,
    planName,
    hasKitchen,
    hasStaff,
    hasInventory,
    startingBillNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRestaurant &&
          other.id == this.id &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.currencySymbol == this.currencySymbol &&
          other.taxPercentage == this.taxPercentage &&
          other.logoUrl == this.logoUrl &&
          other.receiptHeader == this.receiptHeader &&
          other.receiptFooter == this.receiptFooter &&
          other.kitchenBypass == this.kitchenBypass &&
          other.paymentMethods == this.paymentMethods &&
          other.planName == this.planName &&
          other.hasKitchen == this.hasKitchen &&
          other.hasStaff == this.hasStaff &&
          other.hasInventory == this.hasInventory &&
          other.startingBillNumber == this.startingBillNumber);
}

class LocalRestaurantsCompanion extends UpdateCompanion<LocalRestaurant> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> currency;
  final Value<String> currencySymbol;
  final Value<double> taxPercentage;
  final Value<String?> logoUrl;
  final Value<String?> receiptHeader;
  final Value<String?> receiptFooter;
  final Value<bool> kitchenBypass;
  final Value<String> paymentMethods;
  final Value<String?> planName;
  final Value<bool> hasKitchen;
  final Value<bool> hasStaff;
  final Value<bool> hasInventory;
  final Value<int> startingBillNumber;
  final Value<int> rowid;
  const LocalRestaurantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.taxPercentage = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.receiptHeader = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.kitchenBypass = const Value.absent(),
    this.paymentMethods = const Value.absent(),
    this.planName = const Value.absent(),
    this.hasKitchen = const Value.absent(),
    this.hasStaff = const Value.absent(),
    this.hasInventory = const Value.absent(),
    this.startingBillNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRestaurantsCompanion.insert({
    required String id,
    required String name,
    this.currency = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.taxPercentage = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.receiptHeader = const Value.absent(),
    this.receiptFooter = const Value.absent(),
    this.kitchenBypass = const Value.absent(),
    this.paymentMethods = const Value.absent(),
    this.planName = const Value.absent(),
    this.hasKitchen = const Value.absent(),
    this.hasStaff = const Value.absent(),
    this.hasInventory = const Value.absent(),
    this.startingBillNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LocalRestaurant> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? currencySymbol,
    Expression<double>? taxPercentage,
    Expression<String>? logoUrl,
    Expression<String>? receiptHeader,
    Expression<String>? receiptFooter,
    Expression<bool>? kitchenBypass,
    Expression<String>? paymentMethods,
    Expression<String>? planName,
    Expression<bool>? hasKitchen,
    Expression<bool>? hasStaff,
    Expression<bool>? hasInventory,
    Expression<int>? startingBillNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (taxPercentage != null) 'tax_percentage': taxPercentage,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (receiptHeader != null) 'receipt_header': receiptHeader,
      if (receiptFooter != null) 'receipt_footer': receiptFooter,
      if (kitchenBypass != null) 'kitchen_bypass': kitchenBypass,
      if (paymentMethods != null) 'payment_methods': paymentMethods,
      if (planName != null) 'plan_name': planName,
      if (hasKitchen != null) 'has_kitchen': hasKitchen,
      if (hasStaff != null) 'has_staff': hasStaff,
      if (hasInventory != null) 'has_inventory': hasInventory,
      if (startingBillNumber != null)
        'starting_bill_number': startingBillNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRestaurantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? currency,
    Value<String>? currencySymbol,
    Value<double>? taxPercentage,
    Value<String?>? logoUrl,
    Value<String?>? receiptHeader,
    Value<String?>? receiptFooter,
    Value<bool>? kitchenBypass,
    Value<String>? paymentMethods,
    Value<String?>? planName,
    Value<bool>? hasKitchen,
    Value<bool>? hasStaff,
    Value<bool>? hasInventory,
    Value<int>? startingBillNumber,
    Value<int>? rowid,
  }) {
    return LocalRestaurantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      logoUrl: logoUrl ?? this.logoUrl,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      kitchenBypass: kitchenBypass ?? this.kitchenBypass,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      planName: planName ?? this.planName,
      hasKitchen: hasKitchen ?? this.hasKitchen,
      hasStaff: hasStaff ?? this.hasStaff,
      hasInventory: hasInventory ?? this.hasInventory,
      startingBillNumber: startingBillNumber ?? this.startingBillNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (taxPercentage.present) {
      map['tax_percentage'] = Variable<double>(taxPercentage.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (receiptHeader.present) {
      map['receipt_header'] = Variable<String>(receiptHeader.value);
    }
    if (receiptFooter.present) {
      map['receipt_footer'] = Variable<String>(receiptFooter.value);
    }
    if (kitchenBypass.present) {
      map['kitchen_bypass'] = Variable<bool>(kitchenBypass.value);
    }
    if (paymentMethods.present) {
      map['payment_methods'] = Variable<String>(paymentMethods.value);
    }
    if (planName.present) {
      map['plan_name'] = Variable<String>(planName.value);
    }
    if (hasKitchen.present) {
      map['has_kitchen'] = Variable<bool>(hasKitchen.value);
    }
    if (hasStaff.present) {
      map['has_staff'] = Variable<bool>(hasStaff.value);
    }
    if (hasInventory.present) {
      map['has_inventory'] = Variable<bool>(hasInventory.value);
    }
    if (startingBillNumber.present) {
      map['starting_bill_number'] = Variable<int>(startingBillNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRestaurantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('taxPercentage: $taxPercentage, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('receiptHeader: $receiptHeader, ')
          ..write('receiptFooter: $receiptFooter, ')
          ..write('kitchenBypass: $kitchenBypass, ')
          ..write('paymentMethods: $paymentMethods, ')
          ..write('planName: $planName, ')
          ..write('hasKitchen: $hasKitchen, ')
          ..write('hasStaff: $hasStaff, ')
          ..write('hasInventory: $hasInventory, ')
          ..write('startingBillNumber: $startingBillNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, email, roleId, restaurantId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role_id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      ),
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String name;
  final String email;
  final int roleId;
  final String? restaurantId;
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.restaurantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['role_id'] = Variable<int>(roleId);
    if (!nullToAbsent || restaurantId != null) {
      map['restaurant_id'] = Variable<String>(restaurantId);
    }
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      roleId: Value(roleId),
      restaurantId: restaurantId == null && nullToAbsent
          ? const Value.absent()
          : Value(restaurantId),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      roleId: serializer.fromJson<int>(json['roleId']),
      restaurantId: serializer.fromJson<String?>(json['restaurantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'roleId': serializer.toJson<int>(roleId),
      'restaurantId': serializer.toJson<String?>(restaurantId),
    };
  }

  LocalUser copyWith({
    String? id,
    String? name,
    String? email,
    int? roleId,
    Value<String?> restaurantId = const Value.absent(),
  }) => LocalUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    roleId: roleId ?? this.roleId,
    restaurantId: restaurantId.present ? restaurantId.value : this.restaurantId,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('roleId: $roleId, ')
          ..write('restaurantId: $restaurantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, roleId, restaurantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.roleId == this.roleId &&
          other.restaurantId == this.restaurantId);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<int> roleId;
  final Value<String?> restaurantId;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.roleId = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    required int roleId,
    this.restaurantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       roleId = Value(roleId);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? roleId,
    Expression<String>? restaurantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (roleId != null) 'role_id': roleId,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<int>? roleId,
    Value<String?>? restaurantId,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      restaurantId: restaurantId ?? this.restaurantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('roleId: $roleId, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTablesTable extends LocalTables
    with TableInfo<$LocalTablesTable, LocalTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableNumberMeta = const VerificationMeta(
    'tableNumber',
  );
  @override
  late final GeneratedColumn<String> tableNumber = GeneratedColumn<String>(
    'table_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('available'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    tableNumber,
    capacity,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('table_number')) {
      context.handle(
        _tableNumberMeta,
        tableNumber.isAcceptableOrUnknown(
          data['table_number']!,
          _tableNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableNumberMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      tableNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_number'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $LocalTablesTable createAlias(String alias) {
    return $LocalTablesTable(attachedDatabase, alias);
  }
}

class LocalTable extends DataClass implements Insertable<LocalTable> {
  final String id;
  final String restaurantId;
  final String tableNumber;
  final int capacity;
  final String status;
  const LocalTable({
    required this.id,
    required this.restaurantId,
    required this.tableNumber,
    required this.capacity,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['table_number'] = Variable<String>(tableNumber);
    map['capacity'] = Variable<int>(capacity);
    map['status'] = Variable<String>(status);
    return map;
  }

  LocalTablesCompanion toCompanion(bool nullToAbsent) {
    return LocalTablesCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      tableNumber: Value(tableNumber),
      capacity: Value(capacity),
      status: Value(status),
    );
  }

  factory LocalTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTable(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      tableNumber: serializer.fromJson<String>(json['tableNumber']),
      capacity: serializer.fromJson<int>(json['capacity']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'tableNumber': serializer.toJson<String>(tableNumber),
      'capacity': serializer.toJson<int>(capacity),
      'status': serializer.toJson<String>(status),
    };
  }

  LocalTable copyWith({
    String? id,
    String? restaurantId,
    String? tableNumber,
    int? capacity,
    String? status,
  }) => LocalTable(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    tableNumber: tableNumber ?? this.tableNumber,
    capacity: capacity ?? this.capacity,
    status: status ?? this.status,
  );
  LocalTable copyWithCompanion(LocalTablesCompanion data) {
    return LocalTable(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      tableNumber: data.tableNumber.present
          ? data.tableNumber.value
          : this.tableNumber,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTable(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, restaurantId, tableNumber, capacity, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTable &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.tableNumber == this.tableNumber &&
          other.capacity == this.capacity &&
          other.status == this.status);
}

class LocalTablesCompanion extends UpdateCompanion<LocalTable> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> tableNumber;
  final Value<int> capacity;
  final Value<String> status;
  final Value<int> rowid;
  const LocalTablesCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.tableNumber = const Value.absent(),
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTablesCompanion.insert({
    required String id,
    required String restaurantId,
    required String tableNumber,
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       tableNumber = Value(tableNumber);
  static Insertable<LocalTable> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? tableNumber,
    Expression<int>? capacity,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (tableNumber != null) 'table_number': tableNumber,
      if (capacity != null) 'capacity': capacity,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTablesCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? tableNumber,
    Value<int>? capacity,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return LocalTablesCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (tableNumber.present) {
      map['table_number'] = Variable<String>(tableNumber.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTablesCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('tableNumber: $tableNumber, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMenuCategoriesTable extends LocalMenuCategories
    with TableInfo<$LocalMenuCategoriesTable, LocalMenuCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMenuCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, restaurantId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_menu_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMenuCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMenuCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMenuCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LocalMenuCategoriesTable createAlias(String alias) {
    return $LocalMenuCategoriesTable(attachedDatabase, alias);
  }
}

class LocalMenuCategory extends DataClass
    implements Insertable<LocalMenuCategory> {
  final String id;
  final String restaurantId;
  final String name;
  const LocalMenuCategory({
    required this.id,
    required this.restaurantId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['name'] = Variable<String>(name);
    return map;
  }

  LocalMenuCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalMenuCategoriesCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      name: Value(name),
    );
  }

  factory LocalMenuCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMenuCategory(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'name': serializer.toJson<String>(name),
    };
  }

  LocalMenuCategory copyWith({
    String? id,
    String? restaurantId,
    String? name,
  }) => LocalMenuCategory(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    name: name ?? this.name,
  );
  LocalMenuCategory copyWithCompanion(LocalMenuCategoriesCompanion data) {
    return LocalMenuCategory(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuCategory(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, restaurantId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMenuCategory &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.name == this.name);
}

class LocalMenuCategoriesCompanion extends UpdateCompanion<LocalMenuCategory> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> name;
  final Value<int> rowid;
  const LocalMenuCategoriesCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMenuCategoriesCompanion.insert({
    required String id,
    required String restaurantId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       name = Value(name);
  static Insertable<LocalMenuCategory> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMenuCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return LocalMenuCategoriesCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMenuItemsTable extends LocalMenuItems
    with TableInfo<$LocalMenuItemsTable, LocalMenuItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDealMeta = const VerificationMeta('isDeal');
  @override
  late final GeneratedColumn<bool> isDeal = GeneratedColumn<bool>(
    'is_deal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    categoryId,
    name,
    description,
    price,
    costPrice,
    stockQuantity,
    imageUrl,
    isDeal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_menu_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMenuItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_deal')) {
      context.handle(
        _isDealMeta,
        isDeal.isAcceptableOrUnknown(data['is_deal']!, _isDealMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMenuItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMenuItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_quantity'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      isDeal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deal'],
      )!,
    );
  }

  @override
  $LocalMenuItemsTable createAlias(String alias) {
    return $LocalMenuItemsTable(attachedDatabase, alias);
  }
}

class LocalMenuItem extends DataClass implements Insertable<LocalMenuItem> {
  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String? imageUrl;
  final bool isDeal;
  const LocalMenuItem({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    this.imageUrl,
    required this.isDeal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    map['cost_price'] = Variable<double>(costPrice);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_deal'] = Variable<bool>(isDeal);
    return map;
  }

  LocalMenuItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalMenuItemsCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      costPrice: Value(costPrice),
      stockQuantity: Value(stockQuantity),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isDeal: Value(isDeal),
    );
  }

  factory LocalMenuItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMenuItem(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isDeal: serializer.fromJson<bool>(json['isDeal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'costPrice': serializer.toJson<double>(costPrice),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isDeal': serializer.toJson<bool>(isDeal),
    };
  }

  LocalMenuItem copyWith({
    String? id,
    String? restaurantId,
    String? categoryId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? price,
    double? costPrice,
    int? stockQuantity,
    Value<String?> imageUrl = const Value.absent(),
    bool? isDeal,
  }) => LocalMenuItem(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    costPrice: costPrice ?? this.costPrice,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    isDeal: isDeal ?? this.isDeal,
  );
  LocalMenuItem copyWithCompanion(LocalMenuItemsCompanion data) {
    return LocalMenuItem(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isDeal: data.isDeal.present ? data.isDeal.value : this.isDeal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuItem(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isDeal: $isDeal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    restaurantId,
    categoryId,
    name,
    description,
    price,
    costPrice,
    stockQuantity,
    imageUrl,
    isDeal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMenuItem &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.costPrice == this.costPrice &&
          other.stockQuantity == this.stockQuantity &&
          other.imageUrl == this.imageUrl &&
          other.isDeal == this.isDeal);
}

class LocalMenuItemsCompanion extends UpdateCompanion<LocalMenuItem> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<double> costPrice;
  final Value<int> stockQuantity;
  final Value<String?> imageUrl;
  final Value<bool> isDeal;
  final Value<int> rowid;
  const LocalMenuItemsCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isDeal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMenuItemsCompanion.insert({
    required String id,
    required String restaurantId,
    required String categoryId,
    required String name,
    this.description = const Value.absent(),
    required double price,
    this.costPrice = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isDeal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       categoryId = Value(categoryId),
       name = Value(name),
       price = Value(price);
  static Insertable<LocalMenuItem> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<int>? stockQuantity,
    Expression<String>? imageUrl,
    Expression<bool>? isDeal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isDeal != null) 'is_deal': isDeal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMenuItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? price,
    Value<double>? costPrice,
    Value<int>? stockQuantity,
    Value<String?>? imageUrl,
    Value<bool>? isDeal,
    Value<int>? rowid,
  }) {
    return LocalMenuItemsCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isDeal: isDeal ?? this.isDeal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isDeal.present) {
      map['is_deal'] = Variable<bool>(isDeal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuItemsCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isDeal: $isDeal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIngredientsTable extends LocalIngredients
    with TableInfo<$LocalIngredientsTable, LocalIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    name,
    quantity,
    unit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $LocalIngredientsTable createAlias(String alias) {
    return $LocalIngredientsTable(attachedDatabase, alias);
  }
}

class LocalIngredient extends DataClass implements Insertable<LocalIngredient> {
  final String id;
  final String restaurantId;
  final String name;
  final double quantity;
  final String unit;
  const LocalIngredient({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.quantity,
    required this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  LocalIngredientsCompanion toCompanion(bool nullToAbsent) {
    return LocalIngredientsCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
    );
  }

  factory LocalIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIngredient(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
    };
  }

  LocalIngredient copyWith({
    String? id,
    String? restaurantId,
    String? name,
    double? quantity,
    String? unit,
  }) => LocalIngredient(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
  );
  LocalIngredient copyWithCompanion(LocalIngredientsCompanion data) {
    return LocalIngredient(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIngredient(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, restaurantId, name, quantity, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIngredient &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit);
}

class LocalIngredientsCompanion extends UpdateCompanion<LocalIngredient> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> name;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<int> rowid;
  const LocalIngredientsCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIngredientsCompanion.insert({
    required String id,
    required String restaurantId,
    required String name,
    required double quantity,
    required String unit,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       name = Value(name),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<LocalIngredient> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? name,
    Value<double>? quantity,
    Value<String>? unit,
    Value<int>? rowid,
  }) {
    return LocalIngredientsCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMenuItemIngredientsTable extends LocalMenuItemIngredients
    with TableInfo<$LocalMenuItemIngredientsTable, LocalMenuItemIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMenuItemIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _menuItemIdMeta = const VerificationMeta(
    'menuItemId',
  );
  @override
  late final GeneratedColumn<String> menuItemId = GeneratedColumn<String>(
    'menu_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityNeededMeta = const VerificationMeta(
    'quantityNeeded',
  );
  @override
  late final GeneratedColumn<double> quantityNeeded = GeneratedColumn<double>(
    'quantity_needed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    menuItemId,
    ingredientId,
    quantityNeeded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_menu_item_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMenuItemIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('menu_item_id')) {
      context.handle(
        _menuItemIdMeta,
        menuItemId.isAcceptableOrUnknown(
          data['menu_item_id']!,
          _menuItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_menuItemIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('quantity_needed')) {
      context.handle(
        _quantityNeededMeta,
        quantityNeeded.isAcceptableOrUnknown(
          data['quantity_needed']!,
          _quantityNeededMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityNeededMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {menuItemId, ingredientId};
  @override
  LocalMenuItemIngredient map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMenuItemIngredient(
      menuItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_item_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      )!,
      quantityNeeded: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_needed'],
      )!,
    );
  }

  @override
  $LocalMenuItemIngredientsTable createAlias(String alias) {
    return $LocalMenuItemIngredientsTable(attachedDatabase, alias);
  }
}

class LocalMenuItemIngredient extends DataClass
    implements Insertable<LocalMenuItemIngredient> {
  final String menuItemId;
  final String ingredientId;
  final double quantityNeeded;
  const LocalMenuItemIngredient({
    required this.menuItemId,
    required this.ingredientId,
    required this.quantityNeeded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['menu_item_id'] = Variable<String>(menuItemId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['quantity_needed'] = Variable<double>(quantityNeeded);
    return map;
  }

  LocalMenuItemIngredientsCompanion toCompanion(bool nullToAbsent) {
    return LocalMenuItemIngredientsCompanion(
      menuItemId: Value(menuItemId),
      ingredientId: Value(ingredientId),
      quantityNeeded: Value(quantityNeeded),
    );
  }

  factory LocalMenuItemIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMenuItemIngredient(
      menuItemId: serializer.fromJson<String>(json['menuItemId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      quantityNeeded: serializer.fromJson<double>(json['quantityNeeded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'menuItemId': serializer.toJson<String>(menuItemId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'quantityNeeded': serializer.toJson<double>(quantityNeeded),
    };
  }

  LocalMenuItemIngredient copyWith({
    String? menuItemId,
    String? ingredientId,
    double? quantityNeeded,
  }) => LocalMenuItemIngredient(
    menuItemId: menuItemId ?? this.menuItemId,
    ingredientId: ingredientId ?? this.ingredientId,
    quantityNeeded: quantityNeeded ?? this.quantityNeeded,
  );
  LocalMenuItemIngredient copyWithCompanion(
    LocalMenuItemIngredientsCompanion data,
  ) {
    return LocalMenuItemIngredient(
      menuItemId: data.menuItemId.present
          ? data.menuItemId.value
          : this.menuItemId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      quantityNeeded: data.quantityNeeded.present
          ? data.quantityNeeded.value
          : this.quantityNeeded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuItemIngredient(')
          ..write('menuItemId: $menuItemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityNeeded: $quantityNeeded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(menuItemId, ingredientId, quantityNeeded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMenuItemIngredient &&
          other.menuItemId == this.menuItemId &&
          other.ingredientId == this.ingredientId &&
          other.quantityNeeded == this.quantityNeeded);
}

class LocalMenuItemIngredientsCompanion
    extends UpdateCompanion<LocalMenuItemIngredient> {
  final Value<String> menuItemId;
  final Value<String> ingredientId;
  final Value<double> quantityNeeded;
  final Value<int> rowid;
  const LocalMenuItemIngredientsCompanion({
    this.menuItemId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.quantityNeeded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMenuItemIngredientsCompanion.insert({
    required String menuItemId,
    required String ingredientId,
    required double quantityNeeded,
    this.rowid = const Value.absent(),
  }) : menuItemId = Value(menuItemId),
       ingredientId = Value(ingredientId),
       quantityNeeded = Value(quantityNeeded);
  static Insertable<LocalMenuItemIngredient> custom({
    Expression<String>? menuItemId,
    Expression<String>? ingredientId,
    Expression<double>? quantityNeeded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (quantityNeeded != null) 'quantity_needed': quantityNeeded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMenuItemIngredientsCompanion copyWith({
    Value<String>? menuItemId,
    Value<String>? ingredientId,
    Value<double>? quantityNeeded,
    Value<int>? rowid,
  }) {
    return LocalMenuItemIngredientsCompanion(
      menuItemId: menuItemId ?? this.menuItemId,
      ingredientId: ingredientId ?? this.ingredientId,
      quantityNeeded: quantityNeeded ?? this.quantityNeeded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<String>(menuItemId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (quantityNeeded.present) {
      map['quantity_needed'] = Variable<double>(quantityNeeded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMenuItemIngredientsCompanion(')
          ..write('menuItemId: $menuItemId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('quantityNeeded: $quantityNeeded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDealItemsTable extends LocalDealItems
    with TableInfo<$LocalDealItemsTable, LocalDealItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dealItemIdMeta = const VerificationMeta(
    'dealItemId',
  );
  @override
  late final GeneratedColumn<String> dealItemId = GeneratedColumn<String>(
    'deal_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childItemIdMeta = const VerificationMeta(
    'childItemId',
  );
  @override
  late final GeneratedColumn<String> childItemId = GeneratedColumn<String>(
    'child_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [dealItemId, childItemId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_deal_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDealItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deal_item_id')) {
      context.handle(
        _dealItemIdMeta,
        dealItemId.isAcceptableOrUnknown(
          data['deal_item_id']!,
          _dealItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dealItemIdMeta);
    }
    if (data.containsKey('child_item_id')) {
      context.handle(
        _childItemIdMeta,
        childItemId.isAcceptableOrUnknown(
          data['child_item_id']!,
          _childItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_childItemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dealItemId, childItemId};
  @override
  LocalDealItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDealItem(
      dealItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deal_item_id'],
      )!,
      childItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_item_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $LocalDealItemsTable createAlias(String alias) {
    return $LocalDealItemsTable(attachedDatabase, alias);
  }
}

class LocalDealItem extends DataClass implements Insertable<LocalDealItem> {
  final String dealItemId;
  final String childItemId;
  final int quantity;
  const LocalDealItem({
    required this.dealItemId,
    required this.childItemId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['deal_item_id'] = Variable<String>(dealItemId);
    map['child_item_id'] = Variable<String>(childItemId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  LocalDealItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalDealItemsCompanion(
      dealItemId: Value(dealItemId),
      childItemId: Value(childItemId),
      quantity: Value(quantity),
    );
  }

  factory LocalDealItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDealItem(
      dealItemId: serializer.fromJson<String>(json['dealItemId']),
      childItemId: serializer.fromJson<String>(json['childItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dealItemId': serializer.toJson<String>(dealItemId),
      'childItemId': serializer.toJson<String>(childItemId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  LocalDealItem copyWith({
    String? dealItemId,
    String? childItemId,
    int? quantity,
  }) => LocalDealItem(
    dealItemId: dealItemId ?? this.dealItemId,
    childItemId: childItemId ?? this.childItemId,
    quantity: quantity ?? this.quantity,
  );
  LocalDealItem copyWithCompanion(LocalDealItemsCompanion data) {
    return LocalDealItem(
      dealItemId: data.dealItemId.present
          ? data.dealItemId.value
          : this.dealItemId,
      childItemId: data.childItemId.present
          ? data.childItemId.value
          : this.childItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDealItem(')
          ..write('dealItemId: $dealItemId, ')
          ..write('childItemId: $childItemId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dealItemId, childItemId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDealItem &&
          other.dealItemId == this.dealItemId &&
          other.childItemId == this.childItemId &&
          other.quantity == this.quantity);
}

class LocalDealItemsCompanion extends UpdateCompanion<LocalDealItem> {
  final Value<String> dealItemId;
  final Value<String> childItemId;
  final Value<int> quantity;
  final Value<int> rowid;
  const LocalDealItemsCompanion({
    this.dealItemId = const Value.absent(),
    this.childItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDealItemsCompanion.insert({
    required String dealItemId,
    required String childItemId,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dealItemId = Value(dealItemId),
       childItemId = Value(childItemId);
  static Insertable<LocalDealItem> custom({
    Expression<String>? dealItemId,
    Expression<String>? childItemId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dealItemId != null) 'deal_item_id': dealItemId,
      if (childItemId != null) 'child_item_id': childItemId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDealItemsCompanion copyWith({
    Value<String>? dealItemId,
    Value<String>? childItemId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return LocalDealItemsCompanion(
      dealItemId: dealItemId ?? this.dealItemId,
      childItemId: childItemId ?? this.childItemId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dealItemId.present) {
      map['deal_item_id'] = Variable<String>(dealItemId.value);
    }
    if (childItemId.present) {
      map['child_item_id'] = Variable<String>(childItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDealItemsCompanion(')
          ..write('dealItemId: $dealItemId, ')
          ..write('childItemId: $childItemId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOrdersTable extends LocalOrders
    with TableInfo<$LocalOrdersTable, LocalOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<String> tableId = GeneratedColumn<String>(
    'table_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderTypeMeta = const VerificationMeta(
    'orderType',
  );
  @override
  late final GeneratedColumn<String> orderType = GeneratedColumn<String>(
    'order_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
    'tax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMeta = const VerificationMeta(
    'discount',
  );
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
    'discount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deliveryFeeMeta = const VerificationMeta(
    'deliveryFee',
  );
  @override
  late final GeneratedColumn<double> deliveryFee = GeneratedColumn<double>(
    'delivery_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryAddressMeta = const VerificationMeta(
    'deliveryAddress',
  );
  @override
  late final GeneratedColumn<String> deliveryAddress = GeneratedColumn<String>(
    'delivery_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billNumberMeta = const VerificationMeta(
    'billNumber',
  );
  @override
  late final GeneratedColumn<int> billNumber = GeneratedColumn<int>(
    'bill_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    tableId,
    userId,
    orderType,
    status,
    paymentStatus,
    paymentMethod,
    subtotal,
    tax,
    discount,
    deliveryFee,
    total,
    customerName,
    customerPhone,
    deliveryAddress,
    notes,
    createdAt,
    billNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('order_type')) {
      context.handle(
        _orderTypeMeta,
        orderType.isAcceptableOrUnknown(data['order_type']!, _orderTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_orderTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax')) {
      context.handle(
        _taxMeta,
        tax.isAcceptableOrUnknown(data['tax']!, _taxMeta),
      );
    } else if (isInserting) {
      context.missing(_taxMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(
        _discountMeta,
        discount.isAcceptableOrUnknown(data['discount']!, _discountMeta),
      );
    }
    if (data.containsKey('delivery_fee')) {
      context.handle(
        _deliveryFeeMeta,
        deliveryFee.isAcceptableOrUnknown(
          data['delivery_fee']!,
          _deliveryFeeMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('delivery_address')) {
      context.handle(
        _deliveryAddressMeta,
        deliveryAddress.isAcceptableOrUnknown(
          data['delivery_address']!,
          _deliveryAddressMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('bill_number')) {
      context.handle(
        _billNumberMeta,
        billNumber.isAcceptableOrUnknown(data['bill_number']!, _billNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      orderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax'],
      )!,
      discount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount'],
      )!,
      deliveryFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_fee'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      ),
      deliveryAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      billNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bill_number'],
      ),
    );
  }

  @override
  $LocalOrdersTable createAlias(String alias) {
    return $LocalOrdersTable(attachedDatabase, alias);
  }
}

class LocalOrder extends DataClass implements Insertable<LocalOrder> {
  final String id;
  final String restaurantId;
  final String? tableId;
  final String userId;
  final String orderType;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final double subtotal;
  final double tax;
  final double discount;
  final double deliveryFee;
  final double total;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final int? billNumber;
  const LocalOrder({
    required this.id,
    required this.restaurantId,
    this.tableId,
    required this.userId,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.notes,
    required this.createdAt,
    this.billNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    if (!nullToAbsent || tableId != null) {
      map['table_id'] = Variable<String>(tableId);
    }
    map['user_id'] = Variable<String>(userId);
    map['order_type'] = Variable<String>(orderType);
    map['status'] = Variable<String>(status);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tax'] = Variable<double>(tax);
    map['discount'] = Variable<double>(discount);
    map['delivery_fee'] = Variable<double>(deliveryFee);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    if (!nullToAbsent || customerPhone != null) {
      map['customer_phone'] = Variable<String>(customerPhone);
    }
    if (!nullToAbsent || deliveryAddress != null) {
      map['delivery_address'] = Variable<String>(deliveryAddress);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || billNumber != null) {
      map['bill_number'] = Variable<int>(billNumber);
    }
    return map;
  }

  LocalOrdersCompanion toCompanion(bool nullToAbsent) {
    return LocalOrdersCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      tableId: tableId == null && nullToAbsent
          ? const Value.absent()
          : Value(tableId),
      userId: Value(userId),
      orderType: Value(orderType),
      status: Value(status),
      paymentStatus: Value(paymentStatus),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      subtotal: Value(subtotal),
      tax: Value(tax),
      discount: Value(discount),
      deliveryFee: Value(deliveryFee),
      total: Value(total),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      customerPhone: customerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(customerPhone),
      deliveryAddress: deliveryAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryAddress),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      billNumber: billNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(billNumber),
    );
  }

  factory LocalOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOrder(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      tableId: serializer.fromJson<String?>(json['tableId']),
      userId: serializer.fromJson<String>(json['userId']),
      orderType: serializer.fromJson<String>(json['orderType']),
      status: serializer.fromJson<String>(json['status']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tax: serializer.fromJson<double>(json['tax']),
      discount: serializer.fromJson<double>(json['discount']),
      deliveryFee: serializer.fromJson<double>(json['deliveryFee']),
      total: serializer.fromJson<double>(json['total']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      customerPhone: serializer.fromJson<String?>(json['customerPhone']),
      deliveryAddress: serializer.fromJson<String?>(json['deliveryAddress']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      billNumber: serializer.fromJson<int?>(json['billNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'tableId': serializer.toJson<String?>(tableId),
      'userId': serializer.toJson<String>(userId),
      'orderType': serializer.toJson<String>(orderType),
      'status': serializer.toJson<String>(status),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'subtotal': serializer.toJson<double>(subtotal),
      'tax': serializer.toJson<double>(tax),
      'discount': serializer.toJson<double>(discount),
      'deliveryFee': serializer.toJson<double>(deliveryFee),
      'total': serializer.toJson<double>(total),
      'customerName': serializer.toJson<String?>(customerName),
      'customerPhone': serializer.toJson<String?>(customerPhone),
      'deliveryAddress': serializer.toJson<String?>(deliveryAddress),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'billNumber': serializer.toJson<int?>(billNumber),
    };
  }

  LocalOrder copyWith({
    String? id,
    String? restaurantId,
    Value<String?> tableId = const Value.absent(),
    String? userId,
    String? orderType,
    String? status,
    String? paymentStatus,
    Value<String?> paymentMethod = const Value.absent(),
    double? subtotal,
    double? tax,
    double? discount,
    double? deliveryFee,
    double? total,
    Value<String?> customerName = const Value.absent(),
    Value<String?> customerPhone = const Value.absent(),
    Value<String?> deliveryAddress = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<int?> billNumber = const Value.absent(),
  }) => LocalOrder(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    tableId: tableId.present ? tableId.value : this.tableId,
    userId: userId ?? this.userId,
    orderType: orderType ?? this.orderType,
    status: status ?? this.status,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    discount: discount ?? this.discount,
    deliveryFee: deliveryFee ?? this.deliveryFee,
    total: total ?? this.total,
    customerName: customerName.present ? customerName.value : this.customerName,
    customerPhone: customerPhone.present
        ? customerPhone.value
        : this.customerPhone,
    deliveryAddress: deliveryAddress.present
        ? deliveryAddress.value
        : this.deliveryAddress,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    billNumber: billNumber.present ? billNumber.value : this.billNumber,
  );
  LocalOrder copyWithCompanion(LocalOrdersCompanion data) {
    return LocalOrder(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      userId: data.userId.present ? data.userId.value : this.userId,
      orderType: data.orderType.present ? data.orderType.value : this.orderType,
      status: data.status.present ? data.status.value : this.status,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tax: data.tax.present ? data.tax.value : this.tax,
      discount: data.discount.present ? data.discount.value : this.discount,
      deliveryFee: data.deliveryFee.present
          ? data.deliveryFee.value
          : this.deliveryFee,
      total: data.total.present ? data.total.value : this.total,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      deliveryAddress: data.deliveryAddress.present
          ? data.deliveryAddress.value
          : this.deliveryAddress,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      billNumber: data.billNumber.present
          ? data.billNumber.value
          : this.billNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrder(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('tableId: $tableId, ')
          ..write('userId: $userId, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('discount: $discount, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('total: $total, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('billNumber: $billNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    restaurantId,
    tableId,
    userId,
    orderType,
    status,
    paymentStatus,
    paymentMethod,
    subtotal,
    tax,
    discount,
    deliveryFee,
    total,
    customerName,
    customerPhone,
    deliveryAddress,
    notes,
    createdAt,
    billNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOrder &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.tableId == this.tableId &&
          other.userId == this.userId &&
          other.orderType == this.orderType &&
          other.status == this.status &&
          other.paymentStatus == this.paymentStatus &&
          other.paymentMethod == this.paymentMethod &&
          other.subtotal == this.subtotal &&
          other.tax == this.tax &&
          other.discount == this.discount &&
          other.deliveryFee == this.deliveryFee &&
          other.total == this.total &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.deliveryAddress == this.deliveryAddress &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.billNumber == this.billNumber);
}

class LocalOrdersCompanion extends UpdateCompanion<LocalOrder> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String?> tableId;
  final Value<String> userId;
  final Value<String> orderType;
  final Value<String> status;
  final Value<String> paymentStatus;
  final Value<String?> paymentMethod;
  final Value<double> subtotal;
  final Value<double> tax;
  final Value<double> discount;
  final Value<double> deliveryFee;
  final Value<double> total;
  final Value<String?> customerName;
  final Value<String?> customerPhone;
  final Value<String?> deliveryAddress;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int?> billNumber;
  final Value<int> rowid;
  const LocalOrdersCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.tableId = const Value.absent(),
    this.userId = const Value.absent(),
    this.orderType = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.discount = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.total = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOrdersCompanion.insert({
    required String id,
    required String restaurantId,
    this.tableId = const Value.absent(),
    required String userId,
    required String orderType,
    required String status,
    required String paymentStatus,
    this.paymentMethod = const Value.absent(),
    required double subtotal,
    required double tax,
    this.discount = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    required double total,
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.deliveryAddress = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.billNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       userId = Value(userId),
       orderType = Value(orderType),
       status = Value(status),
       paymentStatus = Value(paymentStatus),
       subtotal = Value(subtotal),
       tax = Value(tax),
       total = Value(total),
       createdAt = Value(createdAt);
  static Insertable<LocalOrder> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? tableId,
    Expression<String>? userId,
    Expression<String>? orderType,
    Expression<String>? status,
    Expression<String>? paymentStatus,
    Expression<String>? paymentMethod,
    Expression<double>? subtotal,
    Expression<double>? tax,
    Expression<double>? discount,
    Expression<double>? deliveryFee,
    Expression<double>? total,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? deliveryAddress,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? billNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (tableId != null) 'table_id': tableId,
      if (userId != null) 'user_id': userId,
      if (orderType != null) 'order_type': orderType,
      if (status != null) 'status': status,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (subtotal != null) 'subtotal': subtotal,
      if (tax != null) 'tax': tax,
      if (discount != null) 'discount': discount,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (total != null) 'total': total,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (deliveryAddress != null) 'delivery_address': deliveryAddress,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (billNumber != null) 'bill_number': billNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String?>? tableId,
    Value<String>? userId,
    Value<String>? orderType,
    Value<String>? status,
    Value<String>? paymentStatus,
    Value<String?>? paymentMethod,
    Value<double>? subtotal,
    Value<double>? tax,
    Value<double>? discount,
    Value<double>? deliveryFee,
    Value<double>? total,
    Value<String?>? customerName,
    Value<String?>? customerPhone,
    Value<String?>? deliveryAddress,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int?>? billNumber,
    Value<int>? rowid,
  }) {
    return LocalOrdersCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      tableId: tableId ?? this.tableId,
      userId: userId ?? this.userId,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      billNumber: billNumber ?? this.billNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<String>(tableId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (orderType.present) {
      map['order_type'] = Variable<String>(orderType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (deliveryFee.present) {
      map['delivery_fee'] = Variable<double>(deliveryFee.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (deliveryAddress.present) {
      map['delivery_address'] = Variable<String>(deliveryAddress.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (billNumber.present) {
      map['bill_number'] = Variable<int>(billNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrdersCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('tableId: $tableId, ')
          ..write('userId: $userId, ')
          ..write('orderType: $orderType, ')
          ..write('status: $status, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('discount: $discount, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('total: $total, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('deliveryAddress: $deliveryAddress, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('billNumber: $billNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOrderItemsTable extends LocalOrderItems
    with TableInfo<$LocalOrderItemsTable, LocalOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _menuItemIdMeta = const VerificationMeta(
    'menuItemId',
  );
  @override
  late final GeneratedColumn<String> menuItemId = GeneratedColumn<String>(
    'menu_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    menuItemId,
    quantity,
    price,
    costPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalOrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('menu_item_id')) {
      context.handle(
        _menuItemIdMeta,
        menuItemId.isAcceptableOrUnknown(
          data['menu_item_id']!,
          _menuItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_menuItemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      menuItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_item_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
    );
  }

  @override
  $LocalOrderItemsTable createAlias(String alias) {
    return $LocalOrderItemsTable(attachedDatabase, alias);
  }
}

class LocalOrderItem extends DataClass implements Insertable<LocalOrderItem> {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double price;
  final double costPrice;
  const LocalOrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    required this.costPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['menu_item_id'] = Variable<String>(menuItemId);
    map['quantity'] = Variable<int>(quantity);
    map['price'] = Variable<double>(price);
    map['cost_price'] = Variable<double>(costPrice);
    return map;
  }

  LocalOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalOrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      menuItemId: Value(menuItemId),
      quantity: Value(quantity),
      price: Value(price),
      costPrice: Value(costPrice),
    );
  }

  factory LocalOrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOrderItem(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      menuItemId: serializer.fromJson<String>(json['menuItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      price: serializer.fromJson<double>(json['price']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'menuItemId': serializer.toJson<String>(menuItemId),
      'quantity': serializer.toJson<int>(quantity),
      'price': serializer.toJson<double>(price),
      'costPrice': serializer.toJson<double>(costPrice),
    };
  }

  LocalOrderItem copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    int? quantity,
    double? price,
    double? costPrice,
  }) => LocalOrderItem(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    menuItemId: menuItemId ?? this.menuItemId,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    costPrice: costPrice ?? this.costPrice,
  );
  LocalOrderItem copyWithCompanion(LocalOrderItemsCompanion data) {
    return LocalOrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      menuItemId: data.menuItemId.present
          ? data.menuItemId.value
          : this.menuItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, menuItemId, quantity, price, costPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.menuItemId == this.menuItemId &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.costPrice == this.costPrice);
}

class LocalOrderItemsCompanion extends UpdateCompanion<LocalOrderItem> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> menuItemId;
  final Value<int> quantity;
  final Value<double> price;
  final Value<double> costPrice;
  final Value<int> rowid;
  const LocalOrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.menuItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOrderItemsCompanion.insert({
    required String id,
    required String orderId,
    required String menuItemId,
    required int quantity,
    required double price,
    this.costPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       menuItemId = Value(menuItemId),
       quantity = Value(quantity),
       price = Value(price);
  static Insertable<LocalOrderItem> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? menuItemId,
    Expression<int>? quantity,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? menuItemId,
    Value<int>? quantity,
    Value<double>? price,
    Value<double>? costPrice,
    Value<int>? rowid,
  }) {
    return LocalOrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<String>(menuItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    name,
    amount,
    category,
    date,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }
}

class LocalExpense extends DataClass implements Insertable<LocalExpense> {
  final String id;
  final String restaurantId;
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  const LocalExpense({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      name: Value(name),
      amount: Value(amount),
      category: Value(category),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpense(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalExpense copyWith({
    String? id,
    String? restaurantId,
    String? name,
    double? amount,
    String? category,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
  }) => LocalExpense(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalExpense copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpense(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpense(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, restaurantId, name, amount, category, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpense &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.date == this.date &&
          other.notes == this.notes);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpense> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> category;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String id,
    required String restaurantId,
    required String name,
    required double amount,
    required String category,
    required DateTime date,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       name = Value(name),
       amount = Value(amount),
       category = Value(category),
       date = Value(date);
  static Insertable<LocalExpense> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? category,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInventoryLogsTable extends LocalInventoryLogs
    with TableInfo<$LocalInventoryLogsTable, LocalInventoryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInventoryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    itemName,
    quantity,
    unit,
    cost,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inventory_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInventoryLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    } else if (isInserting) {
      context.missing(_itemNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInventoryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInventoryLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $LocalInventoryLogsTable createAlias(String alias) {
    return $LocalInventoryLogsTable(attachedDatabase, alias);
  }
}

class LocalInventoryLog extends DataClass
    implements Insertable<LocalInventoryLog> {
  final String id;
  final String restaurantId;
  final String itemName;
  final double quantity;
  final String unit;
  final double cost;
  final DateTime date;
  const LocalInventoryLog({
    required this.id,
    required this.restaurantId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.cost,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['item_name'] = Variable<String>(itemName);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['cost'] = Variable<double>(cost);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  LocalInventoryLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalInventoryLogsCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      itemName: Value(itemName),
      quantity: Value(quantity),
      unit: Value(unit),
      cost: Value(cost),
      date: Value(date),
    );
  }

  factory LocalInventoryLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInventoryLog(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      itemName: serializer.fromJson<String>(json['itemName']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      cost: serializer.fromJson<double>(json['cost']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'itemName': serializer.toJson<String>(itemName),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'cost': serializer.toJson<double>(cost),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  LocalInventoryLog copyWith({
    String? id,
    String? restaurantId,
    String? itemName,
    double? quantity,
    String? unit,
    double? cost,
    DateTime? date,
  }) => LocalInventoryLog(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    itemName: itemName ?? this.itemName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    cost: cost ?? this.cost,
    date: date ?? this.date,
  );
  LocalInventoryLog copyWithCompanion(LocalInventoryLogsCompanion data) {
    return LocalInventoryLog(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      cost: data.cost.present ? data.cost.value : this.cost,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryLog(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('cost: $cost, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, restaurantId, itemName, quantity, unit, cost, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInventoryLog &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.itemName == this.itemName &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.cost == this.cost &&
          other.date == this.date);
}

class LocalInventoryLogsCompanion extends UpdateCompanion<LocalInventoryLog> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> itemName;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<double> cost;
  final Value<DateTime> date;
  final Value<int> rowid;
  const LocalInventoryLogsCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.itemName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.cost = const Value.absent(),
    this.date = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInventoryLogsCompanion.insert({
    required String id,
    required String restaurantId,
    required String itemName,
    required double quantity,
    required String unit,
    required double cost,
    required DateTime date,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       itemName = Value(itemName),
       quantity = Value(quantity),
       unit = Value(unit),
       cost = Value(cost),
       date = Value(date);
  static Insertable<LocalInventoryLog> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? itemName,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<double>? cost,
    Expression<DateTime>? date,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (itemName != null) 'item_name': itemName,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (cost != null) 'cost': cost,
      if (date != null) 'date': date,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInventoryLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? itemName,
    Value<double>? quantity,
    Value<String>? unit,
    Value<double>? cost,
    Value<DateTime>? date,
    Value<int>? rowid,
  }) {
    return LocalInventoryLogsCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      cost: cost ?? this.cost,
      date: date ?? this.date,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('itemName: $itemName, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('cost: $cost, ')
          ..write('date: $date, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineQueuesTable extends OfflineQueues
    with TableInfo<$OfflineQueuesTable, OfflineQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableTargetMeta = const VerificationMeta(
    'tableTarget',
  );
  @override
  late final GeneratedColumn<String> tableTarget = GeneratedColumn<String>(
    'table_target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    tableTarget,
    recordId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfflineQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('table_target')) {
      context.handle(
        _tableTargetMeta,
        tableTarget.isAcceptableOrUnknown(
          data['table_target']!,
          _tableTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableTargetMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      tableTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_target'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OfflineQueuesTable createAlias(String alias) {
    return $OfflineQueuesTable(attachedDatabase, alias);
  }
}

class OfflineQueue extends DataClass implements Insertable<OfflineQueue> {
  final int id;
  final String actionType;
  final String tableTarget;
  final String recordId;
  final String payload;
  final DateTime createdAt;
  const OfflineQueue({
    required this.id,
    required this.actionType,
    required this.tableTarget,
    required this.recordId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['table_target'] = Variable<String>(tableTarget);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineQueuesCompanion toCompanion(bool nullToAbsent) {
    return OfflineQueuesCompanion(
      id: Value(id),
      actionType: Value(actionType),
      tableTarget: Value(tableTarget),
      recordId: Value(recordId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineQueue(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      tableTarget: serializer.fromJson<String>(json['tableTarget']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'tableTarget': serializer.toJson<String>(tableTarget),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineQueue copyWith({
    int? id,
    String? actionType,
    String? tableTarget,
    String? recordId,
    String? payload,
    DateTime? createdAt,
  }) => OfflineQueue(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    tableTarget: tableTarget ?? this.tableTarget,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  OfflineQueue copyWithCompanion(OfflineQueuesCompanion data) {
    return OfflineQueue(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      tableTarget: data.tableTarget.present
          ? data.tableTarget.value
          : this.tableTarget,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueue(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('tableTarget: $tableTarget, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionType, tableTarget, recordId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineQueue &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.tableTarget == this.tableTarget &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class OfflineQueuesCompanion extends UpdateCompanion<OfflineQueue> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> tableTarget;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const OfflineQueuesCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.tableTarget = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String tableTarget,
    required String recordId,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : actionType = Value(actionType),
       tableTarget = Value(tableTarget),
       recordId = Value(recordId),
       payload = Value(payload);
  static Insertable<OfflineQueue> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? tableTarget,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (tableTarget != null) 'table_target': tableTarget,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineQueuesCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? tableTarget,
    Value<String>? recordId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return OfflineQueuesCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      tableTarget: tableTarget ?? this.tableTarget,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (tableTarget.present) {
      map['table_target'] = Variable<String>(tableTarget.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineQueuesCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('tableTarget: $tableTarget, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalRestaurantsTable localRestaurants = $LocalRestaurantsTable(
    this,
  );
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalTablesTable localTables = $LocalTablesTable(this);
  late final $LocalMenuCategoriesTable localMenuCategories =
      $LocalMenuCategoriesTable(this);
  late final $LocalMenuItemsTable localMenuItems = $LocalMenuItemsTable(this);
  late final $LocalIngredientsTable localIngredients = $LocalIngredientsTable(
    this,
  );
  late final $LocalMenuItemIngredientsTable localMenuItemIngredients =
      $LocalMenuItemIngredientsTable(this);
  late final $LocalDealItemsTable localDealItems = $LocalDealItemsTable(this);
  late final $LocalOrdersTable localOrders = $LocalOrdersTable(this);
  late final $LocalOrderItemsTable localOrderItems = $LocalOrderItemsTable(
    this,
  );
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  late final $LocalInventoryLogsTable localInventoryLogs =
      $LocalInventoryLogsTable(this);
  late final $OfflineQueuesTable offlineQueues = $OfflineQueuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localRestaurants,
    localUsers,
    localTables,
    localMenuCategories,
    localMenuItems,
    localIngredients,
    localMenuItemIngredients,
    localDealItems,
    localOrders,
    localOrderItems,
    localExpenses,
    localInventoryLogs,
    offlineQueues,
  ];
}

typedef $$LocalRestaurantsTableCreateCompanionBuilder =
    LocalRestaurantsCompanion Function({
      required String id,
      required String name,
      Value<String> currency,
      Value<String> currencySymbol,
      Value<double> taxPercentage,
      Value<String?> logoUrl,
      Value<String?> receiptHeader,
      Value<String?> receiptFooter,
      Value<bool> kitchenBypass,
      Value<String> paymentMethods,
      Value<String?> planName,
      Value<bool> hasKitchen,
      Value<bool> hasStaff,
      Value<bool> hasInventory,
      Value<int> startingBillNumber,
      Value<int> rowid,
    });
typedef $$LocalRestaurantsTableUpdateCompanionBuilder =
    LocalRestaurantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> currency,
      Value<String> currencySymbol,
      Value<double> taxPercentage,
      Value<String?> logoUrl,
      Value<String?> receiptHeader,
      Value<String?> receiptFooter,
      Value<bool> kitchenBypass,
      Value<String> paymentMethods,
      Value<String?> planName,
      Value<bool> hasKitchen,
      Value<bool> hasStaff,
      Value<bool> hasInventory,
      Value<int> startingBillNumber,
      Value<int> rowid,
    });

class $$LocalRestaurantsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRestaurantsTable> {
  $$LocalRestaurantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kitchenBypass => $composableBuilder(
    column: $table.kitchenBypass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethods => $composableBuilder(
    column: $table.paymentMethods,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasKitchen => $composableBuilder(
    column: $table.hasKitchen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasStaff => $composableBuilder(
    column: $table.hasStaff,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasInventory => $composableBuilder(
    column: $table.hasInventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startingBillNumber => $composableBuilder(
    column: $table.startingBillNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRestaurantsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRestaurantsTable> {
  $$LocalRestaurantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kitchenBypass => $composableBuilder(
    column: $table.kitchenBypass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethods => $composableBuilder(
    column: $table.paymentMethods,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planName => $composableBuilder(
    column: $table.planName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasKitchen => $composableBuilder(
    column: $table.hasKitchen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasStaff => $composableBuilder(
    column: $table.hasStaff,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasInventory => $composableBuilder(
    column: $table.hasInventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startingBillNumber => $composableBuilder(
    column: $table.startingBillNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRestaurantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRestaurantsTable> {
  $$LocalRestaurantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
    column: $table.currencySymbol,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxPercentage => $composableBuilder(
    column: $table.taxPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get receiptHeader => $composableBuilder(
    column: $table.receiptHeader,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptFooter => $composableBuilder(
    column: $table.receiptFooter,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get kitchenBypass => $composableBuilder(
    column: $table.kitchenBypass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethods => $composableBuilder(
    column: $table.paymentMethods,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planName =>
      $composableBuilder(column: $table.planName, builder: (column) => column);

  GeneratedColumn<bool> get hasKitchen => $composableBuilder(
    column: $table.hasKitchen,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasStaff =>
      $composableBuilder(column: $table.hasStaff, builder: (column) => column);

  GeneratedColumn<bool> get hasInventory => $composableBuilder(
    column: $table.hasInventory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startingBillNumber => $composableBuilder(
    column: $table.startingBillNumber,
    builder: (column) => column,
  );
}

class $$LocalRestaurantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRestaurantsTable,
          LocalRestaurant,
          $$LocalRestaurantsTableFilterComposer,
          $$LocalRestaurantsTableOrderingComposer,
          $$LocalRestaurantsTableAnnotationComposer,
          $$LocalRestaurantsTableCreateCompanionBuilder,
          $$LocalRestaurantsTableUpdateCompanionBuilder,
          (
            LocalRestaurant,
            BaseReferences<
              _$AppDatabase,
              $LocalRestaurantsTable,
              LocalRestaurant
            >,
          ),
          LocalRestaurant,
          PrefetchHooks Function()
        > {
  $$LocalRestaurantsTableTableManager(
    _$AppDatabase db,
    $LocalRestaurantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRestaurantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRestaurantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRestaurantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<double> taxPercentage = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> receiptHeader = const Value.absent(),
                Value<String?> receiptFooter = const Value.absent(),
                Value<bool> kitchenBypass = const Value.absent(),
                Value<String> paymentMethods = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<bool> hasKitchen = const Value.absent(),
                Value<bool> hasStaff = const Value.absent(),
                Value<bool> hasInventory = const Value.absent(),
                Value<int> startingBillNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRestaurantsCompanion(
                id: id,
                name: name,
                currency: currency,
                currencySymbol: currencySymbol,
                taxPercentage: taxPercentage,
                logoUrl: logoUrl,
                receiptHeader: receiptHeader,
                receiptFooter: receiptFooter,
                kitchenBypass: kitchenBypass,
                paymentMethods: paymentMethods,
                planName: planName,
                hasKitchen: hasKitchen,
                hasStaff: hasStaff,
                hasInventory: hasInventory,
                startingBillNumber: startingBillNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> currency = const Value.absent(),
                Value<String> currencySymbol = const Value.absent(),
                Value<double> taxPercentage = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> receiptHeader = const Value.absent(),
                Value<String?> receiptFooter = const Value.absent(),
                Value<bool> kitchenBypass = const Value.absent(),
                Value<String> paymentMethods = const Value.absent(),
                Value<String?> planName = const Value.absent(),
                Value<bool> hasKitchen = const Value.absent(),
                Value<bool> hasStaff = const Value.absent(),
                Value<bool> hasInventory = const Value.absent(),
                Value<int> startingBillNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRestaurantsCompanion.insert(
                id: id,
                name: name,
                currency: currency,
                currencySymbol: currencySymbol,
                taxPercentage: taxPercentage,
                logoUrl: logoUrl,
                receiptHeader: receiptHeader,
                receiptFooter: receiptFooter,
                kitchenBypass: kitchenBypass,
                paymentMethods: paymentMethods,
                planName: planName,
                hasKitchen: hasKitchen,
                hasStaff: hasStaff,
                hasInventory: hasInventory,
                startingBillNumber: startingBillNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRestaurantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRestaurantsTable,
      LocalRestaurant,
      $$LocalRestaurantsTableFilterComposer,
      $$LocalRestaurantsTableOrderingComposer,
      $$LocalRestaurantsTableAnnotationComposer,
      $$LocalRestaurantsTableCreateCompanionBuilder,
      $$LocalRestaurantsTableUpdateCompanionBuilder,
      (
        LocalRestaurant,
        BaseReferences<_$AppDatabase, $LocalRestaurantsTable, LocalRestaurant>,
      ),
      LocalRestaurant,
      PrefetchHooks Function()
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      required String name,
      required String email,
      required int roleId,
      Value<String?> restaurantId,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<int> roleId,
      Value<String?> restaurantId,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roleId => $composableBuilder(
    column: $table.roleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> roleId = const Value.absent(),
                Value<String?> restaurantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                name: name,
                email: email,
                roleId: roleId,
                restaurantId: restaurantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                required int roleId,
                Value<String?> restaurantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                roleId: roleId,
                restaurantId: restaurantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalTablesTableCreateCompanionBuilder =
    LocalTablesCompanion Function({
      required String id,
      required String restaurantId,
      required String tableNumber,
      Value<int> capacity,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$LocalTablesTableUpdateCompanionBuilder =
    LocalTablesCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> tableNumber,
      Value<int> capacity,
      Value<String> status,
      Value<int> rowid,
    });

class $$LocalTablesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTablesTable> {
  $$LocalTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTablesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTablesTable> {
  $$LocalTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTablesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTablesTable> {
  $$LocalTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tableNumber => $composableBuilder(
    column: $table.tableNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LocalTablesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTablesTable,
          LocalTable,
          $$LocalTablesTableFilterComposer,
          $$LocalTablesTableOrderingComposer,
          $$LocalTablesTableAnnotationComposer,
          $$LocalTablesTableCreateCompanionBuilder,
          $$LocalTablesTableUpdateCompanionBuilder,
          (
            LocalTable,
            BaseReferences<_$AppDatabase, $LocalTablesTable, LocalTable>,
          ),
          LocalTable,
          PrefetchHooks Function()
        > {
  $$LocalTablesTableTableManager(_$AppDatabase db, $LocalTablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> tableNumber = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTablesCompanion(
                id: id,
                restaurantId: restaurantId,
                tableNumber: tableNumber,
                capacity: capacity,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String tableNumber,
                Value<int> capacity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTablesCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                tableNumber: tableNumber,
                capacity: capacity,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTablesTable,
      LocalTable,
      $$LocalTablesTableFilterComposer,
      $$LocalTablesTableOrderingComposer,
      $$LocalTablesTableAnnotationComposer,
      $$LocalTablesTableCreateCompanionBuilder,
      $$LocalTablesTableUpdateCompanionBuilder,
      (
        LocalTable,
        BaseReferences<_$AppDatabase, $LocalTablesTable, LocalTable>,
      ),
      LocalTable,
      PrefetchHooks Function()
    >;
typedef $$LocalMenuCategoriesTableCreateCompanionBuilder =
    LocalMenuCategoriesCompanion Function({
      required String id,
      required String restaurantId,
      required String name,
      Value<int> rowid,
    });
typedef $$LocalMenuCategoriesTableUpdateCompanionBuilder =
    LocalMenuCategoriesCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> name,
      Value<int> rowid,
    });

class $$LocalMenuCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMenuCategoriesTable> {
  $$LocalMenuCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMenuCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMenuCategoriesTable> {
  $$LocalMenuCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMenuCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMenuCategoriesTable> {
  $$LocalMenuCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$LocalMenuCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMenuCategoriesTable,
          LocalMenuCategory,
          $$LocalMenuCategoriesTableFilterComposer,
          $$LocalMenuCategoriesTableOrderingComposer,
          $$LocalMenuCategoriesTableAnnotationComposer,
          $$LocalMenuCategoriesTableCreateCompanionBuilder,
          $$LocalMenuCategoriesTableUpdateCompanionBuilder,
          (
            LocalMenuCategory,
            BaseReferences<
              _$AppDatabase,
              $LocalMenuCategoriesTable,
              LocalMenuCategory
            >,
          ),
          LocalMenuCategory,
          PrefetchHooks Function()
        > {
  $$LocalMenuCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalMenuCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMenuCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMenuCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalMenuCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuCategoriesCompanion(
                id: id,
                restaurantId: restaurantId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuCategoriesCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMenuCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMenuCategoriesTable,
      LocalMenuCategory,
      $$LocalMenuCategoriesTableFilterComposer,
      $$LocalMenuCategoriesTableOrderingComposer,
      $$LocalMenuCategoriesTableAnnotationComposer,
      $$LocalMenuCategoriesTableCreateCompanionBuilder,
      $$LocalMenuCategoriesTableUpdateCompanionBuilder,
      (
        LocalMenuCategory,
        BaseReferences<
          _$AppDatabase,
          $LocalMenuCategoriesTable,
          LocalMenuCategory
        >,
      ),
      LocalMenuCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalMenuItemsTableCreateCompanionBuilder =
    LocalMenuItemsCompanion Function({
      required String id,
      required String restaurantId,
      required String categoryId,
      required String name,
      Value<String?> description,
      required double price,
      Value<double> costPrice,
      Value<int> stockQuantity,
      Value<String?> imageUrl,
      Value<bool> isDeal,
      Value<int> rowid,
    });
typedef $$LocalMenuItemsTableUpdateCompanionBuilder =
    LocalMenuItemsCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> categoryId,
      Value<String> name,
      Value<String?> description,
      Value<double> price,
      Value<double> costPrice,
      Value<int> stockQuantity,
      Value<String?> imageUrl,
      Value<bool> isDeal,
      Value<int> rowid,
    });

class $$LocalMenuItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMenuItemsTable> {
  $$LocalMenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeal => $composableBuilder(
    column: $table.isDeal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMenuItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMenuItemsTable> {
  $$LocalMenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeal => $composableBuilder(
    column: $table.isDeal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMenuItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMenuItemsTable> {
  $$LocalMenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isDeal =>
      $composableBuilder(column: $table.isDeal, builder: (column) => column);
}

class $$LocalMenuItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMenuItemsTable,
          LocalMenuItem,
          $$LocalMenuItemsTableFilterComposer,
          $$LocalMenuItemsTableOrderingComposer,
          $$LocalMenuItemsTableAnnotationComposer,
          $$LocalMenuItemsTableCreateCompanionBuilder,
          $$LocalMenuItemsTableUpdateCompanionBuilder,
          (
            LocalMenuItem,
            BaseReferences<_$AppDatabase, $LocalMenuItemsTable, LocalMenuItem>,
          ),
          LocalMenuItem,
          PrefetchHooks Function()
        > {
  $$LocalMenuItemsTableTableManager(
    _$AppDatabase db,
    $LocalMenuItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMenuItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isDeal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuItemsCompanion(
                id: id,
                restaurantId: restaurantId,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                costPrice: costPrice,
                stockQuantity: stockQuantity,
                imageUrl: imageUrl,
                isDeal: isDeal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String categoryId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double price,
                Value<double> costPrice = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isDeal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuItemsCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                costPrice: costPrice,
                stockQuantity: stockQuantity,
                imageUrl: imageUrl,
                isDeal: isDeal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMenuItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMenuItemsTable,
      LocalMenuItem,
      $$LocalMenuItemsTableFilterComposer,
      $$LocalMenuItemsTableOrderingComposer,
      $$LocalMenuItemsTableAnnotationComposer,
      $$LocalMenuItemsTableCreateCompanionBuilder,
      $$LocalMenuItemsTableUpdateCompanionBuilder,
      (
        LocalMenuItem,
        BaseReferences<_$AppDatabase, $LocalMenuItemsTable, LocalMenuItem>,
      ),
      LocalMenuItem,
      PrefetchHooks Function()
    >;
typedef $$LocalIngredientsTableCreateCompanionBuilder =
    LocalIngredientsCompanion Function({
      required String id,
      required String restaurantId,
      required String name,
      required double quantity,
      required String unit,
      Value<int> rowid,
    });
typedef $$LocalIngredientsTableUpdateCompanionBuilder =
    LocalIngredientsCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> name,
      Value<double> quantity,
      Value<String> unit,
      Value<int> rowid,
    });

class $$LocalIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);
}

class $$LocalIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIngredientsTable,
          LocalIngredient,
          $$LocalIngredientsTableFilterComposer,
          $$LocalIngredientsTableOrderingComposer,
          $$LocalIngredientsTableAnnotationComposer,
          $$LocalIngredientsTableCreateCompanionBuilder,
          $$LocalIngredientsTableUpdateCompanionBuilder,
          (
            LocalIngredient,
            BaseReferences<
              _$AppDatabase,
              $LocalIngredientsTable,
              LocalIngredient
            >,
          ),
          LocalIngredient,
          PrefetchHooks Function()
        > {
  $$LocalIngredientsTableTableManager(
    _$AppDatabase db,
    $LocalIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIngredientsCompanion(
                id: id,
                restaurantId: restaurantId,
                name: name,
                quantity: quantity,
                unit: unit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String name,
                required double quantity,
                required String unit,
                Value<int> rowid = const Value.absent(),
              }) => LocalIngredientsCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                name: name,
                quantity: quantity,
                unit: unit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIngredientsTable,
      LocalIngredient,
      $$LocalIngredientsTableFilterComposer,
      $$LocalIngredientsTableOrderingComposer,
      $$LocalIngredientsTableAnnotationComposer,
      $$LocalIngredientsTableCreateCompanionBuilder,
      $$LocalIngredientsTableUpdateCompanionBuilder,
      (
        LocalIngredient,
        BaseReferences<_$AppDatabase, $LocalIngredientsTable, LocalIngredient>,
      ),
      LocalIngredient,
      PrefetchHooks Function()
    >;
typedef $$LocalMenuItemIngredientsTableCreateCompanionBuilder =
    LocalMenuItemIngredientsCompanion Function({
      required String menuItemId,
      required String ingredientId,
      required double quantityNeeded,
      Value<int> rowid,
    });
typedef $$LocalMenuItemIngredientsTableUpdateCompanionBuilder =
    LocalMenuItemIngredientsCompanion Function({
      Value<String> menuItemId,
      Value<String> ingredientId,
      Value<double> quantityNeeded,
      Value<int> rowid,
    });

class $$LocalMenuItemIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMenuItemIngredientsTable> {
  $$LocalMenuItemIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMenuItemIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMenuItemIngredientsTable> {
  $$LocalMenuItemIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMenuItemIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMenuItemIngredientsTable> {
  $$LocalMenuItemIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantityNeeded => $composableBuilder(
    column: $table.quantityNeeded,
    builder: (column) => column,
  );
}

class $$LocalMenuItemIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMenuItemIngredientsTable,
          LocalMenuItemIngredient,
          $$LocalMenuItemIngredientsTableFilterComposer,
          $$LocalMenuItemIngredientsTableOrderingComposer,
          $$LocalMenuItemIngredientsTableAnnotationComposer,
          $$LocalMenuItemIngredientsTableCreateCompanionBuilder,
          $$LocalMenuItemIngredientsTableUpdateCompanionBuilder,
          (
            LocalMenuItemIngredient,
            BaseReferences<
              _$AppDatabase,
              $LocalMenuItemIngredientsTable,
              LocalMenuItemIngredient
            >,
          ),
          LocalMenuItemIngredient,
          PrefetchHooks Function()
        > {
  $$LocalMenuItemIngredientsTableTableManager(
    _$AppDatabase db,
    $LocalMenuItemIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMenuItemIngredientsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalMenuItemIngredientsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalMenuItemIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> menuItemId = const Value.absent(),
                Value<String> ingredientId = const Value.absent(),
                Value<double> quantityNeeded = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuItemIngredientsCompanion(
                menuItemId: menuItemId,
                ingredientId: ingredientId,
                quantityNeeded: quantityNeeded,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String menuItemId,
                required String ingredientId,
                required double quantityNeeded,
                Value<int> rowid = const Value.absent(),
              }) => LocalMenuItemIngredientsCompanion.insert(
                menuItemId: menuItemId,
                ingredientId: ingredientId,
                quantityNeeded: quantityNeeded,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMenuItemIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMenuItemIngredientsTable,
      LocalMenuItemIngredient,
      $$LocalMenuItemIngredientsTableFilterComposer,
      $$LocalMenuItemIngredientsTableOrderingComposer,
      $$LocalMenuItemIngredientsTableAnnotationComposer,
      $$LocalMenuItemIngredientsTableCreateCompanionBuilder,
      $$LocalMenuItemIngredientsTableUpdateCompanionBuilder,
      (
        LocalMenuItemIngredient,
        BaseReferences<
          _$AppDatabase,
          $LocalMenuItemIngredientsTable,
          LocalMenuItemIngredient
        >,
      ),
      LocalMenuItemIngredient,
      PrefetchHooks Function()
    >;
typedef $$LocalDealItemsTableCreateCompanionBuilder =
    LocalDealItemsCompanion Function({
      required String dealItemId,
      required String childItemId,
      Value<int> quantity,
      Value<int> rowid,
    });
typedef $$LocalDealItemsTableUpdateCompanionBuilder =
    LocalDealItemsCompanion Function({
      Value<String> dealItemId,
      Value<String> childItemId,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$LocalDealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDealItemsTable> {
  $$LocalDealItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dealItemId => $composableBuilder(
    column: $table.dealItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childItemId => $composableBuilder(
    column: $table.childItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDealItemsTable> {
  $$LocalDealItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dealItemId => $composableBuilder(
    column: $table.dealItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childItemId => $composableBuilder(
    column: $table.childItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDealItemsTable> {
  $$LocalDealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dealItemId => $composableBuilder(
    column: $table.dealItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childItemId => $composableBuilder(
    column: $table.childItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$LocalDealItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDealItemsTable,
          LocalDealItem,
          $$LocalDealItemsTableFilterComposer,
          $$LocalDealItemsTableOrderingComposer,
          $$LocalDealItemsTableAnnotationComposer,
          $$LocalDealItemsTableCreateCompanionBuilder,
          $$LocalDealItemsTableUpdateCompanionBuilder,
          (
            LocalDealItem,
            BaseReferences<_$AppDatabase, $LocalDealItemsTable, LocalDealItem>,
          ),
          LocalDealItem,
          PrefetchHooks Function()
        > {
  $$LocalDealItemsTableTableManager(
    _$AppDatabase db,
    $LocalDealItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dealItemId = const Value.absent(),
                Value<String> childItemId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDealItemsCompanion(
                dealItemId: dealItemId,
                childItemId: childItemId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dealItemId,
                required String childItemId,
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDealItemsCompanion.insert(
                dealItemId: dealItemId,
                childItemId: childItemId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDealItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDealItemsTable,
      LocalDealItem,
      $$LocalDealItemsTableFilterComposer,
      $$LocalDealItemsTableOrderingComposer,
      $$LocalDealItemsTableAnnotationComposer,
      $$LocalDealItemsTableCreateCompanionBuilder,
      $$LocalDealItemsTableUpdateCompanionBuilder,
      (
        LocalDealItem,
        BaseReferences<_$AppDatabase, $LocalDealItemsTable, LocalDealItem>,
      ),
      LocalDealItem,
      PrefetchHooks Function()
    >;
typedef $$LocalOrdersTableCreateCompanionBuilder =
    LocalOrdersCompanion Function({
      required String id,
      required String restaurantId,
      Value<String?> tableId,
      required String userId,
      required String orderType,
      required String status,
      required String paymentStatus,
      Value<String?> paymentMethod,
      required double subtotal,
      required double tax,
      Value<double> discount,
      Value<double> deliveryFee,
      required double total,
      Value<String?> customerName,
      Value<String?> customerPhone,
      Value<String?> deliveryAddress,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int?> billNumber,
      Value<int> rowid,
    });
typedef $$LocalOrdersTableUpdateCompanionBuilder =
    LocalOrdersCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String?> tableId,
      Value<String> userId,
      Value<String> orderType,
      Value<String> status,
      Value<String> paymentStatus,
      Value<String?> paymentMethod,
      Value<double> subtotal,
      Value<double> tax,
      Value<double> discount,
      Value<double> deliveryFee,
      Value<double> total,
      Value<String?> customerName,
      Value<String?> customerPhone,
      Value<String?> deliveryAddress,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int?> billNumber,
      Value<int> rowid,
    });

class $$LocalOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOrdersTable> {
  $$LocalOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOrdersTable> {
  $$LocalOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableId => $composableBuilder(
    column: $table.tableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderType => $composableBuilder(
    column: $table.orderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discount => $composableBuilder(
    column: $table.discount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOrdersTable> {
  $$LocalOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tableId =>
      $composableBuilder(column: $table.tableId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get orderType =>
      $composableBuilder(column: $table.orderType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryAddress => $composableBuilder(
    column: $table.deliveryAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get billNumber => $composableBuilder(
    column: $table.billNumber,
    builder: (column) => column,
  );
}

class $$LocalOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOrdersTable,
          LocalOrder,
          $$LocalOrdersTableFilterComposer,
          $$LocalOrdersTableOrderingComposer,
          $$LocalOrdersTableAnnotationComposer,
          $$LocalOrdersTableCreateCompanionBuilder,
          $$LocalOrdersTableUpdateCompanionBuilder,
          (
            LocalOrder,
            BaseReferences<_$AppDatabase, $LocalOrdersTable, LocalOrder>,
          ),
          LocalOrder,
          PrefetchHooks Function()
        > {
  $$LocalOrdersTableTableManager(_$AppDatabase db, $LocalOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String?> tableId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> orderType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tax = const Value.absent(),
                Value<double> discount = const Value.absent(),
                Value<double> deliveryFee = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> deliveryAddress = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> billNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrdersCompanion(
                id: id,
                restaurantId: restaurantId,
                tableId: tableId,
                userId: userId,
                orderType: orderType,
                status: status,
                paymentStatus: paymentStatus,
                paymentMethod: paymentMethod,
                subtotal: subtotal,
                tax: tax,
                discount: discount,
                deliveryFee: deliveryFee,
                total: total,
                customerName: customerName,
                customerPhone: customerPhone,
                deliveryAddress: deliveryAddress,
                notes: notes,
                createdAt: createdAt,
                billNumber: billNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                Value<String?> tableId = const Value.absent(),
                required String userId,
                required String orderType,
                required String status,
                required String paymentStatus,
                Value<String?> paymentMethod = const Value.absent(),
                required double subtotal,
                required double tax,
                Value<double> discount = const Value.absent(),
                Value<double> deliveryFee = const Value.absent(),
                required double total,
                Value<String?> customerName = const Value.absent(),
                Value<String?> customerPhone = const Value.absent(),
                Value<String?> deliveryAddress = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int?> billNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrdersCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                tableId: tableId,
                userId: userId,
                orderType: orderType,
                status: status,
                paymentStatus: paymentStatus,
                paymentMethod: paymentMethod,
                subtotal: subtotal,
                tax: tax,
                discount: discount,
                deliveryFee: deliveryFee,
                total: total,
                customerName: customerName,
                customerPhone: customerPhone,
                deliveryAddress: deliveryAddress,
                notes: notes,
                createdAt: createdAt,
                billNumber: billNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOrdersTable,
      LocalOrder,
      $$LocalOrdersTableFilterComposer,
      $$LocalOrdersTableOrderingComposer,
      $$LocalOrdersTableAnnotationComposer,
      $$LocalOrdersTableCreateCompanionBuilder,
      $$LocalOrdersTableUpdateCompanionBuilder,
      (
        LocalOrder,
        BaseReferences<_$AppDatabase, $LocalOrdersTable, LocalOrder>,
      ),
      LocalOrder,
      PrefetchHooks Function()
    >;
typedef $$LocalOrderItemsTableCreateCompanionBuilder =
    LocalOrderItemsCompanion Function({
      required String id,
      required String orderId,
      required String menuItemId,
      required int quantity,
      required double price,
      Value<double> costPrice,
      Value<int> rowid,
    });
typedef $$LocalOrderItemsTableUpdateCompanionBuilder =
    LocalOrderItemsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String> menuItemId,
      Value<int> quantity,
      Value<double> price,
      Value<double> costPrice,
      Value<int> rowid,
    });

class $$LocalOrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOrderItemsTable> {
  $$LocalOrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalOrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOrderItemsTable> {
  $$LocalOrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalOrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOrderItemsTable> {
  $$LocalOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);
}

class $$LocalOrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalOrderItemsTable,
          LocalOrderItem,
          $$LocalOrderItemsTableFilterComposer,
          $$LocalOrderItemsTableOrderingComposer,
          $$LocalOrderItemsTableAnnotationComposer,
          $$LocalOrderItemsTableCreateCompanionBuilder,
          $$LocalOrderItemsTableUpdateCompanionBuilder,
          (
            LocalOrderItem,
            BaseReferences<
              _$AppDatabase,
              $LocalOrderItemsTable,
              LocalOrderItem
            >,
          ),
          LocalOrderItem,
          PrefetchHooks Function()
        > {
  $$LocalOrderItemsTableTableManager(
    _$AppDatabase db,
    $LocalOrderItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> menuItemId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrderItemsCompanion(
                id: id,
                orderId: orderId,
                menuItemId: menuItemId,
                quantity: quantity,
                price: price,
                costPrice: costPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String menuItemId,
                required int quantity,
                required double price,
                Value<double> costPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalOrderItemsCompanion.insert(
                id: id,
                orderId: orderId,
                menuItemId: menuItemId,
                quantity: quantity,
                price: price,
                costPrice: costPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalOrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalOrderItemsTable,
      LocalOrderItem,
      $$LocalOrderItemsTableFilterComposer,
      $$LocalOrderItemsTableOrderingComposer,
      $$LocalOrderItemsTableAnnotationComposer,
      $$LocalOrderItemsTableCreateCompanionBuilder,
      $$LocalOrderItemsTableUpdateCompanionBuilder,
      (
        LocalOrderItem,
        BaseReferences<_$AppDatabase, $LocalOrderItemsTable, LocalOrderItem>,
      ),
      LocalOrderItem,
      PrefetchHooks Function()
    >;
typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String id,
      required String restaurantId,
      required String name,
      required double amount,
      required String category,
      required DateTime date,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> name,
      Value<double> amount,
      Value<String> category,
      Value<DateTime> date,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExpensesTable,
          LocalExpense,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpense,
            BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
          ),
          LocalExpense,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(_$AppDatabase db, $LocalExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                id: id,
                restaurantId: restaurantId,
                name: name,
                amount: amount,
                category: category,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String name,
                required double amount,
                required String category,
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                name: name,
                amount: amount,
                category: category,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExpensesTable,
      LocalExpense,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpense,
        BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
      ),
      LocalExpense,
      PrefetchHooks Function()
    >;
typedef $$LocalInventoryLogsTableCreateCompanionBuilder =
    LocalInventoryLogsCompanion Function({
      required String id,
      required String restaurantId,
      required String itemName,
      required double quantity,
      required String unit,
      required double cost,
      required DateTime date,
      Value<int> rowid,
    });
typedef $$LocalInventoryLogsTableUpdateCompanionBuilder =
    LocalInventoryLogsCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> itemName,
      Value<double> quantity,
      Value<String> unit,
      Value<double> cost,
      Value<DateTime> date,
      Value<int> rowid,
    });

class $$LocalInventoryLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInventoryLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemName => $composableBuilder(
    column: $table.itemName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInventoryLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemName =>
      $composableBuilder(column: $table.itemName, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$LocalInventoryLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInventoryLogsTable,
          LocalInventoryLog,
          $$LocalInventoryLogsTableFilterComposer,
          $$LocalInventoryLogsTableOrderingComposer,
          $$LocalInventoryLogsTableAnnotationComposer,
          $$LocalInventoryLogsTableCreateCompanionBuilder,
          $$LocalInventoryLogsTableUpdateCompanionBuilder,
          (
            LocalInventoryLog,
            BaseReferences<
              _$AppDatabase,
              $LocalInventoryLogsTable,
              LocalInventoryLog
            >,
          ),
          LocalInventoryLog,
          PrefetchHooks Function()
        > {
  $$LocalInventoryLogsTableTableManager(
    _$AppDatabase db,
    $LocalInventoryLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInventoryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInventoryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInventoryLogsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> itemName = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryLogsCompanion(
                id: id,
                restaurantId: restaurantId,
                itemName: itemName,
                quantity: quantity,
                unit: unit,
                cost: cost,
                date: date,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String itemName,
                required double quantity,
                required String unit,
                required double cost,
                required DateTime date,
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryLogsCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                itemName: itemName,
                quantity: quantity,
                unit: unit,
                cost: cost,
                date: date,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInventoryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInventoryLogsTable,
      LocalInventoryLog,
      $$LocalInventoryLogsTableFilterComposer,
      $$LocalInventoryLogsTableOrderingComposer,
      $$LocalInventoryLogsTableAnnotationComposer,
      $$LocalInventoryLogsTableCreateCompanionBuilder,
      $$LocalInventoryLogsTableUpdateCompanionBuilder,
      (
        LocalInventoryLog,
        BaseReferences<
          _$AppDatabase,
          $LocalInventoryLogsTable,
          LocalInventoryLog
        >,
      ),
      LocalInventoryLog,
      PrefetchHooks Function()
    >;
typedef $$OfflineQueuesTableCreateCompanionBuilder =
    OfflineQueuesCompanion Function({
      Value<int> id,
      required String actionType,
      required String tableTarget,
      required String recordId,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$OfflineQueuesTableUpdateCompanionBuilder =
    OfflineQueuesCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> tableTarget,
      Value<String> recordId,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$OfflineQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableTarget => $composableBuilder(
    column: $table.tableTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfflineQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableTarget => $composableBuilder(
    column: $table.tableTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfflineQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineQueuesTable> {
  $$OfflineQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tableTarget => $composableBuilder(
    column: $table.tableTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OfflineQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfflineQueuesTable,
          OfflineQueue,
          $$OfflineQueuesTableFilterComposer,
          $$OfflineQueuesTableOrderingComposer,
          $$OfflineQueuesTableAnnotationComposer,
          $$OfflineQueuesTableCreateCompanionBuilder,
          $$OfflineQueuesTableUpdateCompanionBuilder,
          (
            OfflineQueue,
            BaseReferences<_$AppDatabase, $OfflineQueuesTable, OfflineQueue>,
          ),
          OfflineQueue,
          PrefetchHooks Function()
        > {
  $$OfflineQueuesTableTableManager(_$AppDatabase db, $OfflineQueuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> tableTarget = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OfflineQueuesCompanion(
                id: id,
                actionType: actionType,
                tableTarget: tableTarget,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String tableTarget,
                required String recordId,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => OfflineQueuesCompanion.insert(
                id: id,
                actionType: actionType,
                tableTarget: tableTarget,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfflineQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfflineQueuesTable,
      OfflineQueue,
      $$OfflineQueuesTableFilterComposer,
      $$OfflineQueuesTableOrderingComposer,
      $$OfflineQueuesTableAnnotationComposer,
      $$OfflineQueuesTableCreateCompanionBuilder,
      $$OfflineQueuesTableUpdateCompanionBuilder,
      (
        OfflineQueue,
        BaseReferences<_$AppDatabase, $OfflineQueuesTable, OfflineQueue>,
      ),
      OfflineQueue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalRestaurantsTableTableManager get localRestaurants =>
      $$LocalRestaurantsTableTableManager(_db, _db.localRestaurants);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalTablesTableTableManager get localTables =>
      $$LocalTablesTableTableManager(_db, _db.localTables);
  $$LocalMenuCategoriesTableTableManager get localMenuCategories =>
      $$LocalMenuCategoriesTableTableManager(_db, _db.localMenuCategories);
  $$LocalMenuItemsTableTableManager get localMenuItems =>
      $$LocalMenuItemsTableTableManager(_db, _db.localMenuItems);
  $$LocalIngredientsTableTableManager get localIngredients =>
      $$LocalIngredientsTableTableManager(_db, _db.localIngredients);
  $$LocalMenuItemIngredientsTableTableManager get localMenuItemIngredients =>
      $$LocalMenuItemIngredientsTableTableManager(
        _db,
        _db.localMenuItemIngredients,
      );
  $$LocalDealItemsTableTableManager get localDealItems =>
      $$LocalDealItemsTableTableManager(_db, _db.localDealItems);
  $$LocalOrdersTableTableManager get localOrders =>
      $$LocalOrdersTableTableManager(_db, _db.localOrders);
  $$LocalOrderItemsTableTableManager get localOrderItems =>
      $$LocalOrderItemsTableTableManager(_db, _db.localOrderItems);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
  $$LocalInventoryLogsTableTableManager get localInventoryLogs =>
      $$LocalInventoryLogsTableTableManager(_db, _db.localInventoryLogs);
  $$OfflineQueuesTableTableManager get offlineQueues =>
      $$OfflineQueuesTableTableManager(_db, _db.offlineQueues);
}
