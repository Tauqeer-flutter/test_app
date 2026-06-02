import 'package:control_room/control_room.dart';

class CounterController extends StateController<int> {
  CounterController() : super(0);

  void increment() {
    state = state + 1;
  }
}
