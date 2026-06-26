import 'package:flutter/material.dart';

class SearchableSelectionField<T> extends StatefulWidget {
  final String labelText;
  final String dialogTitle;
  final List<T> items;
  final T? value;
  final String Function(T item) itemTitle;
  final String? Function(T item)? itemSubtitle;
  final String Function(T item) itemSearchText;
  final ValueChanged<T?> onChanged;
  final String searchHintText;
  final String emptyText;
  final String? Function(T? value)? validator;
  final bool enabled;
  final Widget? suffixIcon;

  const SearchableSelectionField({
    super.key,
    required this.labelText,
    required this.dialogTitle,
    required this.items,
    required this.value,
    required this.itemTitle,
    required this.itemSearchText,
    required this.onChanged,
    this.itemSubtitle,
    this.searchHintText = 'Pesquisar...',
    this.emptyText = 'Nenhum item encontrado.',
    this.validator,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  State<SearchableSelectionField<T>> createState() =>
      _SearchableSelectionFieldState<T>();
}

class _SearchableSelectionFieldState<T>
    extends State<SearchableSelectionField<T>> {
  T? _fieldValue;

  @override
  void initState() {
    super.initState();
    _fieldValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant SearchableSelectionField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _fieldValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: _fieldValue,
      validator: widget.validator,
      builder: (field) {
        if (field.value != _fieldValue) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              field.didChange(_fieldValue);
            }
          });
        }

        final selecionado = _fieldValue;

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.enabled
              ? () async {
                  final resultado = await showSearchableSelection<T>(
                    context: context,
                    title: widget.dialogTitle,
                    items: widget.items,
                    selected: _fieldValue,
                    itemTitle: widget.itemTitle,
                    itemSubtitle: widget.itemSubtitle,
                    itemSearchText: widget.itemSearchText,
                    searchHintText: widget.searchHintText,
                    emptyText: widget.emptyText,
                  );

                  if (resultado == null) return;

                  setState(() {
                    _fieldValue = resultado;
                  });
                  widget.onChanged(resultado);
                  field.didChange(resultado);
                  field.validate();
                }
              : null,
          child: InputDecorator(
            isEmpty: selecionado == null,
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: const OutlineInputBorder(),
              errorText: field.errorText,
              enabled: widget.enabled,
              suffixIcon: widget.suffixIcon ?? const Icon(Icons.search),
            ),
            child: Text(
              selecionado == null ? '' : widget.itemTitle(selecionado),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

Future<T?> showSearchableSelection<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T item) itemTitle,
  required String Function(T item) itemSearchText,
  T? selected,
  String? Function(T item)? itemSubtitle,
  String searchHintText = 'Pesquisar...',
  String emptyText = 'Nenhum item encontrado.',
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      String busca = '';

      return StatefulBuilder(
        builder: (context, setDialogState) {
          final termo = _normalizar(busca);
          final filtrados = termo.isEmpty
              ? items
              : items.where((item) {
                  return _normalizar(itemSearchText(item)).contains(termo);
                }).toList();

          return AlertDialog(
            title: Text(title),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            content: SizedBox(
              width: 560,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: searchHintText,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          busca = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: filtrados.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  emptyText,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtrados.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = filtrados[index];
                                final subtitle = itemSubtitle?.call(item);
                                final isSelected = selected == item;

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    itemTitle(item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle:
                                      subtitle == null ||
                                          subtitle.trim().isEmpty
                                      ? null
                                      : Text(
                                          subtitle,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () =>
                                      Navigator.pop(dialogContext, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _normalizar(String texto) {
  return texto.trim().toLowerCase();
}
