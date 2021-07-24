// import 'dart:async';
// import 'dart:io';

// import 'dart:ui' as ui;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:provider/provider.dart';
// import '../../provider/provider.dart';

// import '../../event/event.dart';
// import '../../utils/binding/widget_binding.dart';
// import '../../utils/utils.dart';
// import '../../utils/widget/image_shadow.dart';
// import '../../widgets/draw_picture.dart';
// import '../../widgets/picture_info.dart';

// typedef ImageBuilder = Widget Function(Widget image, bool hasImage);

// class ImageResolve extends StatefulWidget {
//   ImageResolve(
//       {Key? key,
//       this.img,
//       this.builder,
//       this.errorBuilder,
//       this.placeholder,
//       this.boxFit = BoxFit.fitWidth,
//       this.shadow = true})
//       : super(key: key);
//   final String? img;
//   final Widget Function(Widget)? builder;
//   final Widget Function(BuildContext)? errorBuilder;
//   final BoxFit boxFit;
//   final bool shadow;
//   final Widget? placeholder;

//   @override
//   State<ImageResolve> createState() => _ImageResolveState();
// }

// class _ImageResolveState extends State<ImageResolve> {
//   @override
//   Widget build(BuildContext context) {
//     final _img = widget.img;
//     final child = _layoutBuilder(getPath(_img));

//     return RepaintBoundary(child: Center(child: child));
//   }

//   @override
//   void didUpdateWidget(covariant ImageResolve oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.img != oldWidget.img) {
//       _f = null;
//     }
//   }

//   Future<String?>? _f;
//   Future<String?> getPath(String? img) {
//     if (_f != null) return _f!;
//     if (img == null) return _f = SynchronousFuture(img);
//     final repository = context.read<Repository>();

//     return _f =
//         Future.value(repository.bookEvent.customEvent.getImagePath(img));
//   }

//   Widget _layoutBuilder(Future<String?> _future, {isFirst = true}) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final height = constraints.maxHeight;
//       final width = constraints.maxWidth;
//       return _futureBuilder(_future, isFirst, width, height);
//     });
//   }

//   FutureBuilder<String?> _futureBuilder(
//       Future<String?> _future, bool isFirst, double width, double height) {
//     final ratio = ui.window.devicePixelRatio;
//     return FutureBuilder(
//       future: _future,
//       builder: (context, AsyncSnapshot<String?> snap) {
//         if (snap.hasData) {
//           final data = snap.data!;

//           if (data.isEmpty) {
//             return _errorBuilder(isFirst, width, height);
//           } else {
//             final f = File(data);
//             return Selector<OptionsNotifier, bool>(
//               selector: (_, opt) => opt.options.useImageCache ?? false,
//               builder: (context, useImageCache, _) {
//                 if (!useImageCache) {
//                   return Image.file(
//                     f,
//                     // cacheHeight: (constraints.maxHeight * ratio).toInt(),
//                     cacheWidth: (width * ratio).toInt(),
//                     fit: widget.boxFit,
//                     frameBuilder: (_, child, frame, sync) {
//                       return _imageBuilder(child, sync, frame != null);
//                     },
//                     errorBuilder: (context, __, ___) =>
//                         _errorBuilder(isFirst, width, height),
//                   );
//                 }
//                 return _Image(
//                   f: f,
//                   height: height,
//                   width: width,
//                   boxFit: widget.boxFit,
//                   builder: (child, hasImage) =>
//                       _imageBuilder(child, false, hasImage),
//                   errorBuilder: (context) =>
//                       _errorBuilder(isFirst, width, height),
//                 );
//               },
//             );
//           }
//         } else if (snap.connectionState == ConnectionState.done) {
//           return _errorBuilder(isFirst, width, height);
//         }

//         return widget.placeholder ?? const SizedBox();
//       },
//     );
//   }

//   Widget _errorBuilder(bool isFirst, double width, double height) {
//     if (isFirst) {
//       if (widget.errorBuilder != null) {
//         return widget.errorBuilder!(context);
//       } else {
//         return _futureBuilder(getPath(errorImg), false, width, height);
//       }
//     }
//     return const SizedBox();
//   }

//   Widget _imageBuilder(Widget child, bool sync, bool hasImage) {
//     if (hasImage) {
//       if (widget.builder != null) child = widget.builder!(child);
//       if (widget.shadow) child = ImageShadow(child: child);
//       if (sync) return child;
//     }
//     return child;
//     // return AnimatedOpacity(
//     //     opacity: hasImage ? 1 : 0,
//     //     duration: const Duration(milliseconds: 300),
//     //     child: child);
//   }
// }

// class _Image extends StatefulWidget {
//   const _Image(
//       {Key? key,
//       this.builder,
//       this.errorBuilder,
//       required this.f,
//       required this.height,
//       required this.width,
//       this.boxFit = BoxFit.fitWidth})
//       : super(key: key);

//   final File f;
//   final BoxFit boxFit;
//   final ImageBuilder? builder;
//   final double height;
//   final double width;
//   final Widget Function(BuildContext context)? errorBuilder;

//   @override
//   ImageState createState() => ImageState();
// }

// class ImageState extends State<_Image> {
//   final nop = NopWidgetsFlutterBinding.instance!;
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _sub();
//   }

//   @override
//   void didUpdateWidget(covariant _Image oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.f.path != oldWidget.f.path ||
//         widget.height != oldWidget.height ||
//         widget.width != oldWidget.width) {
//       _sub();
//     }
//   }

//   PictureInfo? pictureInfo;
//   PictureStream? listener;

//   void _sub() {
//     final _ofile = widget.f;

//     final width = widget.width;
//     final height = widget.height;
//     final _listener = nop.preCache(_ofile,
//         cacheWidth: width, cacheHeight: height, fit: widget.boxFit);

//     if (listener != _listener) {
//       final l = PictureListener(onListener, load: onDefLoad);
//       listener?.removeListener(l);
//       // Log.w('removeListener  ${listener.hashCode}');
//       _listener.addListener(l);
//       listener = _listener;
//       // Log.w('addListener  ${listener.hashCode}');
//     }
//   }

//   var _error = false;
//   void onListener(PictureInfo? img, bool error, bool sync) {
//     assert(mounted);

//     setState(() {
//       pictureInfo?.dispose();
//       pictureInfo = img;
//       _error = error;
//     });
//   }

//   bool onDefLoad() =>
//       mounted && Scrollable.recommendDeferredLoadingForContext(context);

//   @override
//   void dispose() {
//     listener?.removeListener(PictureListener(onListener, load: onDefLoad));
//     // Log.w('dispose  ${listener.hashCode}');
//     listener = null;

//     pictureInfo?.dispose();
//     pictureInfo = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final image = PictureWidget(info: pictureInfo);

//     if (_error) {
//       if (widget.errorBuilder != null) {
//         return widget.errorBuilder!(context);
//       }
//     } else {
//       if (widget.builder != null) {
//         return widget.builder!(image, pictureInfo != null);
//       }
//     }

//     return image;
//   }
// }
