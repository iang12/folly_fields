import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_function.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/crud/abstract_route.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields/folly_fields.dart';
import 'package:folly_fields/util/safe_builder.dart';
import 'package:folly_fields/widgets/circular_waiting.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';
import 'package:folly_fields/widgets/folly_divider.dart';
import 'package:folly_fields/widgets/map_function_button.dart';
import 'package:folly_fields/widgets/model_function_button.dart';
import 'package:folly_fields/widgets/text_message.dart';
import 'package:folly_fields/widgets/waiting_message.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sprintf/sprintf.dart';

///
///
///
abstract class AbstractList<
    T extends AbstractModel<Object>,
    UI extends AbstractUIBuilder<T>,
    C extends AbstractConsumer<T>> extends AbstractRoute {
  final bool selection;
  final bool multipleSelection;
  final bool invertSelection;
  final bool forceOffline;
  final C consumer;
  final UI uiBuilder;
  final Future<Widget?> Function(
    BuildContext context,
    UI uiBuilder,
    C consumer,
  )? onAdd;
  final Future<Widget?> Function(
    BuildContext context,
    T model,
    UI uiBuilder,
    C consumer,
    bool edit,
  )? onUpdate;
  final Map<String, String> qsParam;
  final int itemsPerPage;
  final int qtdSuggestions;
  final List<AbstractMapFunction>? mapFunctions;
  final Future<Widget?> Function(
    BuildContext context,
    T model,
    UI uiBuilder,
    C consumer,
    bool edit,
  )? onLongPress;
  final List<AbstractModelFunction<T>>? modelFunctions;
  final String? searchFieldLabel;
  final TextStyle? searchFieldStyle;
  final InputDecorationTheme? searchFieldDecorationTheme;
  final TextInputType? searchKeyboardType;
  final TextInputAction searchTextInputAction;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final int minLengthToSearch;
  final String hintText;
  final String selectionText;
  final String startSearchText;
  final String deleteText;
  final String invertSelectionText;
  final String waitingText;
  final String deleteErrorText;
  final String searchListEmpty;
  final String addText;
  final String searchText;
  final String listEmpty;

  ///
  ///
  ///
  static const TextStyle suggestionStyle = TextStyle(
    fontStyle: FontStyle.italic,
  );

  ///
  ///
  ///
  const AbstractList({
    required this.selection,
    required this.multipleSelection,
    required this.consumer,
    required this.uiBuilder,
    this.invertSelection = false,
    this.forceOffline = false,
    this.onAdd,
    this.onUpdate,
    this.qsParam = const <String, String>{},
    this.itemsPerPage = 50,
    this.qtdSuggestions = 15,
    this.mapFunctions,
    this.onLongPress,
    this.modelFunctions,
    this.searchFieldLabel,
    this.searchFieldStyle,
    this.searchFieldDecorationTheme,
    this.searchKeyboardType,
    this.searchTextInputAction = TextInputAction.search,
    this.selectedIcon = FontAwesomeIcons.solidCheckCircle,
    this.unselectedIcon = FontAwesomeIcons.circle,
    this.minLengthToSearch = 3,
    this.hintText = 'Sugestões:',
    this.selectionText = 'Selecionar %s',
    this.startSearchText = 'Começe a sua pesquisa.\n'
        'Digite ao menos %s caracteres.',
    this.deleteText = 'Deseja excluir?',
    this.invertSelectionText = 'Inverter seleção',
    this.waitingText = 'Consultando...',
    this.deleteErrorText = 'Ocorreu um erro ao tentar excluir:\n%s',
    this.searchListEmpty = 'Nenhum documento.',
    this.addText = 'Adicionar %s',
    this.searchText = 'Pesquisar %s',
    this.listEmpty = 'Sem %s até o momento.',
    Key? key,
  })  : assert(searchFieldStyle == null || searchFieldDecorationTheme == null,
            'searchFieldStyle or searchFieldDecorationTheme must be null.'),
        super(key: key);

  ///
  ///
  ///
  @override
  List<String> get routeName => consumer.routeName;

  ///
  ///
  ///
  bool canDelete(T model) => true;

  ///
  ///
  ///
  @override
  AbstractListState<T, UI, C> createState() => AbstractListState<T, UI, C>();
}

