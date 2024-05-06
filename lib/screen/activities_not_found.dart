import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivitiesNotFound extends StatelessWidget {
  const ActivitiesNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            'No activities found :/',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'but maybe you can brainstorm some ideas with your friends',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Spacer(),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
