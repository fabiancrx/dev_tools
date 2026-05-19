import 'package:dash_tools/tools/registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommandPalette extends StatefulWidget {
  final List<ToolDescriptor> allTools;
  final Set<String> hiddenIds;
  final void Function(String toolId) onSelect;

  const CommandPalette({
    super.key,
    required this.allTools,
    required this.hiddenIds,
    required this.onSelect,
  });

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _tec = TextEditingController();
  final _scrollController = ScrollController();
  late List<ToolDescriptor> _results;
  int _cursor = 0;

  static const _itemHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _results = widget.allTools;
    _tec.addListener(_onQuery);
  }

  @override
  void dispose() {
    _tec.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQuery() {
    final q = _tec.text.toLowerCase().trim();
    setState(() {
      _cursor = 0;
      _results = q.isEmpty
          ? widget.allTools
          : widget.allTools.where((t) {
              if (t.name(context).toLowerCase().contains(q)) return true;
              if (t.category.displayName.toLowerCase().contains(q)) return true;
              return t.aliases.any((a) => a.toLowerCase().contains(q));
            }).toList();
    });
  }

  void _moveCursor(int delta) {
    if (_results.isEmpty) return;
    setState(() {
      _cursor = (_cursor + delta).clamp(0, _results.length - 1);
    });
    final offset = _cursor * _itemHeight;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  void _selectCurrent() {
    if (_results.isEmpty) return;
    widget.onSelect(_results[_cursor].id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchField(
              controller: _tec,
              onUp: () => _moveCursor(-1),
              onDown: () => _moveCursor(1),
              onEnter: _selectCurrent,
            ),
            const Divider(height: 1),
            Flexible(
              child: _results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No tools match'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _results.length,
                      itemExtent: _itemHeight,
                      itemBuilder: (context, index) {
                        final tool = _results[index];
                        final isHidden = widget.hiddenIds.contains(tool.id);
                        final selected = index == _cursor;
                        return _ResultTile(
                          tool: tool,
                          isHidden: isHidden,
                          selected: selected,
                          onTap: () => widget.onSelect(tool.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onEnter;

  const _SearchField({
    required this.controller,
    required this.onUp,
    required this.onDown,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) onUp();
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) onDown();
        if (event.logicalKey == LogicalKeyboardKey.enter) onEnter();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tools…',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final ToolDescriptor tool;
  final bool isHidden;
  final bool selected;
  final VoidCallback onTap;

  const _ResultTile({
    required this.tool,
    required this.isHidden,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: ColoredBox(
        color: selected ? colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(tool.icon, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool.name(context),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      tool.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isHidden)
                Tooltip(
                  message: 'Hidden — will be shown when opened',
                  child: Icon(Icons.visibility_off_outlined,
                      size: 16, color: Theme.of(context).disabledColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
