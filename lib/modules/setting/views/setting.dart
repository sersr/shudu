import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nop/router.dart';
import 'package:nop/utils.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:useful_tools/useful_tools.dart';

import '../providers/options_notifier.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late OptionsNotifier optionsNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    optionsNotifier = context.grass();
  }

  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '亮色';
      case ThemeMode.dark:
        return '暗色';
      default:
        return '跟随系统';
    }
  }

  void update(TargetPlatform? d) {
    optionsNotifier.options = ConfigOptions(platform: d);
    Nav.maybePop();
  }

  SnackbarDelegate? handle;

  ColoredBox titleMenu<T>(
      {required String title,
      required T Function(OptionsNotifier) select,
      Widget? Function(T value)? trailingChild,
      required List<Widget> children}) {
    return ColoredBox(
      color: !context.isDarkMode ? Colors.white : Colors.grey.shade900,
      child: ValueListenableBuilder<T>(
        // selector: select,
        valueListenable: optionsNotifier.select(select),
        builder: (context, updateValue, _) {
          return ListTile(
            onTap: () {
              Nav.showDialog(builder: (_) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Material(
                    borderRadius: BorderRadius.circular(5.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
                    ),
                  ),
                ));
              });
            },
            visualDensity: VisualDensity.compact,
            leading: Text(title,
                style: TextStyle(
                    fontSize: 15,
                    color: !context.isDarkMode
                        ? Color.fromARGB(255, 54, 54, 54)
                        : Color.fromARGB(255, 187, 187, 187))),
            trailing: trailingChild?.call(updateValue),
          );
        },
      ),
    );
  }

  Widget selector<T extends ChangeNotifierBase>({
    required String title,
    required bool Function(T) select,
    required void Function(bool updateValue) onChanged,
  }) {
    return ColoredBox(
      color: !context.isDarkMode ? Colors.white : Colors.grey.shade900,
      child: ValueListenableBuilder<bool>(
        // selector: select,
        valueListenable: context.grass<T>().select(select),
        builder: (context, value, _) {
          return SwitchListTile.adaptive(
            visualDensity: VisualDensity.compact,
            title: Text(title,
                style: TextStyle(
                    fontSize: 15,
                    color: !context.isDarkMode
                        ? Color.fromARGB(255, 54, 54, 54)
                        : Color.fromARGB(255, 187, 187, 187)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            value: value,
            onChanged: onChanged,
          );
        },
      ),
    );
  }

  void _onChanged(ThemeMode? updateValue) {
    optionsNotifier.options = ConfigOptions(themeMode: updateValue);
    Nav.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final mode = optionsNotifier
        .select((parent) => parent.options.themeMode ?? ThemeMode.system);

    final line = Divider(
        color: !context.isDarkMode
            ? Colors.grey.shade300
            : Color.fromRGBO(25, 25, 25, 1),
        height: 1.0);

    final children = <Widget>[
      selector<OptionsNotifier>(
          title: 'app启动时刷新列表',
          select: (opt) => opt.options.updateOnStart ?? false,
          onChanged: (tap) {
            optionsNotifier.options = ConfigOptions(updateOnStart: tap);
          }),
      line,
      titleMenu(
          title: '主题配色',
          select: (opt) => opt.options.themeMode ?? ThemeMode.system,
          trailingChild: (ThemeMode updateValue) {
            return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getThemeName(updateValue),
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        leadingDistribution: TextLeadingDistribution.even),
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined)
                ]);
          },
          children: [
            AnimatedBuilder(
                animation: mode,
                builder: (context, child) {
                  return RadioListTile(
                      title: Text('亮色'),
                      value: ThemeMode.light,
                      groupValue: mode.value,
                      onChanged: _onChanged);
                }),
            AnimatedBuilder(
                animation: mode,
                builder: (context, child) {
                  return RadioListTile(
                      title: Text('暗色'),
                      value: ThemeMode.dark,
                      groupValue: mode.value,
                      onChanged: _onChanged);
                }),
            AnimatedBuilder(
                animation: mode,
                builder: (context, child) {
                  return RadioListTile(
                      title: Text('跟随系统'),
                      value: ThemeMode.system,
                      groupValue: mode.value,
                      onChanged: _onChanged);
                })
          ]),
      line,
      selector<OptionsNotifier>(
          title: '指针采样',
          select: (opt) => opt.options.nopResample ?? false,
          onChanged: (updateValue) {
            optionsNotifier.options = ConfigOptions(nopResample: updateValue);
          }),
      if (!kDartIsWeb) line,
      if (!kDartIsWeb)
        selector<OptionsNotifier>(
            title: '显示性能图层',
            select: (opt) => opt.options.showPerformanceOverlay ?? false,
            onChanged: (updateValue) {
              optionsNotifier.options =
                  ConfigOptions(showPerformanceOverlay: updateValue);
            }),
      line,
      selector<OptionsNotifier>(
          title: '使用图片缓存',
          select: (opt) => opt.options.useImageCache ?? false,
          onChanged: (updateValue) {
            optionsNotifier.options = ConfigOptions(useImageCache: updateValue);
          }),
      line,
      selector<OptionsNotifier>(
          title: '使用文本缓存',
          select: (opt) => opt.options.useTextCache ?? false,
          onChanged: (updateValue) {
            optionsNotifier.options = ConfigOptions(useTextCache: updateValue);
          }),
      line,
      titleMenu(
          title: '平台',
          select: (opt) => opt.options.platform ?? defaultTargetPlatform,
          trailingChild: (updateValue) {
            return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    updateValue == TargetPlatform.android ? 'android' : 'ios',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        leadingDistribution: TextLeadingDistribution.even),
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined)
                ]);
          },
          children: [
            ValueListenableBuilder<TargetPlatform>(
                // selector: select,
                valueListenable: context.grass<OptionsNotifier>().select(
                    (opt) => opt.options.platform ?? defaultTargetPlatform),
                builder: (context, updateValue, _) {
                  return RadioListTile(
                    title: Text('android'),
                    value: TargetPlatform.android,
                    onChanged: update,
                    groupValue: updateValue,
                  );
                }),
            ValueListenableBuilder<TargetPlatform>(
                // selector: select,
                valueListenable: optionsNotifier.select(
                    (opt) => opt.options.platform ?? defaultTargetPlatform),
                builder: (context, updateValue, _) {
                  return RadioListTile(
                    title: Text('ios'),
                    value: TargetPlatform.iOS,
                    onChanged: update,
                    groupValue: updateValue,
                  );
                }),
          ]),
      line,
      ColoredBox(
        color: !context.isDarkMode ? Colors.white : Colors.grey.shade900,
        child: ListTile(
          title: Text('外部存储权限请求',
              style: TextStyle(
                  fontSize: 15,
                  color: !context.isDarkMode
                      ? Color.fromARGB(255, 54, 54, 54)
                      : Color.fromARGB(255, 187, 187, 187))),
          trailing: Icon(Icons.keyboard_arrow_right_outlined),
          onTap: () {
            final style = TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 187, 187, 187));
            if (defaultTargetPlatform == TargetPlatform.android)
              Permission.manageExternalStorage.status.then((status) {
                if (status.isDenied) {
                  Log.w('status denied', onlyDebug: false);
                  Permission.manageExternalStorage.request().then((status) {
                    if (status.isDenied) {
                      Log.w('request denied', onlyDebug: false);
                    } else if (status.isGranted && mounted) {
                      Nav.snackBar(Container(
                        color: Color.fromARGB(255, 61, 61, 61),
                        height: 56,
                        child: Center(child: Text('请求成功!', style: style)),
                      ));
                    }
                  });
                  return;
                }

                handle ??= Nav.snackBar(Container(
                  color: Color.fromARGB(255, 61, 61, 61),
                  height: 56,
                  child: Center(child: Text('权限已请求成功!', style: style)),
                ))
                  ..future.whenComplete(() => handle = null);
              });
          },
        ),
      ),
      line,
    ];

    Widget child = ListView(children: children);
    child = Container(
      color: !context.isDarkMode ? null : const Color.fromRGBO(20, 20, 20, 1),
      child: child,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: getOverlayStyle(dark: context.isDarkMode, statusDark: true),
        child: Scaffold(appBar: AppBar(title: Text('设置')), body: child));
  }
}
