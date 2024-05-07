import 'dart:convert';
import 'package:chatgpt_clone/model/response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController promptController;
  String resposeTxt = '';
  late ResponseModel _responseModel;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff343531),
      appBar: AppBar(
        backgroundColor: const Color(0xff343531),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'F',
              style: GoogleFonts.acme(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            Text('lutter',
                style: GoogleFonts.acme(color: Colors.white, fontSize: 30)),
            const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 5.0,
              ),
            ),
            Text('G',
                style: GoogleFonts.acme(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            Text('pt',
                style: GoogleFonts.acme(color: Colors.white, fontSize: 30)),
          ],
        ),
      ),
      body: Container(
        child: ListView(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PromptBldr(responseTxt: resposeTxt),
              TextFormFieldBldr(
                  promptController: promptController, btnFun: completionFun),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> completionFun() async {
    setState(() => resposeTxt = 'Loading...');
    final response =
        await http.post(Uri.parse('https://api.openai.com/v1/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${dotenv.env['token']}'
            },
            body: jsonEncode(
              {
                "model": "text-davinci-003",
                "prompt": promptController.text,
                "max_tokens": 250,
                "temperature": 0,
                "top_p": 1,
              },
            ));

    final responsebody = jsonDecode(response.body);

    if (kDebugMode) {
      print("response from api is =>  $responsebody");
    }
    final responsemodel = ResponseModel.fromJson(responsebody);
    if (kDebugMode) {
      print("response from api is =>  $responsemodel");
    }

    setState(() {
      _responseModel = responsemodel;
      resposeTxt = _responseModel.text;
      debugPrint(resposeTxt);
    });
  }
}

class PromptBldr extends StatelessWidget {
  const PromptBldr({super.key, required this.responseTxt});
  final String responseTxt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff434654),
      height: 550,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Text(
              responseTxt,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class TextFormFieldBldr extends StatelessWidget {
  const TextFormFieldBldr(
      {super.key, required this.promptController, required this.btnFun});
  final TextEditingController promptController;
  final Function btnFun;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 1, right: 1, bottom: 10, top: 18),
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                cursorColor: Colors.white,
                controller: promptController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xff444653),
                    ),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff445653),
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xff445653),
                  hintStyle: const TextStyle(color: Colors.grey),
                  hintText: 'Ask me anything!',
                ),
              ),
            ),
            Container(
              color: const Color(0xff19bc95),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IconButton(
                    //iconSize: 38,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () => btnFun()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
