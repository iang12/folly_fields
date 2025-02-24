import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields_example/example_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
class ExampleBuilder extends AbstractUIBuilder<ExampleModel> {
  ///
  ///
  ///
  const ExampleBuilder([String prefix = '']) : super(prefix);

  ///
  ///
  ///
  @override
  String get single => 'Exemplo';

  ///
  ///
  ///
  @override
  String get plural => 'Exemplos';

  ///
  ///
  ///
  @override
  Widget getLeading(ExampleModel model) => Icon(
        FontAwesomeIcons.solidCircle,
        color: (model.integer).isEven ? Colors.red : Colors.green,
      );

  ///
  ///
  ///
  @override
  Widget getTitle(ExampleModel model) => Text(model.text);

  ///
  ///
  ///
  @override
  Widget getSubtitle(ExampleModel model) => Text(model.email);

  ///
  ///
  ///
  @override
  Map<String, Color> get listLegend => const <String, Color>{
        'Par': Colors.red,
        'Impar': Colors.green,
      };
}
