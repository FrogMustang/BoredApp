import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final void Function()? retryCallback;

  const ErrorScreen({
    Key? key,
    this.retryCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Column(
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
              )),
              child: Text('Retry'),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}
