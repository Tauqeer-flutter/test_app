import 'package:control_room/control_room.dart';
import 'package:flutter/material.dart';
import 'package:test_app/second_listener.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Second Page'),
      ),
      body: Column(
        children: [
          const Text('You have pushed the button this many times:'),
          StateListener<SecondController, bool>(
            builder: (context, count) {
              return TextButton(
                onPressed: () {
                  ControlRoom.get<SecondController>(context).toggle();
                },
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
