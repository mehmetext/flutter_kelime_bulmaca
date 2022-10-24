import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter_kelime_bulmaca/utils/constants.dart';
import 'package:virtual_keyboard_2/virtual_keyboard_2.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late int random;
  late String word;
  TextEditingController textController = TextEditingController();

  int score = 100;
  int falseScore = 20;
  int trueScore = 30;

  List<String> enteredChars = [];

  @override
  void initState() {
    super.initState();

    random = Random().nextInt(Constants.words.length);
    word = Constants.words[random];

    textController.addListener(() {
      if (textController.text.isNotEmpty) {
        control();
        textController.text = "";
      }
    });
  }

  void control() {
    String char = textController.text.toUpperCase().toLowerCase();

    if (!enteredChars.contains(char)) {
      enteredChars.add(char);

      if (word.toUpperCase().toLowerCase().contains(char)) {
        score += trueScore;
      } else {
        score -= falseScore;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kelime Bulmaca"),
      ),
      body: bodyWidget,
    );
  }

  Widget get bodyWidget => Column(
        children: [
          Expanded(
            child: Column(
              children: [
                scoreWidget,
                wordWidget,
              ],
            ),
          ),
          keyboardWidget,
        ],
      );

  Widget get scoreWidget => Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Skor: "),
            SizedBox(width: 10),
            Text(
              "$score",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ],
        ),
      );

  Widget get wordWidget => Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Wrap(
          runSpacing: 10,
          spacing: 10,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < word.length; i++)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                ),
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child:
                    enteredChars.contains(word[i].toUpperCase().toLowerCase())
                        ? Text(
                            word[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
              ),
          ],
        ),
      );

  Widget get keyboardWidget => VirtualKeyboard(
        type: VirtualKeyboardType.Alphanumeric,
        textController: textController,
        builder: (context, key) {
          return Container();
        },
      );
}
