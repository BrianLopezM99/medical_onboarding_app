import 'dart:convert';
import 'package:medical_onboarding_app/features/customer/data/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApi {
  static const _key = 'customer_data';

  Future<List<CustomerModel>> fetchCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List decoded = json.decode(jsonString);
    return decoded.map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<void> saveCustomers(List<CustomerModel> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(customers.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }
}
