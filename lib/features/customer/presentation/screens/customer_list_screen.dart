import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/core/colors.dart';
import 'package:medical_onboarding_app/features/messaging/presentation/pages/message_screen.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final nameColWidth = width * 0.3;
    final emailColWidth = width * 0.3;
    final actionsColWidth = width * 0.2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: ColorsCore.greenOne,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextButton.icon(
              icon: const Icon(
                Icons.group_add_outlined,
                color: ColorsCore.whiteCustom,
              ),
              label: const Text(
                'Add',
                style: TextStyle(fontSize: 18, color: ColorsCore.whiteCustom),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
                );
                ref.read(customerControllerProvider.notifier).loadCustomers();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: SizedBox(
              width: 200,
              child: DropdownButtonFormField<CustomerStatus?>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...CustomerStatus.values.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
            ),
          ),
          // Search bar
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchTerm = value),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: customersAsync.when(
        data: (customers) {
          final filtered = customers.where((c) {
            final fullName = '${c.firstName} ${c.lastName}'.toLowerCase();
            final matchesSearch = fullName.contains(_searchTerm.toLowerCase());
            final matchesStatus =
                _selectedStatus == null || c.status == _selectedStatus;
            return matchesSearch && matchesStatus;
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No matching customers'));
          }

          return Container(
            decoration: BoxDecoration(color: ColorsCore.whiteCustom),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: double.infinity),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                          (states) => ColorsCore.greenTwo,
                        ),
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: nameColWidth,
                              child: Text(
                                'Name',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: emailColWidth,
                              child: Text(
                                'Email',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: actionsColWidth,
                              child: Center(
                                child: Text(
                                  'Actions',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: filtered.map((customer) {
                          final name =
                              '${customer.firstName} ${customer.lastName}';
                          return DataRow(
                            cells: [
                              DataCell(SizedBox(width: 400, child: Text(name))),
                              DataCell(
                                SizedBox(
                                  width: 400,
                                  child: Text(customer.email),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 400,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
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
                                                      Text(
                                                        'Email: ${customer.email}',
                                                      ),
                                                      Text(
                                                        'Phone: ${customer.phone}',
                                                      ),
                                                      Text(
                                                        'DOB: ${customer.dateOfBirth.toLocal().toString().split(' ')[0]}',
                                                      ),
                                                      if (customer
                                                              .medicalRecordNumber !=
                                                          null)
                                                        Text(
                                                          'Medical Record #: ${customer.medicalRecordNumber}',
                                                        ),
                                                      Text(
                                                        'Status: ${customer.status.name}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Close'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              CustomerDetailScreen(
                                                                customer:
                                                                    customer,
                                                              ),
                                                        ),
                                                      ).then(
                                                        (_) => ref
                                                            .read(
                                                              customerControllerProvider
                                                                  .notifier,
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
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.chat),
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                insetPadding:
                                                    const EdgeInsets.all(24),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  child: SizedBox(
                                                    width: 700,
                                                    height: 800,
                                                    child: MessageScreen(
                                                      isAi: false,
                                                      customerId: customer.id,
                                                      customerName: name,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                insetPadding:
                                                    EdgeInsets.symmetric(
                                                      vertical: height * 0.20,
                                                    ),
                                                child: SizedBox(
                                                  width: 500,
                                                  child: CustomerDetailScreen(
                                                    customer: customer,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          ref
                                              .read(
                                                customerControllerProvider
                                                    .notifier,
                                              )
                                              .loadCustomers();
                                        },
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Delete Customer',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete $name?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            await ref
                                                .read(
                                                  customerControllerProvider
                                                      .notifier,
                                                )
                                                .deleteCustomer(customer.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
