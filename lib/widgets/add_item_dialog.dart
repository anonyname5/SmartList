import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  const AddItemDialog({
    required this.projectId,
    this.item,
    super.key,
  });

  final int projectId;
  final Item? item;

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price.toStringAsFixed(2) ?? '',
    );
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _targetDate = widget.item?.targetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    if (widget.item == null) {
      await ref.read(itemActionsProvider).add(
            projectId: widget.projectId,
            name: _nameController.text,
            price: double.parse(_priceController.text.trim()),
            category: _categoryController.text,
            targetDate: _targetDate,
          );
    } else {
      await ref.read(itemActionsProvider).update(
            item: widget.item!,
            name: _nameController.text,
            price: double.parse(_priceController.text.trim()),
            category: _categoryController.text,
            targetDate: _targetDate,
          );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final initial = _targetDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: Item.validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Item.validatePrice,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category (Optional)'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _targetDate == null
                      ? 'Target Date: Not set'
                      : 'Target Date: ${DateFormat.yMMMd().format(_targetDate!)}',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _saving ? null : _pickTargetDate,
                    child: const Text('Pick Date'),
                  ),
                  if (_targetDate != null)
                    TextButton(
                      onPressed: _saving ? null : () => setState(() => _targetDate = null),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.item == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
