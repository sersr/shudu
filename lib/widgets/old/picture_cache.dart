
// class PictureCache {
//   void clear() {
//     clearDispose(_textDisposesCaches);
//     clearDispose(_textDisposes);
//     clearDispose(_textListeners);
//   }

//   void clearDispose(Map<ListKey, PictureStream> map) {
//     print('dispose: ${map.length}');
//     map.values.forEach((stream) => stream.dispose());
//     map.clear();
//   }

//   final _tlooper = EventLooper(parallels: 2);
//   final _textListeners = <ListKey, PictureStream>{};
//   final _textDisposes = <ListKey, PictureStream>{};
//   final _textDisposesCaches = <ListKey, PictureStream>{};

//   PictureStream? getListener(ListKey key) {
//     var listener = _textDisposesCaches.remove(key);
//     if (listener != null) {
//       assert(!_textDisposes.containsKey(key));
//       assert(!_textListeners.containsKey(key));
//       _textListeners[key] = listener;
//     }
//     if (listener == null) {
//       listener ??= _textDisposes.remove(key);

//       if (listener != null) {
//         assert(!_textListeners.containsKey(key));
//         _textListeners[key] = listener;
//       }
//     }

//     listener ??= _textListeners[key];

//     assert(!_textDisposes.containsKey(key));

//     return listener;
//   }

//   PictureStream putIfAbsent(
//       List keys, Future<Size> Function(Canvas canvas) callback) {
//     final key = ListKey(keys);

//     final _text = getListener(key);
//     if (_text != null) return _text;

//     final stream = _textListeners[key] = PictureStream(onRemove: (stream) {
//       assert(!_textDisposes.containsKey(key));

//       if (_textListeners.containsKey(key)) {
//         final _stream = _textListeners.remove(key);
//         assert(_stream == stream);

//         final disposeLength = _textDisposes.length;

//         /// 缓存超过100，移到二级缓存，由二级缓存释放
//         if (disposeLength >= 50) {
//           if (_textDisposesCaches.length > 240) {
//             clearDispose(_textDisposesCaches);
//           }
//           _textDisposesCaches.addAll(_textDisposes);
//           _textDisposes.clear();
//         }

//         _textDisposes[key] = stream;
//       } else {
//         stream.dispose();
//       }
//     });

//     _tlooper.addEventTask(() async {
//       final recoder = ui.PictureRecorder();
//       final canvas = Canvas(recoder);

//       await releaseUI;
//       final size = await callback(canvas);

//       final picture = PictureInfo.picture(recoder.endRecording(), size);
//       await releaseUI;
//       stream.setPicture(picture);
//     });

//     return stream;
//   }
// }