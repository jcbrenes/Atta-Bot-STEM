import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tec/features/bot-control/actions/action_menu.dart';
import 'package:proyecto_tec/features/bot-control/actions/history_menu.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/help_dialog_for_simplified.dart';
import 'package:proyecto_tec/features/commands/components/dropdown_menu_for_simplified.dart';
import 'package:proyecto_tec/features/bot-control/dialogs/default_movement_dialog.dart';
import 'package:proyecto_tec/features/bot-control/movement/movement_menu.dart';
import 'package:proyecto_tec/pages/history_page.dart';
import 'package:proyecto_tec/shared/features/dependency-manager/dependency_manager.dart';
import 'package:proyecto_tec/shared/features/navigation/services/navigation.dart';
import 'package:proyecto_tec/shared/components/ui/buttons/switch_button.dart';
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
        centerTitle: true,
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
              if(simplifiedProvider.simplifiedMode) {
                HelpDialogForSimplifiedMode.show(context);
              } else {
                HelpDialog.show(context);
              }
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ModeSwitch(
                    isSimplified: simplifiedProvider.simplifiedMode,
                    onChanged: (bool value) async{
                      if (value != simplifiedProvider.simplifiedMode) {
                        if (value) {
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
                        } else {
                          await HistoryDropdownHelper.showMenuForContext(context);
                        }
                        setState(() {
                          simplifiedProvider.setSimplifiedMode(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            MovementMenu(simplifiedMode: simplifiedProvider.simplifiedMode, defaultDistance: simplifiedProvider.defaultDistance, defaultAngle: simplifiedProvider.defaultAngle),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.02), 
                child: ActionMenu(),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Expanded(
              child: HistoryMenu(),
            ),
          ],
        ),
      ),
    );
  }
}