///
///
///
class AbstractListState<
    T extends AbstractModel<Object>,
    UI extends AbstractUIBuilder<T>,
    C extends AbstractConsumer<T>> extends State<AbstractList<T, UI, C>> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final ScrollController _scrollController = ScrollController();
  final StreamController<bool?> _streamController = StreamController<bool?>();

  List<T> _globalItems = <T>[];
  bool _loading = false;
  int _page = 0;

  bool _insert = false;
  bool _update = false;
  bool _delete = false;

  Map<Object, T> selections = <Object, T>{};

  final Map<String, String> _qsParam = <String, String>{};

  final Map<ConsumerPermission, AbstractMapFunction> effectiveMapFunctions =
      <ConsumerPermission, AbstractMapFunction>{};

  final Map<ConsumerPermission, AbstractModelFunction<T>>
      effectiveModelFunctions =
      <ConsumerPermission, AbstractModelFunction<T>>{};

  FocusNode keyboardFocusNode = FocusNode();

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();

    if (widget.qsParam.isNotEmpty) {
      _qsParam.addAll(widget.qsParam);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (!_loading && _page >= 0) {
          _loadData(context, clear: false);
        }
      }
    });

    _loadPermissions(context);
  }

  ///
  ///
  ///
  Future<void> _loadPermissions(BuildContext context) async {
    if (widget.mapFunctions != null) {
      for (AbstractMapFunction headerFunction in widget.mapFunctions!) {
        ConsumerPermission permission = await widget.consumer
            .checkPermission(context, headerFunction.routeName);

        if (permission.view) {
          effectiveMapFunctions[permission] = headerFunction;
        }
      }
    }

    if (widget.modelFunctions != null) {
      for (AbstractModelFunction<T> rowFunction in widget.modelFunctions!) {
        ConsumerPermission permission = await widget.consumer
            .checkPermission(context, rowFunction.routeName);

        if (permission.view) {
          effectiveModelFunctions[permission] = rowFunction;
        }
      }
    }

    await _loadData(context);
  }

  ///
  ///
  ///
  Future<void> _loadData(
    BuildContext context, {
    bool clear = true,
  }) async {
    if (clear) {
      _globalItems = <T>[];
      _page = 0;
      _streamController.add(null);
    } else {
      _loading = true;
      _streamController.add(false);
    }

    try {
      if (!widget.selection) {
        ConsumerPermission permission =
            await widget.consumer.checkPermission(context, <String>[]);

        _insert = permission.insert && widget.onAdd != null;
        _update = permission.update && widget.onUpdate != null;
        _delete = permission.delete;
      }

      _qsParam['f'] = '${_page * widget.itemsPerPage}';
      _qsParam['q'] = '${widget.itemsPerPage}';
      _qsParam['s'] = '${widget.selection}';

      List<T> result = await widget.consumer.list(
        context,
        _qsParam,
        widget.forceOffline,
      );

      if (result.isEmpty) {
        _page = -1;
      } else {
        _page++;
        _globalItems.addAll(result);
      }

      _streamController.add(true);
      _loading = false;
    } catch (e, s) {
      if (kDebugMode) {
        print('$e\n$s');
      }
      _streamController.addError(e, s);
    }
  }

  ///
  ///
  ///
  Widget _getScaffoldTitle() => Text(
        widget.selection
            ? sprintf(
                widget.selectionText,
                <dynamic>[widget.uiBuilder.superSingle],
              )
            : widget.uiBuilder.superPlural,
      );

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool?>(
      stream: _streamController.stream,
      builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: _getScaffoldTitle(),
            ),
            bottomNavigationBar:
                widget.uiBuilder.buildBottomNavigationBar(context),
            body: widget.uiBuilder.buildBackgroundContainer(
              context,
              Column(
                children: <Widget>[
                  Scrollbar(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: () => _loadData(context),
                      child: TextMessage(snapshot.error.toString()),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          /// CircularProgressIndicator at list final.
          int itemCount = _globalItems.length;
          if (!snapshot.data!) {
            itemCount++;
          }

          Widget? _fabAdd;

          List<Widget> _actions = <Widget>[];

          /// Botão Selecionar Todos
          if (widget.selection == true &&
              widget.multipleSelection == true &&
              widget.invertSelection == true) {
            _actions.add(
              IconButton(
                tooltip: widget.invertSelectionText,
                icon: const Icon(Icons.select_all),
                onPressed: () {
                  for (T model in _globalItems) {
                    if (selections.containsKey(model.id)) {
                      selections.remove(model.id);
                    } else {
                      selections[model.id!] = model;
                    }
                  }
                  setState(() {});
                },
              ),
            );
          }

          /// Search Button
          if (FollyFields().isOnline) {
            _actions.add(
              IconButton(
                tooltip: sprintf(
                  widget.searchText,
                  <dynamic>[widget.uiBuilder.superSingle],
                ),
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
            );
          }

          /// Selection Confirm Button
          if (widget.selection) {
            if (widget.multipleSelection) {
              _actions.add(
                IconButton(
                  tooltip: sprintf(
                    widget.selectionText,
                    <dynamic>[widget.uiBuilder.superPlural],
                  ),
                  icon: const FaIcon(FontAwesomeIcons.check),
                  onPressed: () => Navigator.of(context)
                      .pop(List<T>.from(selections.values)),
                ),
              );
            }
          } else {
            /// Action Routes
            for (MapEntry<ConsumerPermission, AbstractMapFunction> entry
                in effectiveMapFunctions.entries) {
              _actions.add(
                MapFunctionButton(
                  mapFunction: entry.value,
                  permission: entry.key,
                  qsParam: _qsParam,
                  selection: widget.selection,
                  callback: (Map<String, String> map) {
                    _qsParam.addAll(map);
                    _loadData(context);
                  },
                ),
              );
            }

            /// Add Button
            if (_insert) {
              if (FollyFields().isWeb) {
                _actions.add(
                  IconButton(
                    tooltip: sprintf(
                      widget.addText,
                      <dynamic>[widget.uiBuilder.superSingle],
                    ),
                    icon: const FaIcon(FontAwesomeIcons.plus),
                    onPressed: _addEntity,
                  ),
                );
              } else {
                _fabAdd = FloatingActionButton(
                  tooltip: sprintf(
                    widget.addText,
                    <dynamic>[widget.uiBuilder.superSingle],
                  ),
                  onPressed: _addEntity,
                  child: const FaIcon(FontAwesomeIcons.plus),
                );
              }
            }

            /// Legend Button
            if (widget.uiBuilder.listLegend.isNotEmpty) {
              _actions.add(
                IconButton(
                  tooltip: widget.uiBuilder.listLegendTitle,
                  icon: FaIcon(widget.uiBuilder.listLegendIcon),
                  onPressed: _showListLegend,
                ),
              );
            }
          }

          return Scaffold(
            appBar: AppBar(
              title: _getScaffoldTitle(),
              actions: _actions,
            ),
            bottomNavigationBar:
                widget.uiBuilder.buildBottomNavigationBar(context),
            body: widget.uiBuilder.buildBackgroundContainer(
              context,
              RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => _loadData(context),
                child: _globalItems.isEmpty
                    ? TextMessage(
                        sprintf(
                          widget.listEmpty,
                          <dynamic>[widget.uiBuilder.superPlural.toLowerCase()],
                        ),
                      )
                    : RawKeyboardListener(
                        autofocus: true,
                        focusNode: keyboardFocusNode,
                        onKey: (RawKeyEvent event) {
                          if (event.character != null) {
                            _search(event.character);
                          }
                        },
                        child: Scrollbar(
                          controller: _scrollController,
                          isAlwaysShown: FollyFields().isWeb,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              /// Updating...
                              if (index >= _globalItems.length) {
                                return const SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              T model = _globalItems[index];

                              if (_delete &&
                                  FollyFields().isMobile &&
                                  widget.canDelete(model)) {
                                return Dismissible(
                                  key: Key('key_${model.id}'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    child: const FaIcon(
                                      FontAwesomeIcons.trashAlt,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss:
                                      (DismissDirection direction) =>
                                          _askDelete(),
                                  onDismissed: (DismissDirection direction) =>
                                      _deleteEntity(model),
                                  child: _buildResultItem(
                                    model: model,
                                    selection: selections.containsKey(model.id),
                                    canDelete: false,
                                  ),
                                );
                              } else {
                                return _buildResultItem(
                                  model: model,
                                  selection: selections.containsKey(model.id),
                                  canDelete: _delete &&
                                      FollyFields().isWeb &&
                                      widget.canDelete(model),
                                );
                              }
                            },
                            separatorBuilder: (_, __) => const FollyDivider(),
                            itemCount: itemCount,
                          ),
                        ),
                      ),
              ),
            ),
            floatingActionButton: _fabAdd,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: _getScaffoldTitle(),
          ),
          bottomNavigationBar:
              widget.uiBuilder.buildBottomNavigationBar(context),
          body: widget.uiBuilder.buildBackgroundContainer(
            context,
            WaitingMessage(message: widget.waitingText),
          ),
        );
      },
    );
  }

  ///
  ///
  ///
  void _search([String? query]) {
    showSearch<T?>(
      context: context,
      query: query,
      delegate: InternalSearch<T, UI, C>(
        buildResultItem: _buildResultItem,
        canDelete: (T model) =>
            _delete && FollyFields().isWeb && widget.canDelete(model),
        qsParam: widget.qsParam,
        forceOffline: widget.forceOffline,
        itemsPerPage: widget.itemsPerPage,
        uiBuilder: widget.uiBuilder,
        consumer: widget.consumer,
        searchFieldLabel: widget.searchFieldLabel,
        searchFieldStyle: widget.searchFieldStyle,
        searchFieldDecorationTheme: widget.searchFieldDecorationTheme,
        keyboardType: widget.searchKeyboardType,
        textInputAction: widget.searchTextInputAction,
        minLengthToSearch: widget.minLengthToSearch,
        hintText: widget.hintText,
        startSearchText: widget.startSearchText,
        waitingText: widget.waitingText,
        searchListEmpty: widget.searchListEmpty,
      ),
    ).then(
      (T? entity) {
        if (entity != null) {
          _internalRoute(
            entity,
            !selections.containsKey(entity.id),
          );
        }
      },
    );
  }

  ///
  ///
  ///
  Widget _buildResultItem({
    required T model,
    required bool selection,
    required bool canDelete,
    Future<void> Function()? afterDeleteRefresh,
    Function(T model)? onTap,
  }) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          widget.multipleSelection && onTap == null
              ? FaIcon(selection ? widget.selectedIcon : widget.unselectedIcon)
              : widget.uiBuilder.getLeading(model),
        ],
      ),
      title: widget.uiBuilder.getTitle(model),
      subtitle: widget.uiBuilder.getSubtitle(model),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          /// Item Buttons
          ...effectiveModelFunctions.entries.map(
            (
              MapEntry<ConsumerPermission, AbstractModelFunction<T>> entry,
            ) =>
                ModelFunctionButton<T>(
              rowFunction: entry.value,
              permission: entry.key,
              model: model,
              selection: widget.selection,
              qsParam: _qsParam,
              callback: (Object? object) => _loadData(context),
            ),
          ),

          /// Delete Button
          if (canDelete)
            IconButton(
              icon: const Icon(FontAwesomeIcons.trashAlt),
              onPressed: () async {
                bool refresh = await _deleteEntity(model, ask: true);
                if (afterDeleteRefresh != null && refresh) {
                  await afterDeleteRefresh();
                }
              },
            ),
        ],
      ),
      onTap: onTap != null
          ? () => onTap(model)
          : () => _internalRoute(model, !selection),
      onLongPress:
          widget.onLongPress == null ? null : () => _internalLongPress(model),
    );
  }

  ///
  ///
  ///
  Future<void> _internalLongPress(T model) async => _push(
        await widget.onLongPress!(
          context,
          model,
          widget.uiBuilder,
          widget.consumer,
          _update,
        ),
      );

  ///
  ///
  ///
  Future<void> _addEntity() async => _push(
        await widget.onAdd!(
          context,
          widget.uiBuilder,
          widget.consumer,
        ),
      );

  ///
  ///
  ///
  Future<void> _internalRoute(T model, bool selected) async {
    if (widget.selection) {
      if (widget.multipleSelection) {
        if (selected) {
          selections[model.id!] = model;
        } else {
          selections.remove(model.id);
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        Navigator.of(context).pop(model);
      }
    } else {
      Widget? next = await widget.onUpdate!(
        context,
        model,
        widget.uiBuilder,
        widget.consumer,
        _update,
      );

      await _push(next);
    }
  }

  ///
  ///
  ///
  Future<void> _push(Widget? widget, [bool clear = true]) async {
    if (widget != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<T>(builder: (_) => widget),
      );

      await _loadData(context, clear: clear);
    }
  }

  ///
  ///
  ///
  Future<bool> _deleteEntity(T model, {bool ask = false}) async {
    CircularWaiting wait = CircularWaiting(context);
    try {
      bool del = true;

      if (ask) {
        del = await _askDelete();
      }

      if (del) {
        del = await widget.consumer.beforeDelete(context, model);
      }

      if (del) {
        wait.show();
        await widget.consumer.delete(context, model);
        wait.close();

        if (ask) {
          await _loadData(context);
        }

        return ask;
      }
    } catch (e, s) {
      wait.close();

      if (kDebugMode) {
        print('$e\n$s');
      }

      await FollyDialogs.dialogMessage(
        context: context,
        message: sprintf(widget.deleteErrorText, <dynamic>[e.toString()]),
      );
    }
    return !ask;
  }

  ///
  ///
  ///
  Future<bool> _askDelete() => FollyDialogs.yesNoDialog(
        context: context,
        message: widget.deleteText,
      );

  ///
  ///
  ///
  void _showListLegend() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: <Widget>[
            FaIcon(widget.uiBuilder.listLegendIcon),
            const SizedBox(
              width: 8,
            ),
            Text(widget.uiBuilder.listLegendTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: widget.uiBuilder.listLegend.keys
                .map(
                  (String key) => ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.solidCircle,
                      color: widget.uiBuilder.listLegend[key],
                    ),
                    title: Text(key),
                  ),
                )
                .toList(),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(widget.uiBuilder.listLegendButtonText),
          ),
        ],
      ),
    );
  }

  ///
  ///
  ///
  @override
  void dispose() {
    keyboardFocusNode.dispose();
    super.dispose();
  }
}

