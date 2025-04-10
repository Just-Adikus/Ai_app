import 'dart:convert';

import 'dart:io';
import 'package:egov__mob/widgets/voice_animation_wave.dart';
import "package:flutter/material.dart";
import 'package:vosk_flutter_2/vosk_flutter_2.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _modelName = 'vosk-model-small-kz-0.15';
  static const _sampleRate = 16000;

  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  final ModelLoader _modelLoader = ModelLoader();
  Model? _model;
  String? _error;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  String _recognizedText = '';
  bool _isListening = false;
  bool _isModelLoaded = false;
  String _responseText = '';

// Список иконок сервисов
List<String> serviceIcons = [
  'assets/icons/service1.png',
  'assets/icons/service2.png',
  'assets/icons/service3.png',
  'assets/icons/service4.png',
];

// Список популярных услуг
List<String> popularServices = [
  'Услуга 1',
  'Услуга 2',
  'Услуга 3',
  'Услуга 4',
  'Услуга 5',
];


Future<void> _sendRequest(String recognizedText) async {
  final url = 'https://5adf-34-82-29-56.ngrok-free.app/generate';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'prompt': recognizedText}),
  );

  if (response.statusCode == 200) {
    setState(() {
      _responseText = jsonDecode(response.body)['output'];
    });
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}

void _handleResult(String result) {
  var res = json.decode(result);
  var recognizedText = res['text'];
  _sendRequest(recognizedText); // Отправка запроса на сервер
}

  @override
  void initState() {
    super.initState();
    _initializeRecognizer();
    _requestMicrophonePermission();
    _modelLoader
        .loadModelsList()
        .then((modelsList) =>
            modelsList.firstWhere((model) => model.name == _modelName))
        .then((modelDescription) =>
            _modelLoader.loadFromNetwork(modelDescription.url))
        .then((modelPath) => _vosk.createModel(modelPath))
        .then((model) {
          setState(() {
            _model = model;
            _isModelLoaded =true; // Установите флаг в true после загрузки модели
          });
        })
        .then((_) =>
            _vosk.createRecognizer(model: _model!, sampleRate: _sampleRate))
        .then((value) => _recognizer = value)
        .then((recognizer) {
          if (Platform.isAndroid) {
            _vosk.initSpeechService(_recognizer!).then((speechService) {
              setState(() => _speechService = speechService);
            }).catchError((e) => setState(() => _error = e.toString()));
          }
        })
        .catchError((e) {
          setState(() => _error = e.toString());
          return null;
        });
  }


Widget _buildDialogContents() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      VoiceWaveAnimation(),
      Text(_recognizedText.isEmpty ? "Говорите..." : _recognizedText),
      SizedBox(height: 20),
      Text(_responseText), // Отображение ответа от сервера
    ],
  );
}

  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _initializeRecognizer() async {
    final modelPath = await _modelLoader.loadFromAssets('assets/models/vosk-model-small-kz-0.15.zip');
    _model = await _vosk.createModel(modelPath);
    _recognizer =
        await _vosk.createRecognizer(model: _model!, sampleRate: _sampleRate);

    if (Platform.isAndroid) {
      _speechService = await _vosk.initSpeechService(_recognizer!);
      _speechService!.onResult().listen((result) {
        print("Результат распознавания: $result");
        setState(() {
          _recognizedText = result;
        });
      });
      setState(() {
        _isModelLoaded = true;
      });
    }
  }

  void _toggleListening() async {
    if (!_isModelLoaded) {
      print('Модель не загружена. Пожалуйста, подождите.');
      return;
    }

    if (_isListening) {
      await _speechService?.stop();
    } else {
      await _speechService?.start();
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  Widget _buildRecognitionResults() {
    if (_speechService == null) {
      return Text("Speech service не инициализирован");
    }

    return Column(
      children: [
        StreamBuilder(
          stream: _speechService!.onResult(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String result = snapshot.data.toString();
              var res = json.decode(result);
              var recognizedText = res['text'];
              print(result);
              _handleResult(result); // Обработка результата
              return Column(
                children: [
                  Text(recognizedText), // Отображение распознанного текста
                  Text(_responseText), // Отображение обработанного ответа
                ],
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showVoiceDialog() {
    _toggleListening(); // Запуск записи

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Голосовой Ассистент"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              VoiceWaveAnimation(),
              _buildRecognitionResults(),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Закрыть",style: 
              TextStyle(color: Color.fromRGBO(21, 107, 195, 1.000),),),
              onPressed: () {
                _toggleListening(); // Остановка записи
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 107, 195, 1.000),
        leading: Icon(Icons.account_circle_outlined,color:Colors.white),
        title: Text(
          "Вход / Регистрация",
          style: TextStyle(fontSize: 14,color: Colors.white),
        ),
        elevation: 0,
        actions: <Widget>[
          Icon(Icons.qr_code_scanner_outlined,color: Colors.white,),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
            SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: serviceIcons.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(21, 107, 195, 1.000),
                      ),

                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20,),     
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: serviceIcons.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(21, 107, 195, 1.000),
                      ),
                    ),
                  );
                },
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
            ),
                        // Вертикальный список популярных услуг
                        // Вертикальный список популярных услуг
              ...popularServices.map((service) => Card(
                child: ListTile(
                title: Text(service),
              ))
              ).toList(),
          ],
        ),
      ),
      floatingActionButton:FloatingActionButton(
  shape: CircleBorder(),
  backgroundColor: Color.fromRGBO(21, 107, 195, 1.000),
  onPressed: _showVoiceDialog,
  child: CircleAvatar(
    backgroundImage: AssetImage('assets/images/egov_icon.jpg'),
    radius: 30.0, // Устанавливаем желаемый радиус круговой маски
  ),
),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromRGBO(21, 107, 195, 1.000),
        selectedIconTheme:
            IconThemeData(color: Color.fromRGBO(21, 107, 195, 1.000)),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
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
