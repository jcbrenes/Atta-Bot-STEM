import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/styles/colors.dart';

class BotControlPage extends StatefulWidget {
  const BotControlPage({super.key});
  @override
  State<BotControlPage> createState() => _BotControlPageState();
}

class SimplifiedModeProvider extends ChangeNotifier {
  bool _simplifiedMode = false;
  int _defaultDistance = 10;
  int _defaultAngle = 90;

  bool get simplifiedMode => _simplifiedMode;
  int get defaultDistance => _defaultDistance;
  int get defaultAngle => _defaultAngle;

  void setSimplifiedMode(bool value) {
    _simplifiedMode = value;
    notifyListeners();
  }

  void setDefaults(int distance, int angle) {
    _defaultDistance = distance;
    _defaultAngle = angle;
    notifyListeners();
  }
}

class _BotControlPageState extends State<BotControlPage> {
  NavigationService navService = DependencyManager().getNavigationService();

  @override
  Widget build(BuildContext context) {
    final simplifiedProvider = Provider.of<SimplifiedModeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Atta-Bot Educativo'),
        titleTextStyle: const TextStyle(
            color: neutralWhite,
            fontSize: 18.0,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Image.asset(
              'assets/button_icons/question_mark.png',
              color: neutralWhite,
              height: 16,
              width: 16,
            ),
            color: neutralWhite,
            onPressed: () {
              HelpDialog.show(context);
            },
          ),
        ],
      ),
      body: Container(
        color: neutralDarkBlue,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Modo simplificado',
                  style: TextStyle(
                    color: neutralWhite,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Switch(
                  value: simplifiedProvider.simplifiedMode,
                  inactiveThumbColor: neutralWhite,
                  activeThumbColor: secondaryIconOrange,
                  onChanged: (bool value) {
                    if (value){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return DefaultMovementDialog(
                            initialDistance: simplifiedProvider.defaultDistance,
                            initialAngle: simplifiedProvider.defaultAngle,
                            onSetDefaults: (newDistance, newAngle) {
                              simplifiedProvider.setDefaults(newDistance, newAngle);
                            },
                          );
                        },
                      );
                    }else{
                      HistoryPage.showClearHistoryDialog(context);
                    }
                    setState(() {
                      simplifiedProvider.setSimplifiedMode(value);
                    });
                  },
                ),
              ],
            ),
            MovementMenu(simplifiedMode: simplifiedProvider.simplifiedMode, defaultDistance: simplifiedProvider.defaultDistance, defaultAngle: simplifiedProvider.defaultAngle),
            const Expanded(child: SizedBox(height: 10)),
            const ActionMenu(),
            const Expanded(child: SizedBox(height: 10)),
            const HistoryMenu(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
