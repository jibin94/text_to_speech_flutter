import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

enum TtsState { playing, stopped }

class MyAppState extends State<MyApp> {
  FlutterTts? flutterTts;
  dynamic languages;
  String? language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts!.setStartHandler(
      () {
        setState(
          () {
            debugPrint("playing");
            ttsState = TtsState.playing;
          },
        );
      },
    );

    flutterTts!.setCompletionHandler(
      () {
        setState(
          () {
            debugPrint("Complete");
            ttsState = TtsState.stopped;
          },
        );
      },
    );

    flutterTts!.setErrorHandler((msg) {
      setState(() {
        debugPrint("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts!.getLanguages;
    debugPrint("languages $languages");
    if (languages != null) setState(() => languages);
  }

  Future _speak() async {
    await flutterTts!.setVolume(volume);
    await flutterTts!.setSpeechRate(rate);
    await flutterTts!.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        var result = await flutterTts!.speak(_newVoiceText!);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts!.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts!.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    ///To remove duplicate items from being added in your getLanguageDropDownMenuItems method,
    ///you can use a Set to keep track of items that have already been added.
    ///This ensures that each item is only added once.
    List<DropdownMenuItem<String>> items = [];
    Set<String> seenLanguages = <String>{};

    for (String language in languages) {
      if (!seenLanguages.contains(language)) {
        items.add(DropdownMenuItem(value: language, child: Text(language)));
        seenLanguages.add(language);
      }
    }

    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts!.setLanguage(language!);
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: bottomBar(),
        appBar: AppBar(
          title: const Text(
            'Text To Speech',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _inputSection(),
                languages != null ? _languageDropDownSection() : const Text(""),
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  "< Change speech settings >",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                _buildSliders()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputSection() => Container(
        alignment: Alignment.topCenter,
        child: TextField(
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: "Enter text"),
          onChanged: (String value) {
            _onChange(value);
          },
        ),
      );

  Widget _languageDropDownSection() => Container(
        padding: const EdgeInsets.only(top: 30.0),
        child: DropdownButton(
          isExpanded: true,
          isDense: true,
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        ),
      );

  Widget _buildSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }

  bottomBar() => Container(
        margin: const EdgeInsets.all(10.0),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _speak,
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            FloatingActionButton(
              onPressed: _stop,
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.stop,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}
