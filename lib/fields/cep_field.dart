import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folly_fields/fields/validator_field.dart';
import 'package:folly_fields/validators/cep_validator.dart';

///
///
///
class CepField extends ValidatorField {
  ///
  ///
  ///
  CepField({
    String validatorMessage = 'Informe o CEP.',
    String labelPrefix = '',
    String label = '',
    TextEditingController? controller,
    String? Function(String value)? validator,
    List<TextInputFormatter>? inputFormatter,
    TextAlign textAlign = TextAlign.start,
    void Function(String)? onSaved,
    String? initialValue,
    bool enabled = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    bool autocorrect = false,
    bool enableSuggestions = true,
    EdgeInsets scrollPadding = const EdgeInsets.all(20),
    bool enableInteractiveSelection = true,
    bool filled = false,
    Color? fillColor,
    bool required = true,
    Iterable<String>? autofillHints,
    TextStyle? style,
    InputDecoration? decoration,
    EdgeInsets padding = const EdgeInsets.all(8),
    int? sizeExtraSmall,
    int? sizeSmall,
    int? sizeMedium,
    int? sizeLarge,
    int? sizeExtraLarge,
    double? minHeight,
    Key? key,
  })  : assert(initialValue == null || controller == null,
            'initialValue or controller must be null.'),
        super(
          abstractValidator: CepValidator(),
          validatorMessage: validatorMessage,
          labelPrefix: labelPrefix,
          label: label,
          controller: controller,
          validator: validator,
          inputFormatter: inputFormatter,
          textAlign: textAlign,
          maxLength: 10,
          onSaved:
              onSaved != null ? (String? value) => onSaved(value ?? '') : null,
          initialValue: initialValue,
          enabled: enabled,
          autoValidateMode: autoValidateMode,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          textCapitalization: TextCapitalization.none,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          filled: filled,
          fillColor: fillColor,
          required: required,
          autofillHints: autofillHints,
          style: style,
          decoration: decoration,
          padding: padding,
          sizeExtraSmall: sizeExtraSmall,
          sizeSmall: sizeSmall,
          sizeMedium: sizeMedium,
          sizeLarge: sizeLarge,
          sizeExtraLarge: sizeExtraLarge,
          minHeight: minHeight,
          key: key,
        );
}
