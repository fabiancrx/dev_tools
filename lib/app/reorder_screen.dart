import 'package:dash_tools/common/tool_order.dart';
import 'package:dash_tools/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class ReorderScreen extends StatelessWidget {
  final ToolOrderNotifier notifier;

  const ReorderScreen({super.key, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return YaruDetailPage(
      appBar: const YaruWindowTitleBar(title: Text('Organize tools')),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: notifier,
              builder: (context, _) {
                final tools = notifier.tools;
                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tools.length,
                  onReorder: notifier.reorder,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return ListTile(
                      key: ValueKey(tool.id),
                      leading: Icon(tool.icon),
                      title: Text(tool.name(context)),
                      subtitle: Text(
                        tool.category.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.drag_handle),
                    );
                  },
                );
              },
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
    );
  }
}
