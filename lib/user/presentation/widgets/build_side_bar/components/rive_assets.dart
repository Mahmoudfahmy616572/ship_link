import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  final int index;
  RiveWidgetController? controller;
  BooleanInput? input;

  RiveAsset(this.src,
      {required this.artboard,
      required this.index,
      required this.stateMachineName,
      required this.title});
}

List<RiveAsset> sideMenue = [
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "HOME",
      stateMachineName: "HOME_interactivity",
      title: "home_drawer",
      index: 0),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
      title: "profile_drawer",
      index: 1),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "LIKE/STAR",
      stateMachineName: "STAR_Interactivity",
      title: "favourites_drawer",
      index: 4),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "BELL",
      stateMachineName: "BELL_Interactivity",
      title: "notifications",
      index: 2),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "CHAT",
      stateMachineName: "CHAT_Interactivity",
      title: "help_center",
      index: 5),
  RiveAsset("assets/RiveAssets/icons.riv",
      artboard: "SETTINGS",
      stateMachineName: "SETTINGS_Interactivity",
      title: "settings",
      index: 3),
];
