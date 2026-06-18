import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/update_activity_form_config.dart';
import 'package:flutter_bottom_nav/models/UpdateActivity/updateactivity_loockup_model.dart';

class UpdateActivityFormBuilder extends StatelessWidget {
  final UpdateActivityFormConfig config;

  /// Current values of all dynamic fields.
  final Map<String, dynamic> values;

  /// Text controllers created and disposed by the parent page.
  final Map<String, TextEditingController> controllers;

  /// Dropdown data stored using the field key.
  final Map<String, List<UpdateActivityLookupOption>>
      dropdownOptions;

  /// Field keys whose dropdown data is currently loading.
  final Set<String> loadingDropdownFields;

  /// Called whenever text or dropdown value changes.
  final void Function(
    UpdateActivityFieldConfig field,
    String value,
  ) onValueChanged;

  /// Called when the user taps a date/date-time field.
  final Future<void> Function(
    UpdateActivityFieldConfig field,
  ) onDateFieldTap;

  const UpdateActivityFormBuilder({
    super.key,
    required this.config,
    required this.values,
    required this.controllers,
    required this.dropdownOptions,
    required this.loadingDropdownFields,
    required this.onValueChanged,
    required this.onDateFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleFields = config.fields
        .where((field) => field.isVisible(values))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0;
            index < visibleFields.length;
            index++)
          _buildField(
            context,
            visibleFields[index],
            index,
          ),
      ],
    );
  }

  Widget _buildField(
    BuildContext context,
    UpdateActivityFieldConfig field,
    int index,
  ) {
    final fieldKey = ValueKey(
      '${config.id}_${field.key}_'
      '${field.lookupCode ?? ''}_$index',
    );

    switch (field.type) {
      case UpdateActivityFieldType.dropdown:
        return _buildDropdown(
          field: field,
          fieldKey: fieldKey,
        );

      case UpdateActivityFieldType.date:
      case UpdateActivityFieldType.dateTime:
        return _buildDateField(
          field: field,
          fieldKey: fieldKey,
        );

      case UpdateActivityFieldType.text:
      case UpdateActivityFieldType.multilineText:
      case UpdateActivityFieldType.phone:
      case UpdateActivityFieldType.integer:
      case UpdateActivityFieldType.decimal:
        return _buildTextField(
          field: field,
          fieldKey: fieldKey,
        );
    }
  }

  Widget _buildDropdown({
    required UpdateActivityFieldConfig field,
    required Key fieldKey,
  }) {
    final isLoading =
        loadingDropdownFields.contains(field.key);

    final options =
        dropdownOptions[field.key] ??
        const <UpdateActivityLookupOption>[];

    final selectedValue =
        values[field.key]?.toString().trim() ?? '';

    final valueExists = options.any(
      (option) => option.code == selectedValue,
    );

    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),

        if (isLoading)
          _buildLoadingField()
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              child: DropdownButtonFormField<String>(
                value:
                    valueExists ? selectedValue : null,
                isExpanded: true,
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.code,
                    child: Text(
                      option.description,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: options.isEmpty
                    ? null
                    : (value) {
                        onValueChanged(
                          field,
                          value ?? '',
                        );
                      },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.fromLTRB(
                        12,
                        10,
                        12,
                        10,
                      ),
                  hintText: _hintText(field),
                  hintStyle:
                      const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required UpdateActivityFieldConfig field,
    required Key fieldKey,
  }) {
    final controller = controllers[field.key];

    if (controller == null) {
      return Padding(
        key: fieldKey,
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Controller missing for ${field.key}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final isMultiline =
        field.type ==
        UpdateActivityFieldType.multilineText;

    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: TextField(
              controller: controller,
              keyboardType: _keyboardType(field),
              minLines: isMultiline ? 3 : 1,
              maxLines: isMultiline ? 3 : 1,
              maxLength: field.maxLength,
              inputFormatters:
                  _inputFormatters(field),
              onChanged: (value) {
                onValueChanged(field, value);
              },
              decoration: InputDecoration(
                hintText: _hintText(field),
                counterText: '',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required UpdateActivityFieldConfig field,
    required Key fieldKey,
  }) {
    final controller = controllers[field.key];

    if (controller == null) {
      return Padding(
        key: fieldKey,
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Controller missing for ${field.key}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: TextField(
              controller: controller,
              readOnly: true,
              onTap: () => onDateFieldTap(field),
              decoration: InputDecoration(
                hintText: _hintText(field),
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.all(12),
                suffixIcon: Icon(
                  field.type ==
                          UpdateActivityFieldType
                              .dateTime
                      ? Icons.calendar_month
                      : Icons.calendar_today,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(
    UpdateActivityFieldConfig field,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        field.isRequired
            ? '${field.label} *'
            : field.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildLoadingField() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  String _hintText(
    UpdateActivityFieldConfig field,
  ) {
    if (field.hintText.trim().isNotEmpty) {
      return field.hintText;
    }

    return field.label;
  }

  TextInputType _keyboardType(
    UpdateActivityFieldConfig field,
  ) {
    switch (field.type) {
      case UpdateActivityFieldType.phone:
        return TextInputType.phone;

      case UpdateActivityFieldType.integer:
        return TextInputType.number;

      case UpdateActivityFieldType.decimal:
        return const TextInputType.numberWithOptions(
          decimal: true,
        );

      case UpdateActivityFieldType.multilineText:
        return TextInputType.multiline;

      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _inputFormatters(
    UpdateActivityFieldConfig field,
  ) {
    if (field.digitsOnly ||
        field.type ==
            UpdateActivityFieldType.integer ||
        field.type ==
            UpdateActivityFieldType.phone) {
      return [
        FilteringTextInputFormatter.digitsOnly,
      ];
    }

    if (field.type ==
        UpdateActivityFieldType.decimal) {
      return [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d{0,2}'),
        ),
      ];
    }

    return const [];
  }
}
