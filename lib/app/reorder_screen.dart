import 'dart:io';

import 'package:dash_tools/app/tray.dart';
import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/platform_keys.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:dash_tools/tools/registry.dart';
import 'package:dash_tools/widgets/adaptive_navigation.dart';
import 'package:dash_tools/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class ReorderScreen extends StatelessWidget {
  final ToolOrderNotifier notifier;

  const ReorderScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return YaruDetailPage(
      heroTag: null,
      appBar: YaruWindowTitleBar(
        // On macOS the traffic lights occupy the top-left; push the back
        // button to the right with a spacer, or place it in actions.
        leading: Platform.isMacOS
            ? const SizedBox(width: 72)
            : BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          if (Platform.isMacOS)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
        title: const Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AppearanceSection(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _ShowHidePane(notifier: notifier)),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _OrganizePane(notifier: notifier)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: AppSettings.instance,
            builder: (context, _) => SwitchListTile(
              secondary: const Icon(Icons.bolt_outlined),
              title: const Text('Process as you type'),
              subtitle: const Text('Disable for expensive tools to use Run button instead'),
              value: AppSettings.instance.autoRun,
              onChanged: AppSettings.instance.setAutoRun,
            ),
          ),
          const Divider(height: 1),
          const _ShortcutsSection(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Licenses'),
            onTap: () => showLicensePage(
              context: context,
              applicationIcon: const Padding(
                padding: EdgeInsets.all(8),
                child: AppLogo(),
              ),
              applicationVersion: '0.0.2+2',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appearance (compact + accent) ─────────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final selectedName = AppSettings.instance.accentVariant;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.compress_outlined),
              title: const Text('Compact mode'),
              subtitle: const Text('Reduce spacing and density'),
              value: AppSettings.instance.compactMode,
              onChanged: AppSettings.instance.setCompactMode,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.palette_outlined, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Accent color', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AccentSwatch(
                              label: 'System (follow OS)',
                              selected: selectedName == null,
                              isSystem: true,
                              onTap: () => AppSettings.instance.setAccentVariant(null),
                            ),
                            for (final v in YaruVariant.accents)
                              _AccentSwatch(
                                label: _variantLabel(v.name),
                                color: v.color,
                                selected: selectedName == v.name,
                                onTap: () => AppSettings.instance.setAccentVariant(v.name),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _variantLabel(String name) {
    // 'prussianGreen' → 'Prussian Green', 'adwaitaBlue' → 'Adwaita Blue'
    final spaced = name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)!}');
    return spaced.split(' ').where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }
}

class _AccentSwatch extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final bool isSystem;
  final VoidCallback onTap;

  const _AccentSwatch({
    required this.label,
    this.color,
    required this.selected,
    this.isSystem = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSystem ? null : color,
            gradient: isSystem
                ? const SweepGradient(colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.purple,
                    Colors.red,
                  ])
                : null,
            border: Border.all(
              width: selected ? 2.5 : 1,
              color: selected ? scheme.onSurface : scheme.outline.withValues(alpha: 0.2),
            ),
          ),
          alignment: Alignment.center,
          child: selected
              ? Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

// ── Show / Hide pane ──────────────────────────────────────────────────────────

class _ShowHidePane extends StatelessWidget {
  final ToolOrderNotifier notifier;
  const _ShowHidePane({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byCategory = <ToolCategory, List<ToolDescriptor>>{};
    for (final cat in ToolCategory.values) {
      byCategory[cat] = toolRegistry.where((t) => t.category == cat).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(
            'Visibility',
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: notifier,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final cat in ToolCategory.values)
                    if ((byCategory[cat] ?? []).isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                        child: Text(
                          cat.displayName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      for (final tool in byCategory[cat] ?? [])
                        SwitchListTile(
                          secondary: Icon(tool.icon),
                          title: Text(tool.name(context)),
                          dense: true,
                          value: !notifier.isHidden(tool.id),
                          onChanged: (_) => notifier.toggleHidden(tool.id),
                        ),
                    ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Organize (reorder) pane ───────────────────────────────────────────────────

class _OrganizePane extends StatelessWidget {
  final ToolOrderNotifier notifier;
  const _OrganizePane({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text(
            'Order',
            style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: notifier,
            builder: (context, _) {
              final tools = notifier.tools;
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: tools.length,
                onReorder: notifier.reorder,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  final hidden = notifier.isHidden(tool.id);
                  return ListTile(
                    key: ValueKey(tool.id),
                    dense: true,
                    leading: Icon(tool.icon, color: hidden ? theme.disabledColor : null),
                    title: Text(
                      tool.name(context),
                      style: hidden ? TextStyle(color: theme.disabledColor) : null,
                    ),
                    subtitle: Text(
                      tool.category.displayName,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.drag_handle),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shortcuts section ─────────────────────────────────────────────────────────

class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.keyboard_outlined),
      title: const Text('Keyboard Shortcuts'),
      children: [
        _row(context, 'Open palette', [PlatformKeys.palette, PlatformKeys.paletteAlt]),
        _row(context, 'Run tool', [PlatformKeys.run]),
        if (isTraySupported) _row(context, 'Toggle window (global)', [PlatformKeys.toggleWindow]),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _row(BuildContext context, String label, List<String> shortcuts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 6, 16, 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          for (int i = 0; i < shortcuts.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            ShortcutChip(label: shortcuts[i]),
          ],
        ],
      ),
    );
  }
}
