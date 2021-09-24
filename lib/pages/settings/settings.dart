import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/options_notifier.dart';
import 'package:useful_tools/widgets.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late OptionsNotifier optionsNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    optionsNotifier = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final options = optionsNotifier.options;

    // TODO: 未实现
    // 将所有设置选项移到此处
    return ListViewBuilder(
      itemBuilder: (BuildContext context, int index) {
        return const SizedBox();
      },
      itemCount: 20,
    );
  }
}
