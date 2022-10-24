import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter_kelime_bulmaca/utils/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:virtual_keyboard_2/virtual_keyboard_2.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late String word;
  TextEditingController textController = TextEditingController();

  int score = 200;
  int falseScore = 25;
  int trueScore = 50;

  bool isFinished = false;

  Set<String> enteredChars = {};
  Set<String> trueEnteredChars = {};

  @override
  void initState() {
    super.initState();

    selectRandomWord();

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
        trueEnteredChars.add(char);
      } else {
        score -= falseScore;
      }

      setState(() {});

      Set<String> charsInSelectedWord = word.split("").toSet();

      if (charsInSelectedWord.length == trueEnteredChars.length) {
        finishGame();
      }
    } else {
      showToast("Bu harfi zaten kullandınız!");
    }
  }

  void showToast(String msg) {
    Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_LONG);
  }

  void finishGame() {
    setState(() {
      isFinished = true;
    });

    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: gameOverDialogWidget,
      ),
    );
  }

  void selectRandomWord() {
    int random = Random().nextInt(Constants.words.length);
    word = Constants.words[random];
  }

  void playAgain() {
    setState(() {
      score = 100;
      isFinished = false;
      enteredChars = {};
      trueEnteredChars = {};

      selectRandomWord();
    });

    Navigator.pop(context);
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
                Expanded(child: wordWidget),
                communityWidget,
              ],
            ),
          ),
          keyboardWidget,
        ],
      );

  Widget get communityWidget => Container(
        padding: EdgeInsets.all(10),
        child: Text("Yazılım Geliştirme Topluluğu"),
      );

  Widget get gameOverDialogWidget => SimpleDialog(
        title: Text("Oyun Bitti!"),
        children: [
          scoreWidget,
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: playAgain,
                child: Text("Yeniden Oyna"),
              ),
            ],
          ),
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