///
///
///
class InternalSearch<
    W extends AbstractModel<Object>,
    UI extends AbstractUIBuilder<W>,
    C extends AbstractConsumer<W>> extends SearchDelegate<W?> {
  final UI uiBuilder;
  final C consumer;

  final Widget Function({
    required W model,
    required bool selection,
    required bool canDelete,
    Future<void> Function()? afterDeleteRefresh,
    Function(W model)? onTap,
  }) buildResultItem;

  final bool Function(W) canDelete;
  final Map<String, String> qsParam;
  final bool forceOffline;
  final int itemsPerPage;
  final int minLengthToSearch;
  final String hintText;
  final String startSearchText;
  final String waitingText;
  final String searchListEmpty;

  String? _lastQuery;
  Widget? _lastWidget;

  ///
  ///
  ///
  InternalSearch({
    required this.uiBuilder,
    required this.consumer,
    required this.buildResultItem,
    required this.canDelete,
    required this.qsParam,
    required this.forceOffline,
    required this.itemsPerPage,
    required this.minLengthToSearch,
    required this.hintText,
    required this.startSearchText,
    required this.waitingText,
    required this.searchListEmpty,
    required String? searchFieldLabel,
    required TextStyle? searchFieldStyle,
    required InputDecorationTheme? searchFieldDecorationTheme,
    required TextInputType? keyboardType,
    required TextInputAction textInputAction,
  }) : super(
          searchFieldLabel: searchFieldLabel,
          searchFieldStyle: searchFieldStyle,
          searchFieldDecorationTheme: searchFieldDecorationTheme,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
        );

  ///
  ///
  ///
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = super.appBarTheme(context);

    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }

  ///
  ///
  ///
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  ///
  ///
  ///
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  ///
  ///
  ///
  @override
  Widget buildResults(BuildContext context) {
    if (query.length < minLengthToSearch) {
      return Column(
        children: <Widget>[
          Expanded(
            child: uiBuilder.buildBackgroundContainer(
              context,
              Center(
                child: Text(
                  sprintf(startSearchText, <dynamic>[minLengthToSearch]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          uiBuilder.buildBottomNavigationBar(context),
        ],
      );
    } else {
      Map<String, String> param = <String, String>{};

      if (qsParam.isNotEmpty) {
        param.addAll(qsParam);
      }

      if (query.contains('%')) {
        query = query.replaceAll('%', '');
      }

      param['t'] = query;

      return Column(
        children: <Widget>[
          Expanded(
            child: uiBuilder.buildBackgroundContainer(
              context,
              SafeFutureBuilder<List<W>>(
                future: consumer.list(context, param, forceOffline),
                waitingMessage: waitingText,
                builder: (BuildContext context, List<W> data) => data.isNotEmpty
                    ? ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (BuildContext context, int index) =>
                            buildResultItem(
                          model: data[index],
                          selection: false,
                          canDelete: canDelete(data[index]),
                          onTap: (W entity) => close(context, entity),
                          afterDeleteRefresh: () async => query += '%',
                        ),
                        separatorBuilder: (_, __) => const FollyDivider(),
                        itemCount: data.length,
                      )
                    : Center(child: Text(searchListEmpty)),
              ),
            ),
          ),
          uiBuilder.buildBottomNavigationBar(context),
        ],
      );
    }
  }

  ///
  ///
  ///
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < minLengthToSearch) {
      return Column(
        children: <Widget>[
          Expanded(
            child: uiBuilder.buildBackgroundContainer(
              context,
              Center(
                child: Text(
                  sprintf(startSearchText, <dynamic>[minLengthToSearch]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          uiBuilder.buildBottomNavigationBar(context),
        ],
      );
    } else {
      if (_lastQuery == query && _lastWidget != null) {
        return _lastWidget!;
      } else {
        Map<String, String> param = <String, String>{};

        _lastQuery = query;

        if (qsParam.isNotEmpty) {
          param.addAll(qsParam);
        }

        param['t'] = query.replaceAll('%', '');

        param['q'] = itemsPerPage.toString();

        _lastWidget = Column(
          children: <Widget>[
            Expanded(
              child: uiBuilder.buildBackgroundContainer(
                context,
                SafeFutureBuilder<List<W>>(
                  future: consumer.list(context, param, forceOffline),
                  waitingMessage: waitingText,
                  builder: (BuildContext context, List<W> data) => data
                          .isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                hintText,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  W model = data[index];

                                  return ListTile(
                                    title: uiBuilder.getSuggestionTitle(model),
                                    subtitle:
                                        uiBuilder.getSuggestionSubtitle(model),
                                    onTap: () {
                                      _lastQuery = model.listSearchTerm;
                                      query = _lastQuery!;
                                      showResults(context);
                                    },
                                  );
                                },
                                itemCount: data.length,
                              ),
                            ),
                          ],
                        )
                      : Center(child: Text(searchListEmpty)),
                ),
              ),
            ),
            uiBuilder.buildBottomNavigationBar(context),
          ],
        );

        return _lastWidget!;
      }
    }
  }
}
