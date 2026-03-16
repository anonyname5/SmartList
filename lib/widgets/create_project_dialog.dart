import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../providers/project_provider.dart';

class CreateProjectDialog extends ConsumerStatefulWidget {
  const CreateProjectDialog({
    this.project,
    super.key,
  });

  final Project? project;

  @override
  ConsumerState<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _budgetController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _budgetController = TextEditingController(
      text: widget.project?.budget?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final budgetText = _budgetController.text.trim();
    final budget = budgetText.isEmpty ? null : double.tryParse(budgetText);

    if (widget.project == null) {
      await ref.read(projectActionsProvider).create(
            title: _titleController.text,
            budget: budget,
          );
    } else {
      await ref.read(projectActionsProvider).update(
            projectId: widget.project!.id,
            title: _titleController.text,
            budget: budget,
          );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'Create Project' : 'Edit Project'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Project Title'),
              validator: Project.validateTitle,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget (Optional)',
                hintText: 'e.g. 500',
              ),
              validator: Project.validateBudget,
            ),
          ],
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
              : Text(widget.project == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
