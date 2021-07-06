// import 'dart:math' as math;

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class ClampingScrollPhysicsNew extends ScrollPhysics {
//   /// Creates scroll physics that prevent the scroll offset from exceeding the
//   /// bounds of the content.
//   const ClampingScrollPhysicsNew({ScrollPhysics? parent})
//       : super(parent: parent);

//   @override
//   ClampingScrollPhysicsNew applyTo(ScrollPhysics? ancestor) {
//     return ClampingScrollPhysicsNew(parent: buildParent(ancestor));
//   }

//   @override
//   double applyBoundaryConditions(ScrollMetrics position, double value) {
//     assert(() {
//       if (value == position.pixels) {
//         throw FlutterError.fromParts(<DiagnosticsNode>[
//           ErrorSummary(
//               '$runtimeType.applyBoundaryConditions() was called redundantly.'),
//           ErrorDescription(
//               'The proposed new position, $value, is exactly equal to the current position of the '
//               'given ${position.runtimeType}, ${position.pixels}.\n'
//               'The applyBoundaryConditions method should only be called when the value is '
//               'going to actually change the pixels, otherwise it is redundant.'),
//           DiagnosticsProperty<ScrollPhysics>(
//               'The physics object in question was', this,
//               style: DiagnosticsTreeStyle.errorProperty),
//           DiagnosticsProperty<ScrollMetrics>(
//               'The position object in question was', position,
//               style: DiagnosticsTreeStyle.errorProperty)
//         ]);
//       }
//       return true;
//     }());
//     if (value < position.pixels &&
//         position.pixels <= position.minScrollExtent) // underscroll
//       return value - position.pixels;
//     if (position.maxScrollExtent <= position.pixels &&
//         position.pixels < value) // overscroll
//       return value - position.pixels;
//     if (value < position.minScrollExtent &&
//         position.minScrollExtent < position.pixels) // hit top edge
//       return value - position.minScrollExtent;
//     if (position.pixels < position.maxScrollExtent &&
//         position.maxScrollExtent < value) // hit bottom edge
//       return value - position.maxScrollExtent;
//     return 0.0;
//   }

//   @override
//   Simulation? createBallisticSimulation(
//       ScrollMetrics position, double velocity) {
//     final tolerance = this.tolerance;
//     if (position.outOfRange) {
//       double? end;
//       if (position.pixels > position.maxScrollExtent)
//         end = position.maxScrollExtent;
//       if (position.pixels < position.minScrollExtent)
//         end = position.minScrollExtent;
//       assert(end != null);
//       return ScrollSpringSimulation(
//         spring,
//         position.pixels,
//         end!,
//         math.min(0.0, velocity),
//         tolerance: tolerance,
//       );
//     }
//     if (velocity.abs() < tolerance.velocity) return null;
//     if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
//       return null;
//     if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
//       return null;
//     return ClampingScrollSimulationNew(
//       position: position.pixels,
//       velocity: velocity,
//       tolerance: tolerance,
//     );
//   }
// }

// const double _inflexion = 0.35;

// /// flutter master
// class ClampingScrollSimulationNew extends Simulation {
//   ClampingScrollSimulationNew({
//     required this.position,
//     required this.velocity,
//     this.friction = 0.015,
//     Tolerance tolerance = Tolerance.defaultTolerance,
//   }) : super(tolerance: tolerance) {
//     _duration = _splineFlingDuration(velocity);
//     _distance = _splineFlingDistance(velocity);
//   }

//   final double position;

//   final double velocity;

//   final double friction;

//   late int _duration;
//   late double _distance;

//   static final double _kDecelerationRate = math.log(0.78) / math.log(0.9);

//   static double _decelerationForFriction(double friction) {
//     return 9.80665 *
//         39.37 *
//         friction *
//         1.0 * // Flutter operates on logical pixels so the DPI should be 1.0.
//         160.0;
//   }

//   double _splineDeceleration(double velocity) {
//     return math.log(_inflexion *
//         velocity.abs() /
//         (friction * _decelerationForFriction(0.84)));
//   }

//   int _splineFlingDuration(double velocity) {
//     final deceleration = _splineDeceleration(velocity);
//     return (1000 * math.exp(deceleration / (_kDecelerationRate - 1.0))).round();
//   }

//   // See getSplineFlingDistance().
//   double _splineFlingDistance(double velocity) {
//     final l = _splineDeceleration(velocity);
//     final decelMinusOne = _kDecelerationRate - 1.0;
//     return friction *
//         _decelerationForFriction(0.84) *
//         math.exp(_kDecelerationRate / decelMinusOne * l);
//   }

//   @override
//   double x(double time) {
//     if (time == 0) {
//       return position;
//     }
//     final sample = _NBSample(time, _duration);
//     return position + (sample.distanceCoef * _distance) * velocity.sign;
//   }

//   @override
//   double dx(double time) {
//     if (time == 0) {
//       return velocity;
//     }
//     final sample = _NBSample(time, _duration);
//     return sample.velocityCoef * _distance / _duration * velocity.sign * 1000.0;
//   }

//   @override
//   bool isDone(double time) {
//     return time * 1000.0 >= _duration;
//   }
// }

// class _NBSample {
//   _NBSample(double time, int duration) {
//     // See computeScrollOffset().
//     final t = time * 1000.0 / duration;
//     final index = (_nbSamples * t).clamp(0, _nbSamples).round();
//     _distanceCoef = 1.0;
//     _velocityCoef = 0.0;
//     if (index < _nbSamples) {
//       final tInf = index / _nbSamples;
//       final tSup = (index + 1) / _nbSamples;
//       final dInf = _splinePosition[index];
//       final dSup = _splinePosition[index + 1];
//       _velocityCoef = (dSup - dInf) / (tSup - tInf);
//       _distanceCoef = dInf + (t - tInf) * _velocityCoef;
//     }
//   }

//   late double _velocityCoef;
//   double get velocityCoef => _velocityCoef;

//   late double _distanceCoef;
//   double get distanceCoef => _distanceCoef;

//   static const int _nbSamples = 100;

//   // Generated from dev/tools/generate_android_spline_data.dart.
//   static final List<double> _splinePosition = <double>[
//     0.000022888183591973643,
//     0.028561000304762274,
//     0.05705195792956655,
//     0.08538917797618413,
//     0.11349556286812107,
//     0.14129881694635613,
//     0.16877157254923383,
//     0.19581093511175632,
//     0.22239649722992452,
//     0.24843841866631658,
//     0.2740024733220569,
//     0.298967680744136,
//     0.32333234658228116,
//     0.34709556909569184,
//     0.3702249257894571,
//     0.39272483400399893,
//     0.41456988647721615,
//     0.43582889025419114,
//     0.4564192786416,
//     0.476410299013587,
//     0.4957560715637827,
//     0.5145493169954743,
//     0.5327205670880077,
//     0.5502846891191615,
//     0.5673274324802855,
//     0.583810881323224,
//     0.5997478744397482,
//     0.615194045299478,
//     0.6301165005270208,
//     0.6445484042257972,
//     0.6585198219185201,
//     0.6720397744233084,
//     0.6850997688076114,
//     0.6977281404741683,
//     0.7099506591298411,
//     0.7217749311525871,
//     0.7331784038850426,
//     0.7442308394229518,
//     0.7549087205105974,
//     0.7652471277371271,
//     0.7752251637549381,
//     0.7848768260203478,
//     0.7942056937103814,
//     0.8032299679689082,
//     0.8119428702388629,
//     0.8203713516576219,
//     0.8285187880808974,
//     0.8363794492831295,
//     0.8439768562813565,
//     0.851322799855549,
//     0.8584111051351724,
//     0.8652534074722162,
//     0.8718525580962131,
//     0.8782333271742155,
//     0.8843892099362031,
//     0.8903155590440985,
//     0.8960465359221951,
//     0.9015574505919048,
//     0.9068736766459904,
//     0.9119951682409297,
//     0.9169321898723632,
//     0.9216747065581234,
//     0.9262420604674766,
//     0.9306331858366086,
//     0.9348476990715433,
//     0.9389007110754832,
//     0.9427903495057521,
//     0.9465220679845756,
//     0.9500943036519721,
//     0.9535176728088761,
//     0.9567898524767604,
//     0.959924306623116,
//     0.9629127700159108,
//     0.9657622101750765,
//     0.9684818726275105,
//     0.9710676079044347,
//     0.9735231939498,
//     0.9758514437576309,
//     0.9780599066560445,
//     0.9801485715370128,
//     0.9821149805689633,
//     0.9839677526782791,
//     0.9857085499421516,
//     0.9873347811966005,
//     0.9888547171706613,
//     0.9902689443512227,
//     0.9915771042095881,
//     0.9927840651641069,
//     0.9938913963715834,
//     0.9948987305580712,
//     0.9958114963810524,
//     0.9966274782266875,
//     0.997352148697352,
//     0.9979848677523623,
//     0.9985285021374979,
//     0.9989844084453229,
//     0.9993537595844986,
//     0.999638729860106,
//     0.9998403888004533,
//     0.9999602810470701,
//     1.0,
//   ];
// }
