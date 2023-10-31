import "package:flutter/material.dart";
import 'package:alan_voice/alan_voice.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

_MainScreenState(){
        _initAlanButton();

}

void _initAlanButton() {
  /// Init Alan Button with project key from Alan AI Studio      
  AlanVoice.addButton("24d58515187894e62a0c474864802ac22e956eca572e1d8b807a3e2338fdd0dc/stage",
  buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);

  /// Handle commands from Alan AI Studio
  AlanVoice.onCommand.add((command) {
    debugPrint("got new command ${command.toString()}");
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 107, 195, 1.000),
        leading: Icon(Icons.account_circle_outlined),
        title: Text(
          "Вход / Регистрация",
          style: TextStyle(fontSize: 13),
        ),
        elevation: 0,
        actions: <Widget>[
          Icon(Icons.qr_code_scanner_outlined),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Color.fromRGBO(21, 107, 195, 1.000),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text("Цифровые документы"),
                  ),
                  SizedBox(width: 15),
                  Container(
                    child: Text("eGov QR"),
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.topLeft,
              child: Text(
                "Сервисы",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 100),
            Container(
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.topLeft,
              child: Text(
                "Популярные услуги",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromRGBO(21, 107, 195, 1.000),
      //   onPressed: () => {},
      //   child: const Icon(Icons.mic, color: Colors.white),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(21, 107, 195, 1.000),
        selectedIconTheme: IconThemeData(color: Color.fromRGBO(21, 107, 195, 1.000)),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Сведения',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_rounded),
            label: 'Услуги',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Уведомления',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        unselectedItemColor: Colors.grey,
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        showSelectedLabels: true, // Показать метки выбранных элементов
        showUnselectedLabels: true, // Показать метки неактивных элементов
      ),
    );
  }
}
