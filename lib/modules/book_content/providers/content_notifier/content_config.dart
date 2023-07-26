import 'package:flutter/Material.dart';
import 'package:flutter_nop/flutter_nop.dart';
import 'package:useful_tools/useful_tools.dart';

import '../../../constants.dart';
import '../content_config.dart';
import 'content_base.dart';
import 'content_status.dart';

mixin Configs on ContentDataBase, ContentStatus {
  late final ContentViewConfigProvider configProvider;

  ValueNotifier<ContentViewConfig> get config => configProvider.config;
  void init(NopLifecycle delegate) {
    configProvider = delegate.getType();
    initConfigs();
  }

  ValueNotifier<double> get autoValue => configProvider.autoValue;

  Future<void> setPrefs(ContentViewConfig _config) async {
    return configProvider.setPrefs(_config, (align) {
      final done =
          currentPage == tData.content.length || currentPage == 1 || align
              ? resetController
              : null;
      startFirstEvent(onStart: done);
    }, (isPortrait) async {
      await uiOverlay(hide: !isPortrait);
      setOrientation(isPortrait);
    });
  }

  late TextStyle style;
  late TextStyle secstyle;

  void initConfigs() {
    style = _getStyle(config.value);
    secstyle = style.copyWith(
      fontSize: contentFontSize,
      leadingDistribution: TextLeadingDistribution.even,
    );
    config.addListener(configListen);
  }

  TextStyle _getStyle(ContentViewConfig config) {
    return TextStyle(
      locale: const Locale('zh', 'CN'),
      fontSize: config.fontSize,
      color: config.fontColor!,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      // fontFamily: 'NotoSansSC', // SourceHanSansSC
      // fontFamilyFallback: ['RobotoMono', 'NotoSansSC'],
    );
  }

  void configListen() {
    style = _getStyle(config.value);
    secstyle = style.copyWith(
      fontSize: contentFontSize,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}

class ContentViewConfig {
  ContentViewConfig({
    this.fontSize,
    this.lineTweenHeight,
    this.bgcolor,
    this.fontFamily,
    this.fontColor,
    this.locale,
    this.axis,
    this.orientation,
    this.audio,
  });
  double? fontSize;
  double? lineTweenHeight;
  Color? bgcolor;
  String? fontFamily;
  Color? fontColor;
  Locale? locale;
  Axis? axis;
  bool? orientation; // true == portrait
  bool? audio;

  ContentViewConfig copyWith({
    double? fontSize,
    double? lineTweenHeight,
    Color? bgcolor,
    int? fontFamily,
    Color? fontColor,
    Locale? locale,
    Axis? axis,
    bool? orientation,
    bool? audio,
  }) {
    return ContentViewConfig(
        fontColor: fontColor ?? this.fontColor,
        fontFamily: fontFamily as String? ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineTweenHeight: lineTweenHeight ?? this.lineTweenHeight,
        bgcolor: bgcolor ?? this.bgcolor,
        locale: locale ?? this.locale,
        axis: axis ?? this.axis,
        audio: audio ?? this.audio,
        orientation: orientation ?? this.orientation);
  }

  bool get isEmpty {
    return bgcolor == null ||
        fontSize == null ||
        fontColor == null ||
        axis == null ||
        lineTweenHeight == null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ContentViewConfig &&
            fontColor == other.fontColor &&
            fontFamily == other.fontFamily &&
            fontSize == other.fontSize &&
            lineTweenHeight == other.lineTweenHeight &&
            bgcolor == other.bgcolor &&
            locale == other.locale &&
            axis == other.axis &&
            audio == other.audio &&
            orientation == other.orientation;
  }

  @override
  String toString() {
    return '$runtimeType: fontSize: $fontSize, bgcolor: $bgcolor, fontColor:'
        ' $fontColor, lineTweenHeight: $lineTweenHeight,'
        ' fontFamily: $fontFamily,  local: $locale, axis: $axis';
  }

  @override
  int get hashCode => Object.hash(fontColor, fontFamily, fontSize,
      lineTweenHeight, bgcolor, locale, axis, audio, orientation);
}
