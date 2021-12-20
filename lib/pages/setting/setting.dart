import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:useful_tools/change_notifier.dart';
import 'package:useful_tools/widgets.dart';
import 'package:utils/utils.dart';

import '../../provider/options_notifier.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late OptionsNotifier optionsNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    optionsNotifier = context.read();
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

  Iterable<Widget> _buildChild(ConfigOptions options) sync* {
    final line = Divider(
        color: !context.isDarkMode
            ? Colors.grey.shade300
            : Color.fromRGBO(25, 25, 25, 1),
        height: 1.0);

    yield selector<OptionsNotifier>(
        title: 'app启动时刷新列表',
        select: (_, opt) => opt.options.updateOnStart ?? false,
        onChanged: (tap) {
          optionsNotifier.options = ConfigOptions(updateOnStart: tap);
        });

    yield line;
    final mode = optionsNotifier
        .selector((parent) => parent.options.themeMode ?? ThemeMode.system);
    void _onChanged(ThemeMode? updateValue) {
      optionsNotifier.options = ConfigOptions(themeMode: updateValue);
      // final isDark = OptionsNotifier.isDarkMode(updateValue);
      // uiStyle(dark: isDark);
      Get.back();
    }

    yield titleMenu(
        title: '主题配色',
        select: (_, opt) => opt.options.themeMode ?? ThemeMode.system,
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
        ]);

    yield line;
    yield selector<OptionsNotifier>(
        title: '指针采样',
        select: (_, opt) => opt.options.resample ?? false,
        onChanged: (updateValue) {
          optionsNotifier.options = ConfigOptions(resample: updateValue);
        });
    yield line;
    yield selector<OptionsNotifier>(
        title: '指针采样(修改版，最好不要同时使用)',
        select: (_, opt) => opt.options.nopResample ?? false,
        onChanged: (updateValue) {
          optionsNotifier.options = ConfigOptions(nopResample: updateValue);
        });
    if (!kDartIsWeb) {
      yield line;
    }
    if (!kDartIsWeb) {
      yield selector<OptionsNotifier>(
          title: '显示性能图层',
          select: (_, opt) => opt.options.showPerformanceOverlay ?? false,
          onChanged: (updateValue) {
            optionsNotifier.options =
                ConfigOptions(showPerformanceOverlay: updateValue);
          });
    }
    yield line;
    yield selector<OptionsNotifier>(
        title: '使用图片缓存',
        select: (_, opt) => opt.options.useImageCache ?? false,
        onChanged: (updateValue) {
          optionsNotifier.options = ConfigOptions(useImageCache: updateValue);
        });
    yield line;
    yield selector<OptionsNotifier>(
        title: '使用文本缓存',
        select: (_, opt) => opt.options.useTextCache ?? false,
        onChanged: (updateValue) {
          optionsNotifier.options = ConfigOptions(useTextCache: updateValue);
        });
    // if (!(defaultTargetPlatform == TargetPlatform.windows ||
    //     defaultTargetPlatform == TargetPlatform.linux)) {
    //   yield line;
    //   yield selector<OptionsNotifier>(
    //       title: '使用 sqflite',
    //       select: (_, opt) => opt.options.useSqflite ?? false,
    //       onChanged: (updateValue) {
    //         optionsNotifier.options = ConfigOptions(useSqflite: updateValue);
    //       });
    // }

    yield line;
    void update(TargetPlatform? d) {
      optionsNotifier.options = ConfigOptions(platform: d);
      Get.back();
    }

    yield titleMenu(
        title: '平台',
        select: (_, opt) => opt.options.platform ?? defaultTargetPlatform,
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
          Selector<OptionsNotifier, TargetPlatform>(
              selector: (_, opt) =>
                  opt.options.platform ?? defaultTargetPlatform,
              builder: (context, updateValue, _) {
                return RadioListTile(
                  title: Text('android'),
                  value: TargetPlatform.android,
                  onChanged: update,
                  groupValue: updateValue,
                );
              }),
          Selector<OptionsNotifier, TargetPlatform>(
              selector: (_, opt) =>
                  opt.options.platform ?? defaultTargetPlatform,
              builder: (context, updateValue, _) {
                return RadioListTile(
                  title: Text('ios'),
                  value: TargetPlatform.iOS,
                  onChanged: update,
                  groupValue: updateValue,
                );
              }),
        ]);
    yield line;
    yield ColoredBox(
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
          if (defaultTargetPlatform == TargetPlatform.android)
            Permission.manageExternalStorage.status.then((status) {
              if (status.isDenied) {
                Log.w('status denied', onlyDebug: false);
                Permission.manageExternalStorage.request().then((status) {
                  if (status.isDenied) {
                    Log.w('request denied', onlyDebug: false);
                  } else if (status.isGranted && mounted) {
                    Get.showSnackbar(GetSnackBar(messageText: Text('请求成功！')));
                  }
                });
                return;
              }
              if (mounted) {
                _snackBarController ??=
                    Get.showSnackbar(GetSnackBar(messageText: Text('权限已请求成功！')))
                      ..future.whenComplete(() => _snackBarController = null);
              }
            });
        },
      ),
    );

    yield line;
  }

  static SnackbarController? _snackBarController;

  ColoredBox titleMenu<T>(
      {required String title,
      required T Function(BuildContext, OptionsNotifier) select,
      Widget? Function(T value)? trailingChild,
      required List<Widget> children}) {
    return ColoredBox(
      color: !context.isDarkMode ? Colors.white : Colors.grey.shade900,
      child: Selector<OptionsNotifier, T>(
        selector: select,
        builder: (context, updateValue, _) {
          return ListTile(
            onTap: () {
              Get.dialog(Center(
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
              )));
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

  Widget selector<T>(
      {required String title,
      required bool Function(BuildContext, T) select,
      required void Function(bool updateValue) onChanged}) {
    return ColoredBox(
      color: !context.isDarkMode ? Colors.white : Colors.grey.shade900,
      child: Selector<T, bool>(
          selector: select,
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
                onChanged: onChanged);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = optionsNotifier.options;
    final children = _buildChild(options).toList();

    final child = ListViewBuilder(
      color: !context.isDarkMode ? null : const Color.fromRGBO(20, 20, 20, 1),
      itemBuilder: (BuildContext context, int index) {
        return children[index];
      },
      itemCount: children.length,
    );

    return Scaffold(appBar: AppBar(title: Text('设置')), body: child);
  }
}
