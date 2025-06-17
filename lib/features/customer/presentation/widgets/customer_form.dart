import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_onboarding_app/features/customer/domain/customer_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CustomerForm extends StatefulWidget {
  final Customer? initialCustomer;
  final bool readOnly;
  final void Function(Customer)? onSubmit;

  const CustomerForm({
    super.key,
    this.initialCustomer,
    this.readOnly = false,
    this.onSubmit,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController? _medicalRecordController;
  DateTime? _selectedDate;
  CustomerStatus? _status;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;

    _firstNameController = TextEditingController(text: c?.firstName ?? '');
    _lastNameController = TextEditingController(text: c?.lastName ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _medicalRecordController = TextEditingController(
      text: c?.medicalRecordNumber,
    );

    _status = c?.status ?? CustomerStatus.newCustomer;
    _selectedDate = c?.dateOfBirth;
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() &&
        widget.onSubmit != null &&
        _selectedDate != null) {
      final customer = Customer(
        id: widget.initialCustomer?.id ?? const Uuid().v4(),
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        medicalRecordNumber: _medicalRecordController?.text,
        dateOfBirth: _selectedDate!,
        status: _status!,
      );

      widget.onSubmit!(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.readOnly;

    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                  readOnly: isReadOnly,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (RegExp(r'\d').hasMatch(val))
                      return 'Must not contain numbers';
                    return null;
                  },
                  readOnly: isReadOnly,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    if (!RegExp(
                      r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$',
                    ).hasMatch(val)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                  readOnly: isReadOnly,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    if (val.length < 10) return 'At least 10 digits';
                    return null;
                  },
                  readOnly: isReadOnly,
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: isReadOnly ? null : _pickDate,
                child: AbsorbPointer(
                  child: SizedBox(
                    width: 350,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : '',
                      ),
                      validator: (val) =>
                          _selectedDate == null ? 'Select a date' : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 350,
                child: TextFormField(
                  controller: _medicalRecordController,
                  decoration: const InputDecoration(
                    labelText: 'Medical Record Number',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (val.length < 5) return 'Must be at least 5 characters';
                    return null;
                  },
                  readOnly: isReadOnly,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 350,
                child: DropdownButtonFormField<CustomerStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: CustomerStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: isReadOnly
                      ? null
                      : (value) => setState(() => _status = value),
                  validator: (value) =>
                      value == null ? 'Please select a status' : null,
                ),
              ),

              if (!isReadOnly) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: 350,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
