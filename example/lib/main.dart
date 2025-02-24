import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:folly_fields/fields/bool_field.dart';
import 'package:folly_fields/fields/cep_field.dart';
import 'package:folly_fields/fields/cest_field.dart';
import 'package:folly_fields/fields/cnae_field.dart';
import 'package:folly_fields/fields/cnpj_field.dart';
import 'package:folly_fields/fields/color_field.dart';
import 'package:folly_fields/fields/cpf_cnpj_field.dart';
import 'package:folly_fields/fields/cpf_field.dart';
import 'package:folly_fields/fields/date_field.dart';
import 'package:folly_fields/fields/date_time_field.dart';
import 'package:folly_fields/fields/decimal_field.dart';
import 'package:folly_fields/fields/dropdown_field.dart';
import 'package:folly_fields/fields/email_field.dart';
import 'package:folly_fields/fields/icon_data_field.dart';
import 'package:folly_fields/fields/integer_field.dart';
import 'package:folly_fields/fields/list_field.dart';
import 'package:folly_fields/fields/local_phone_field.dart';
import 'package:folly_fields/fields/mac_address_field.dart';
import 'package:folly_fields/fields/model_field.dart';
import 'package:folly_fields/fields/multiline_field.dart';
import 'package:folly_fields/fields/ncm_field.dart';
import 'package:folly_fields/fields/password_field.dart';
import 'package:folly_fields/fields/phone_field.dart';
import 'package:folly_fields/fields/string_field.dart';
import 'package:folly_fields/fields/time_field.dart';
import 'package:folly_fields/folly_fields.dart';
import 'package:folly_fields/util/decimal.dart';
import 'package:folly_fields/util/folly_validators.dart';
import 'package:folly_fields/util/icon_helper.dart';
import 'package:folly_fields/util/safe_builder.dart';
import 'package:folly_fields/widgets/error_message.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';
import 'package:folly_fields_example/advanced/example_builder.dart';
import 'package:folly_fields_example/advanced/example_consumer.dart';
import 'package:folly_fields_example/advanced/example_edit.dart';
import 'package:folly_fields_example/advanced/example_list.dart';
import 'package:folly_fields_example/advanced/example_map_function_route.dart';
import 'package:folly_fields_example/brand_new/brand_new_builder.dart';
import 'package:folly_fields_example/brand_new/brand_new_consumer.dart';
import 'package:folly_fields_example/brand_new/brand_new_edit.dart';
import 'package:folly_fields_example/brand_new/brand_new_model.dart';
import 'package:folly_fields_example/code_link.dart';
import 'package:folly_fields_example/config.dart';
import 'package:folly_fields_example/example_enum.dart';
import 'package:folly_fields_example/example_model.dart';
import 'package:folly_fields_example/example_table.dart';
import 'package:folly_fields_example/views/four_images.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

///
///
///
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FollyFields.start(Config());

  runApp(const MyApp());
}

///
///
///
class MyApp extends StatelessWidget {
  ///
  ///
  ///
  const MyApp({Key? key}) : super(key: key);

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folly Fields Example',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.dark,
        snackBarTheme: ThemeData.dark().snackBarTheme.copyWith(
              backgroundColor: Colors.deepOrange,
              contentTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        toggleableActiveColor: Colors.deepOrange,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const MyHomePage(),
        '/table': (_) => const ExampleTable(),
        '/list': (_) => ExampleList(),
        '/edit': (_) => ExampleEdit(
              ExampleModel.generate(),
              const ExampleBuilder(),
              const ExampleConsumer(),
              true,
            ),
        '/brandnew': (_) => BrandNewEdit(
              BrandNewModel(),
              const BrandNewBuilder(),
              BrandNewConsumer(),
              true,
            ),
        '/four_images': (_) => const FourImages(),
        const ExampleMapFunctionRoute().path: (_) =>
            const ExampleMapFunctionRoute(),
      },
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('pt', 'BR'),
      ],
    );
  }
}

///
///
///
class MyHomePage extends StatefulWidget {
  ///
  ///
  ///
  const MyHomePage({Key? key}) : super(key: key);

