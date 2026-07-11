import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/farm_game.dart';
import 'state.dart';
import 'ui/hud.dart';
import 'ui/seed_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameState.I.load();
  runApp(const FarmApp());
}

class FarmApp extends StatelessWidget {
  const FarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مزرعتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: GameWidget<FarmGame>.controlled(
          gameFactory: FarmGame.new,
          overlayBuilderMap: {
            'hud': (context, game) => Hud(game: game),
            'seeds': (context, game) => SeedMenu(game: game),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}
