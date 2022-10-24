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

  //Drawer denemesini canlı canlı yapalım.
  //score, falseScore, trueScore değişkenlerini değiştirelim.

  //Uygulama açıldığında ilk ve yalnızca bir kez çalışan fonksiyondur.
  @override
  void initState() {
    super.initState();

    selectRandomWord();

    //Sanal klavyeden tuşa basıldığında tetiklenecek olan fonksiyondur.
    textController.addListener(() {
      if (textController.text.isNotEmpty) {
        control();
        textController.text = "";
      }
    });
  }

  //Önceden hazırlanan kelime listesinden rastgele bir kelime seçen fonksiyondur.
  void selectRandomWord() {
    int random = Random().nextInt(Constants.words.length);
    word = Constants.words[random];
  }

  //Her tuşa basıldığında çalışan fonksiyondur.
  void control() {
    //.toUpperCase().toLowerCase() sayesinde kontrolü daha sağlıklı yapar.
    String char = textController.text.toUpperCase().toLowerCase();

    if (!enteredChars.contains(char)) {
      enteredChars.add(char);

      //Eğer kelime, girilen karaktere sahipse score değişkenine trueScore değerini ekler ve trueEnteredChars değişkenine bu karakteri ekler. Değilse score değişkeninden falseScore değerini çıkarır.
      if (word.toUpperCase().toLowerCase().contains(char)) {
        score += trueScore;
        trueEnteredChars.add(char);
      } else {
        score -= falseScore;
      }

      setState(() {});

      Set<String> charsInSelectedWord = word.split("").toSet();

      //Seçilen karakterdeki farklı harflerin sayısı, doğru girilen farklı harflerin sayısına eşitse oyunu bitirir.
      if (charsInSelectedWord.length == trueEnteredChars.length) {
        finishGame();
      }
    } else {
      showToast("Bu harfi zaten kullandınız!");
    }
  }

  void showToast(String msg) {
    //Hazır kütüphane kullanarak bu fonksiyon sayesinde ekranda toast mesajı gösterebiliriz.
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

  //playAgain fonksiyonu ile değişkenleri sıfırlayarak uygulamayı tekrar başlatırız. selectRandomWord fonksiyonu ile rastgele bir kelime seçiyorduk, onu da kullanıyoruz.
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

  //Uygulama hazır olduğunda çalışan fonksiyondur. Uygulama ekranını çizer. State yani durum her güncellendiğinde bu fonksiyon çalışır. Flutter lifecycle diye araştırmayla daha detaylı bilgi edinilebilir.
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

  //Ekrana yazı yazdırmak işte bu kadar basittir.
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

  //Uygulama içinde klavye kullanabiliyoruz fakat burada herhangi bir yerde input yani bir değer girebileceğimiz kutucuk olmadığı için telefonun klavyesini açamıyoruz. Dolayısıyla sanal bir klavye eklemek zorundayız. Başkalarının geliştirdiği ve herkese açık paylaştığı klavyeyi kütüphane olarak projeye dahil eder ve rahatça kullanabiliriz.
  Widget get keyboardWidget => VirtualKeyboard(
        type: VirtualKeyboardType.Alphanumeric,
        textController: textController,
      );
}