  ///
  ///
  ///
  @override
  MyHomePageState createState() => MyHomePageState();
}

///
///
///
class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Prefixo utilizado no label dos campos.
  /// O conteúdo está no arquivo de configurações.
  String labelPrefix = Config().labelPrefix;

  /// Habilita ou desabilita os campos.
  bool edit = true;

  /// Modelo padrão para o exemplo.
  ExampleModel model = ExampleModel.generate();

  /// Para o campo de lista.
  List<ExampleModel> list = <ExampleModel>[];

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo - Folly Fields'),
        actions: <Widget>[
          /// Github
          IconButton(
            icon: const Icon(FontAwesomeIcons.github),
            onPressed: () async {
              const String url = 'https://github.com/edufolly/folly_fields';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                await FollyDialogs.dialogMessage(
                  context: context,
                  message: 'Não foi possível abrir $url',
                );
              }
            },
            tooltip: 'Github',
          ),

          IconButton(
            icon: const Icon(FontAwesomeIcons.image),
            onPressed: () => Navigator.of(context).pushNamed('/four_images'),
            tooltip: 'Quatro Imagens',
          ),

          /// Table
          IconButton(
            icon: const Icon(FontAwesomeIcons.table),
            onPressed: () => Navigator.of(context).pushNamed('/table'),
            tooltip: 'Tabela',
          ),

          /// AbstractList
          IconButton(
            icon: const Icon(FontAwesomeIcons.list),
            onPressed: () => Navigator.of(context).pushNamed('/list'),
            tooltip: 'Lista',
          ),
        ],
      ),
      body: SafeArea(
        child: SafeFutureBuilder<Response>(
          future: get(Uri.parse('https://raw.githubusercontent.com/edufolly'
              '/folly_fields/main/example/lib/main.dart')),
          builder: (BuildContext context, Response response) {
            int statusCode = response.statusCode;
            if (statusCode < 200 || statusCode > 299) {
              return ErrorMessage(error: 'Status code error: $statusCode');
            }

            String code = response.body;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    /// Título
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Formulário Básico',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),

                    // [RootCode]
                    CodeLink(
                      code: code,
                      tag: 'StringField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/string_field.dart',
                      child:
                          // [StringField]
                          StringField(
                        labelPrefix: labelPrefix,
                        label: 'Texto*',
                        enabled: edit,
                        initialValue: model.text,
                        validator: (String value) => value.isEmpty
                            ? 'O campo texto precisa ser informado.'
                            : null,
                        onSaved: (String? value) => model.text = value!,
                      ),
                      // [/StringField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'EmailField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/email_field.dart',
                      child:
                          // [EmailField]
                          EmailField(
                        labelPrefix: labelPrefix,
                        label: 'E-mail*',
                        enabled: edit,
                        initialValue: model.email,
                        onSaved: (String value) => model.email = value,
                      ),
                      // [/EmailField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'PasswordField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/password_field.dart',
                      child:
                          // [PasswordField]
                          PasswordField(
                        labelPrefix: labelPrefix,
                        label: 'Senha*',
                        enabled: edit,
                        validator: (String value) => value.isEmpty
                            ? 'O campo senha precisa ser informado.'
                            : null,
                        onSaved: (String value) => model.password = value,
                      ),
                      // [/PasswordField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'DecimalField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/decimal_field.dart',
                      child:
                          // [DecimalField]
                          DecimalField(
                        labelPrefix: labelPrefix,
                        label: 'Decimal*',
                        enabled: edit,
                        initialValue: model.decimal,
                        onSaved: (Decimal value) => model.decimal = value,
                      ),
                      // [/DecimalField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'IntegerField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/integer_field.dart',
                      child:
                          // [IntegerField]
                          IntegerField(
                        labelPrefix: labelPrefix,
                        label: 'Integer*',
                        enabled: edit,
                        initialValue: model.integer,
                        onSaved: (int? value) => model.integer = value ?? 0,
                      ),
                      // [/IntegerField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'ColorField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/color_field.dart',
                      child:
                          // [ColorField]
                          ColorField(
                        labelPrefix: labelPrefix,
                        label: 'Cor',
                        enabled: edit,
                        initialValue: model.color,
                        validator: FollyValidators.notNull,
                        onSaved: (Color? value) => model.color = value,
                      ),
                      // [/ColorField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CpfField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cpf_field.dart',
                      child:
                          // [CpfField]
                          CpfField(
                        labelPrefix: labelPrefix,
                        label: 'CPF*',
                        enabled: edit,
                        initialValue: model.cpf,
                        onSaved: (String value) => model.cpf = value,
                      ),
                      // [/CpfField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CnpjField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cnpj_field.dart',
                      child:
                          // [CnpjField]
                          CnpjField(
                        labelPrefix: labelPrefix,
                        label: 'CNPJ*',
                        enabled: edit,
                        initialValue: model.cnpj,
                        onSaved: (String value) => model.cnpj = value,
                      ),
                      // [/CnpjField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CpfCnpjField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cpf_cnpj_field.dart',
                      child:
                          // [CpfCnpjField]
                          CpfCnpjField(
                        labelPrefix: labelPrefix,
                        label: 'CPF ou CNPJ*',
                        enabled: edit,
                        initialValue: model.document,
                        onSaved: (String value) => model.document = value,
                      ),
                      // [/CpfCnpjField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'PhoneField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/phone_field.dart',
                      child:
                          // [PhoneField]
                          PhoneField(
                        labelPrefix: labelPrefix,
                        label: 'Telefone*',
                        enabled: edit,
                        initialValue: model.phone,
                        onSaved: (String value) => model.phone = value,
                      ),
                      // [/PhoneField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'LocalPhoneField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/local_phone_field.dart',
                      child:
                          // [LocalPhoneField]
                          LocalPhoneField(
                        labelPrefix: labelPrefix,
                        label: 'Telefone sem DDD*',
                        enabled: edit,
                        initialValue: model.localPhone,
                        onSaved: (String value) => model.localPhone = value,
                      ),
                      // [/LocalPhoneField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'DateTimeField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/date_time_field.dart',
                      child:
                          // [DateTimeField]
                          DateTimeField(
                        labelPrefix: labelPrefix,
                        label: 'Data e Hora*',
                        enabled: edit,
                        initialValue: model.dateTime,
                        validator: (DateTime? value) =>
                            value == null ? 'Informe uma data' : null,
                        onSaved: (DateTime? value) => model.dateTime = value!,
                      ),
                      // [/DateTimeField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'DateField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/date_field.dart',
                      child:
                          // [DateField]
                          DateField(
                        labelPrefix: labelPrefix,
                        label: 'Data*',
                        enabled: edit,
                        initialValue: model.date,
                        onSaved: (DateTime? value) => model.date = value,
                      ),
                      // [/DateField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'TimeField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/time_field.dart',
                      child:
                          // [TimeField]
                          TimeField(
                        labelPrefix: labelPrefix,
                        label: 'Hora*',
                        enabled: edit,
                        initialValue: model.time,
                        onSaved: (TimeOfDay? value) => model.time = value,
                      ),
                      // [/TimeField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'MacAddressField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/mac_address_field.dart',
                      child:
                          // [MacAddressField]
                          MacAddressField(
                        labelPrefix: labelPrefix,
                        label: 'Mac Address*',
                        enabled: edit,
                        initialValue: model.macAddress,
                        onSaved: (String value) => model.macAddress = value,
                      ),
                      // [/MacAddressField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'NcmField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/ncm_field.dart',
                      child:
                          // [NcmField]
                          NcmField(
                        labelPrefix: labelPrefix,
                        label: 'NCM*',
                        enabled: edit,
                        initialValue: model.ncm,
                        onSaved: (String value) => model.ncm = value,
                      ),
                      // [/NcmField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CestField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cest_field.dart',
                      child:
                          // [CestField]
                          CestField(
                        labelPrefix: labelPrefix,
                        label: 'CEST*',
                        enabled: edit,
                        initialValue: model.cest,
                        onSaved: (String value) => model.cest = value,
                      ),
                      // [/CestField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CnaeField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cnae_field.dart',
                      child:
                          // [CnaeField]
                          CnaeField(
                        labelPrefix: labelPrefix,
                        label: 'CNAE*',
                        enabled: edit,
                        initialValue: model.cnae,
                        onSaved: (String value) => model.cnae = value,
                      ),
                      // [/CnaeField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'CepField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/cep_field.dart',
                      child:
                          // [CepField]
                          CepField(
                        labelPrefix: labelPrefix,
                        label: 'CEP*',
                        enabled: edit,
                        initialValue: model.cep,
                        onSaved: (String value) => model.cep = value,
                      ),
                      // [/CepField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'BoolField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/bool_field.dart',
                      child:
                          // [BoolField]
                          BoolField(
                        labelPrefix: labelPrefix,
                        label: 'Campo Boleano',
                        enabled: edit,
                        initialValue: model.active,
                        validator: (bool value) => !value
                            ? 'Para testes, este campo deve ser sempre '
                                'verdadeiro.'
                            : null,
                        onSaved: (bool value) => model.active = value,
                      ),
                      // [/BoolField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'IconDataField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/icon_data_field.dart',
                      child:
                          // [IconDataField]
                          IconDataField(
                        labelPrefix: labelPrefix,
                        label: 'Ícone*',
                        enabled: edit,
                        icons: IconHelper.data,
                        initialValue: model.icon,
                        validator: FollyValidators.notNull,
                        onSaved: (IconData? iconData) => model.icon = iconData,
                      ),
                      // [/IconDataField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'DropdownField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/dropdown_field.dart',
                      child:
                          // [DropdownField]
                          DropdownField<ExampleEnum>(
                        labelPrefix: labelPrefix,
                        label: 'Ordinal',
                        enabled: edit,
                        items: const ExampleEnumParser().items,
                        initialValue: model.ordinal,
                        validator: FollyValidators.notNull,
                        onSaved: (ExampleEnum? value) => model.ordinal = value!,
                      ),
                      // [/DropdownField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'MultilineField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/multiline_field.dart',
                      child:
                          // [MultilineField]
                          MultilineField(
                        labelPrefix: labelPrefix,
                        label: 'Multiline*',
                        enabled: edit,
                        initialValue: model.multiline,
                        validator: FollyValidators.stringNotEmpty,
                        onSaved: (String value) => model.multiline = value,
                        style: GoogleFonts.firaMono(
                          textStyle: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                      // [/MultilineField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'ModelField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/model_field.dart',
                      child:
                          // [ModelField]
                          ModelField<ExampleModel>(
                        labelPrefix: labelPrefix,
                        label: 'Example Model*',
                        enabled: edit,
                        initialValue: ExampleModel.generate(),
                        routeBuilder: (BuildContext context) => ExampleList(
                          labelPrefix: labelPrefix,
                          selection: true,
                        ),
                      ),
                      // [/ModelField]
                    ),

                    CodeLink(
                      code: code,
                      tag: 'ListField',
                      source: 'https://github.com/edufolly/folly_fields/'
                          'blob/main/lib/fields/list_field.dart',
                      child:
                          // [ListField]
                          ListField<ExampleModel, ExampleBuilder>(
                        enabled: edit,
                        initialValue: list,
                        uiBuilder: ExampleBuilder(labelPrefix),
                        routeAddBuilder:
                            (BuildContext context, ExampleBuilder uiBuilder) =>
                                ExampleList(
                          labelPrefix: labelPrefix,
                          selection: true,
                          multipleSelection: true,
                        ),
                      ),
                      // [/ListField]
                    ),
                    // [/RootCode]

                    /// Botão Enviar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('ENVIAR'),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ///
  ///
  ///
  void _send() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (kDebugMode) {
        print(model.toMap());
      }

      FollyDialogs.dialogMessage(
        context: context,
        title: 'Resultado do método toMap()',
        message: model.toMap().toString(),
      );
    }
  }
}
