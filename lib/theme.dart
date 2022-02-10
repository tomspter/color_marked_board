import 'package:fluent_ui/fluent_ui.dart';

class AppTheme extends ChangeNotifier{
  PaneDisplayMode _displayMode = PaneDisplayMode.auto;
  PaneDisplayMode get displayMode => _displayMode;
  set displayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
    notifyListeners();
  }
}