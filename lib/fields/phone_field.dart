import 'package:flutter/material.dart';
import 'package:folly_fields/validators/phone_validator.dart';
import 'package:folly_fields/fields/validator_field.dart';

///
///
///
class PhoneField extends ValidatorField {
  ///
  ///
  ///
  PhoneField({
    Key? key,
    String validatorMessage = 'Informe o telefone.',
    String prefix = '',
    String label = '',
    TextEditingController? controller,
    TextAlign textAlign = TextAlign.start,
    FormFieldSetter<String>? onSaved,
    String? initialValue,
    bool enabled = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    bool filled = false,
    bool required = true,
  }) : super(
          key: key,
          abstractValidator: PhoneValidator(),
          validatorMessage: validatorMessage,
          prefix: prefix,
          label: label,
          controller: controller,
          textAlign: textAlign,
          maxLength: 15,
          onSaved: onSaved,
          initialValue: initialValue,
          enabled: enabled,
          autoValidateMode: autoValidateMode,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          filled: filled,
          required: required,
        );
}
