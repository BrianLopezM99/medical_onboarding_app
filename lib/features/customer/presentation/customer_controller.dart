import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/customer/data/customer_repository_impl.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_entity.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_repository.dart';

class CustomerController extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerRepository repository;

  CustomerController(this.repository) : super(const AsyncLoading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncLoading();
    try {
      final customers = await repository.getAll();
      state = AsyncData(customers);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    await repository.create(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await repository.update(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await repository.delete(id);
    await loadCustomers();
  }
}

final customerControllerProvider =
    StateNotifierProvider<CustomerController, AsyncValue<List<Customer>>>(
      (ref) => CustomerController(CustomerRepositoryImpl()),
    );
