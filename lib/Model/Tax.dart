// To parse this JSON data, do
//
//     final tax = taxFromJson(jsonString);

import 'dart:convert';

Tax taxFromJson(String str) => Tax.fromJson(json.decode(str));

String taxToJson(Tax data) => json.encode(data.toJson());

class Tax {
  List<CustomerDetail>? customerDetail;
  List<TaxDetail>? taxDetail;

  Tax({
    this.customerDetail,
    this.taxDetail,
  });

  Tax copyWith({
    List<CustomerDetail>? customerDetail,
    List<TaxDetail>? taxDetail,
  }) =>
      Tax(
        customerDetail: customerDetail ?? this.customerDetail,
        taxDetail: taxDetail ?? this.taxDetail,
      );

  factory Tax.fromJson(Map<String, dynamic> json) => Tax(
        customerDetail: json['customer_detail'] == null
            ? []
            : List<CustomerDetail>.from(json['customer_detail']!
                .map((x) => CustomerDetail.fromJson(x))),
        taxDetail: json['tax_detail'] == null
            ? []
            : List<TaxDetail>.from(
                json['tax_detail']!.map((x) => TaxDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'customer_detail': customerDetail == null
            ? []
            : List<dynamic>.from(customerDetail!.map((x) => x.toJson())),
        'tax_detail': taxDetail == null
            ? []
            : List<dynamic>.from(taxDetail!.map((x) => x.toJson())),
      };
}

class CustomerDetail {
  String? id;
  String? codType;

  CustomerDetail({
    this.id,
    this.codType,
  });

  CustomerDetail copyWith({
    String? id,
    String? codType,
  }) =>
      CustomerDetail(
        id: id ?? this.id,
        codType: codType ?? this.codType,
      );

  factory CustomerDetail.fromJson(Map<String, dynamic> json) => CustomerDetail(
        id: json['id'],
        codType: json['cod_type'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cod_type': codType,
      };
}

class TaxDetail {
  String? id;
  String? title;
  String? percentage;
  String? status;

  TaxDetail({
    this.id,
    this.title,
    this.percentage,
    this.status,
  });

  TaxDetail copyWith({
    String? id,
    String? title,
    String? percentage,
    String? status,
  }) =>
      TaxDetail(
        id: id ?? this.id,
        title: title ?? this.title,
        percentage: percentage ?? this.percentage,
        status: status ?? this.status,
      );

  factory TaxDetail.fromJson(Map<String, dynamic> json) => TaxDetail(
        id: json['id'],
        title: json['title'],
        percentage: json['percentage'],
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'percentage': percentage,
        'status': status,
      };
}
