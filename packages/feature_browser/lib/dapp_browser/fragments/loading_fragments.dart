import 'package:flutter/material.dart';

class LoadingFragments extends StatelessWidget {
  final double progress;
  const LoadingFragments({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 40),
              const Icon(Icons.flutter_dash, size: 64),
              const SizedBox(height: 20),
              Text("正在加载 DApp...", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        ),
      ),
    );
  }
}
