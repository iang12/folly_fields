import 'package:flutter/material.dart';
import 'package:folly_fields/responsive/responsive.dart';
import 'package:folly_fields/util/decimal.dart';
import 'package:folly_fields/validators/decimal_validator.dart';

///
///
///
class DecimalField extends StatefulResponsive {
  final String labelPrefix;
  final String label;
  final DecimalEditingController? controller;
  final Decimal? initialValue;
  final String? Function(Decimal value)? validator;
  final void Function(Decimal value)? onSaved;
  final TextAlign textAlign;
  final int? maxLength;
  final bool enabled;
  final AutovalidateMode autoValidateMode;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final bool filled;
  final Color? fillColor;
  final void Function(Decimal)? lostFocus;
  final bool readOnly;
  final InputDecoration? decoration;
  final EdgeInsets padding;

  ///
  ///
  ///
  const DecimalField({
    this.labelPrefix = '',
    this.label = '',
    this.controller,
    this.validator,
    this.textAlign = TextAlign.end,
    this.maxLength,
    this.onSaved,
    this.initialValue,
    this.enabled = true,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.scrollPadding = const EdgeInsets.all(20),
    this.enableInteractiveSelection = true,
    this.filled = false,
    this.fillColor,
    this.lostFocus,
    this.readOnly = false,
    this.decoration,
    this.padding = const EdgeInsets.all(8),
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
          sizeExtraSmall: sizeExtraSmall,
          sizeSmall: sizeSmall,
          sizeMedium: sizeMedium,
          sizeLarge: sizeLarge,
          sizeExtraLarge: sizeExtraLarge,
          minHeight: minHeight,
          key: key,
        );

  ///
  ///
  ///
  @override
  DecimalFieldState createState() => DecimalFieldState();
}

///
///
///
class DecimalFieldState extends State<DecimalField> {
  DecimalEditingController? _controller;
  FocusNode? _focusNode;

  ///
  ///
  ///
  DecimalEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  ///
  ///
  ///
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode!;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = DecimalEditingController(widget.initialValue!);
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }

    _effectiveFocusNode.addListener(_handleFocus);
  }

  ///
  ///
  ///
  void _handleFocus() {
    if (_effectiveFocusNode.hasFocus) {
      _effectiveController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _effectiveController.text.length,
      );
    }

    if (!_effectiveFocusNode.hasFocus && widget.lostFocus != null) {
      widget.lostFocus!(_effectiveController.decimal);
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocus);

    if (_controller != null) {
      _controller!.dispose();
    }

    if (_focusNode != null) {
      _focusNode!.dispose();
    }

    super.dispose();
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    final InputDecoration effectiveDecoration = (widget.decoration ??
            InputDecoration(
              border: const OutlineInputBorder(),
              filled: widget.filled,
              fillColor: widget.fillColor,
              labelText: widget.labelPrefix.isEmpty
                  ? widget.label
                  : '${widget.labelPrefix} - ${widget.label}',
              counterText: '',
            ))
        .applyDefaults(Theme.of(context).inputDecorationTheme);

    return Padding(
      padding: widget.padding,
      child: TextFormField(
        controller: _effectiveController,
        decoration: effectiveDecoration,
        validator: (String? value) => widget.enabled && widget.validator != null
            ? widget.validator!(
                _effectiveController.parse(value),
              )
            : null,
        keyboardType: _effectiveController.validator.keyboard,
        minLines: 1,
        inputFormatters: _effectiveController.validator.inputFormatters,
        textAlign: widget.textAlign,
        maxLength: widget.maxLength,
        onSaved: (String? value) => widget.enabled && widget.onSaved != null
            ? widget.onSaved!(_effectiveController.parse(value))
            : null,
        enabled: widget.enabled,
        autovalidateMode: widget.autoValidateMode,
        focusNode: _effectiveFocusNode,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        autocorrect: false,
        enableSuggestions: false,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        readOnly: widget.readOnly,
        style: widget.enabled && !widget.readOnly
            ? null
            : Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
      ),
    );
  }
}

///
///
///
class DecimalEditingController extends TextEditingController {
  final DecimalValidator validator;

  double _lastValue = 0;

  ///
  ///
  ///
  DecimalEditingController(Decimal value)
      : validator = DecimalValidator(value.precision) {
    addListener(_changeListener);
    decimal = value;
  }

  ///
  ///
  ///
  set decimal(Decimal dec) {
    // TODO(edufolly): Remover esse limitador?
    if (dec.doubleValue.toStringAsFixed(0).length > 12) {
      dec.doubleValue = _lastValue;
    } else {
      _lastValue = dec.doubleValue;
    }

    String masked = validator.format(dec);

    if (masked != super.text) {
      super.text = masked;

      int cursorPosition = super.text.length - validator.rightSymbol.length;
      super.selection = TextSelection.fromPosition(
        TextPosition(
          offset: cursorPosition,
        ),
      );
    }
  }

  ///
  ///
  ///
  Decimal get decimal => parse(text);

  ///
  ///
  ///
  void _changeListener() => decimal = decimal;

  ///
  ///
  ///
  Decimal parse(String? text) =>
      validator.parse(text) ?? Decimal(precision: validator.precision);

  ///
  ///
  ///
  set intValue(int intValue) {
    decimal = Decimal(precision: validator.precision, intValue: intValue);
  }

  ///
  ///
  ///
  int get intValue => decimal.intValue;

  ///
  ///
  ///
  set doubleValue(double doubleValue) {
    decimal = Decimal(precision: validator.precision, doubleValue: doubleValue);
  }

  ///
  ///
  ///
  double get doubleValue => decimal.doubleValue;

  ///
  ///
  ///
  @override
  void dispose() {
    removeListener(_changeListener);
    super.dispose();
  }
}
