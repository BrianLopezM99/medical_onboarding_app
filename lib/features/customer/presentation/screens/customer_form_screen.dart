import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/customer/presentation/widgets/customer_form.dart';
import '../customer_controller.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomerForm(
          initialCustomer: null,
          readOnly: false,
          onSubmit: (customer) {
            ref.read(customerControllerProvider.notifier).addCustomer(customer);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
