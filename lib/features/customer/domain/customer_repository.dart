import 'customer_entity.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
}
