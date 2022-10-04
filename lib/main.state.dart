import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribble/scribble.dart';

final scribbleStateProvider =
    StateNotifierProvider.autoDispose<ScribbleNotifier, ScribbleState>(
  (ref) => ScribbleNotifier(),
);
