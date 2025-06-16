import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_entity.dart';
import 'package:medical_onboarding_app/features/customer/presentation/customer_controller.dart';
import '../widgets/customer_form.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final Customer customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomerForm(
          initialCustomer: customer,
          onSubmit: (updatedCustomer) {
            ref
                .read(customerControllerProvider.notifier)
                .updateCustomer(updatedCustomer);
            print(
              'Updated Customer: ${updatedCustomer.firstName} ${updatedCustomer.lastName}',
            );
            Navigator.pop(context, updatedCustomer);
          },
        ),
      ),
    );
  }
}
