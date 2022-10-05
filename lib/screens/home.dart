import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screibble_app/main.state.dart';
import 'package:scribble/scribble.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ScribbleNotifier scribbleNotifier;

  @override
  void initState() {
    scribbleNotifier = ref.read(scribbleStateProvider.notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scribble Riverpod"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.save),
          tooltip: "Save to Image",
          onPressed: () => _saveImage(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Scribble(
                notifier: ref.watch(scribbleStateProvider.notifier),
                drawPen: true,
                drawEraser: true,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildToolbar(context),
                    const Divider(height: 32),
                    _buildStrokeToolbar(context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    final image = await scribbleNotifier.renderImage();
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/img.png");
    file.writeAsBytes(image.buffer.asUint8List());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Text("Your Image")),
        content: Column(
          children: [
            SizedBox(
              height: 500.0,
              child: Image.file(file),
            ),
            ElevatedButton(
              onPressed: () => Share.shareFiles([file.path]),
              child: const Text("Share image"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final w in scribbleNotifier.widths)
          _buildStrokeButton(
            context,
            strokeWidth: w,
            state: ref.read(scribbleStateProvider),
          ),
      ],
    );
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => scribbleNotifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
                color: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                border: state.map(
                  drawing: (_) => null,
                  erasing: (_) => Border.all(width: 1),
                ),
                borderRadius: BorderRadius.circular(50.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    const div4 = Divider(
      height: 4,
    );
    const div20 = Divider(
      height: 20,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildUndoButton(context),
        div4,
        _buildRedoButton(context),
        div4,
        _buildClearButton(context),
        div20,
        _buildEraserButton(
          context,
          isSelected: ref.read(scribbleStateProvider) is Erasing,
        ),
      ],
    );
  }

  Widget _buildEraserButton(BuildContext context, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FloatingActionButton.small(
        tooltip: "Erase",
        backgroundColor: const Color(0xFFF7FBFF),
        elevation: isSelected ? 10 : 2,
        shape: !isSelected
            ? const CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
        onPressed: scribbleNotifier.setEraser,
        child: const Icon(Icons.remove, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildUndoButton(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: "Undo",
      onPressed: scribbleNotifier.canUndo ? scribbleNotifier.undo : null,
      disabledElevation: 0,
      backgroundColor: scribbleNotifier.canUndo ? Colors.blueGrey : Colors.grey,
      child: const Icon(
        Icons.undo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRedoButton(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: "Redo",
      onPressed: scribbleNotifier.canRedo ? scribbleNotifier.redo : null,
      disabledElevation: 0,
      backgroundColor: scribbleNotifier.canRedo ? Colors.blueGrey : Colors.grey,
      child: const Icon(
        Icons.redo_rounded,
        color: Colors.white,
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: "Clear",
      onPressed: scribbleNotifier.clear,
      disabledElevation: 0,
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.clear),
    );
  }
}
