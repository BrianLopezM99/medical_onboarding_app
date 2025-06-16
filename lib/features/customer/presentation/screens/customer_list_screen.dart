import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/customer_entity.dart';
import '../customer_controller.dart';
import 'customer_form_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _searchTerm = '';
  CustomerStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // 🔍 Search bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search by name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 8),
                // 🔽 Dropdown
                DropdownButtonFormField<CustomerStatus?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filter by status',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All statuses'),
                    ),
                    ...CustomerStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // 📋 List customers
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final filtered = customers.where((c) {
                  final fullName = '${c.firstName} ${c.lastName}'.toLowerCase();
                  final matchesSearch = fullName.contains(_searchTerm);
                  final matchesStatus =
                      _selectedStatus == null || c.status == _selectedStatus;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching customers'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];
                    return ListTile(
                      title: Text('${customer.firstName} ${customer.lastName}'),
                      subtitle: Text(customer.email),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                '${customer.firstName} ${customer.lastName}',
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: [
                                    Text('Email: ${customer.email}'),
                                    Text('Phone: ${customer.phone}'),
                                    Text(
                                      'DOB: ${customer.dateOfBirth.toLocal().toString().split(' ')[0]}',
                                    ),
                                    if (customer.medicalRecordNumber != null)
                                      Text(
                                        'Medical Record #: ${customer.medicalRecordNumber}',
                                      ),
                                    Text('Status: ${customer.status.name}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CustomerDetailScreen(
                                          customer: customer,
                                        ),
                                      ),
                                    ).then(
                                      (_) => ref
                                          .read(
                                            customerControllerProvider.notifier,
                                          )
                                          .loadCustomers(),
                                    );
                                  },
                                  child: const Text('Edit'),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CustomerDetailScreen(customer: customer),
                                ),
                              ).then(
                                (_) => ref
                                    .read(customerControllerProvider.notifier)
                                    .loadCustomers(),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Customer'),
                                  content: Text(
                                    'Are you sure you want to delete ${customer.firstName} ${customer.lastName}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await ref
                                    .read(customerControllerProvider.notifier)
                                    .deleteCustomer(customer.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
          );
          ref.read(customerControllerProvider.notifier).loadCustomers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
