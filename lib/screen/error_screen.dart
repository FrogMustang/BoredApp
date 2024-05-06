import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final void Function()? retryCallback;

  const ErrorScreen({
    super.key,
    this.retryCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        const Icon(
          Icons.warning_amber_outlined,
          size: 40,
        ),
        const Text(
          'Opps. We did a booboo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "and we're not showing it to you",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        if (retryCallback != null)
          ElevatedButton(
            onPressed: retryCallback,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.teal,
              ),
            ),
            child: const Text('Retry'),
          ),
        const Spacer(),
      ],
    );
  }
}
