import 'package:dash_tools/common/app_settings.dart';
import 'package:dash_tools/common/tool_order.dart';
import 'package:dash_tools/tools/registry.dart';
import 'package:dash_tools/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class ReorderScreen extends StatelessWidget {
  final ToolOrderNotifier notifier;

  const ReorderScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: YaruDetailPage(
        appBar: const YaruWindowTitleBar(
          title: TabBar(
            tabs: [
              Tab(text: 'Organize'),
              Tab(text: 'Show / Hide'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrganizeTab(notifier: notifier),
            _ShowHideTab(notifier: notifier),
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
      ),
    );
  }
}

class _OrganizeTab extends StatelessWidget {
  final ToolOrderNotifier notifier;
  const _OrganizeTab({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final tools = notifier.tools;
        return ReorderableListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tools.length,
          onReorder: notifier.reorder,
          itemBuilder: (context, index) {
            final tool = tools[index];
            final hidden = notifier.isHidden(tool.id);
            return ListTile(
              key: ValueKey(tool.id),
              leading: Icon(tool.icon,
                  color: hidden ? Theme.of(context).disabledColor : null),
              title: Text(
                tool.name(context),
                style: hidden
                    ? TextStyle(color: Theme.of(context).disabledColor)
                    : null,
              ),
              subtitle: Text(
                tool.category.displayName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.drag_handle),
            );
          },
        );
      },
    );
  }
}

class _ShowHideTab extends StatelessWidget {
  final ToolOrderNotifier notifier;
  const _ShowHideTab({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final byCategory = <ToolCategory, List<ToolDescriptor>>{};
    for (final cat in ToolCategory.values) {
      byCategory[cat] = toolRegistry.where((t) => t.category == cat).toList();
    }

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            for (final cat in ToolCategory.values)
              if ((byCategory[cat] ?? []).isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    cat.displayName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                for (final tool in byCategory[cat] ?? [])
                  SwitchListTile(
                    secondary: Icon(tool.icon),
                    title: Text(tool.name(context)),
                    value: !notifier.isHidden(tool.id),
                    onChanged: (_) => notifier.toggleHidden(tool.id),
                  ),
              ],
          ],
        );
      },
    );
  }
}
