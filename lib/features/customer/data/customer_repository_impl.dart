import 'package:medical_onboarding_app/features/customer/data/customer_model.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_entity.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  static const _storageKey = 'customers';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<Customer>> getAll() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    final models = CustomerModel.decodeList(jsonStr);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Customer> create(Customer customer) async {
    final prefs = await _prefs;
    final current = await getAll();
    final updated = [...current, customer];
    final models = updated.map(CustomerModel.fromEntity).toList();
    await prefs.setString(_storageKey, CustomerModel.encodeList(models));
    return customer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final prefs = await _prefs;
    final current = await getAll();
    final updated = current
        .map((c) => c.id == customer.id ? customer : c)
        .toList();
    final models = updated.map(CustomerModel.fromEntity).toList();
    await prefs.setString(_storageKey, CustomerModel.encodeList(models));
    return customer;
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await _prefs;
    final current = await getAll();
    final updated = current.where((c) => c.id != id).toList();
    final models = updated.map(CustomerModel.fromEntity).toList();
    await prefs.setString(_storageKey, CustomerModel.encodeList(models));
  }
}
