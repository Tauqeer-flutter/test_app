import 'package:control_room/control_room.dart';

class SecondController extends StateController<bool> {
  SecondController() : super(false);

  void toggle() {
    state = !state;
  }
}
