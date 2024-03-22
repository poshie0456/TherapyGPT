import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xff121212),
        appBarTheme: AppBarTheme(
          color: Color(0xff121212),
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  String OpenAiKey = ''; // ADDD HEREEEE
  bool isLoading = false;
  String content = "";
  final ScrollController _scrollController = ScrollController();

  Future<String> _sendMessage(String prompt) async {
    setState(() {
      isLoading = true;
      // Add a typing indicator
      messages.add({
        'role': 'assistant',
        'content': 'Typing...',
      });
    });

    try {
      // Send the user's message to the model
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OpenAiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        // Remove the typing indicator message
        messages.removeWhere((msg) => msg['content'] == 'Typing...');

        // Add the actual assistant response
        messages.add({
          'role': 'assistant',
          'content': content,
        });
      }

      // Ensure that loading indicator is hidden after response is received
      setState(() {
        isLoading = false;
      });

      return content;
    } catch (e) {
      // Handle exceptions
      setState(() {
        isLoading = false;
      });
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "HelpGPT",
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5),
                ),
                Lottie.asset("assets/anim.json", height: 50)
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: ListView.separated(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final bool isWaitingForResponse =
                      isLoading && index == messages.length - 1;

                  return Align(
                      alignment: messages[index]['role'] == 'assistant'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: !isWaitingForResponse
                          ? Container(
                              width: 330,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: messages[index]['role'] == 'assistant'
                                      ? Color(0xff4ECDC4)
                                      : Color(0xff1E1E1E),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 2,
                                        color: Colors.black12)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    messages[index]['role'] == 'assistant'
                                        ? "Chatbot"
                                        : "Meneer",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                    thickness: 0.4,
                                  ),
                                  // Or any other loading indicator
                                  Text(
                                    messages[index]['content']!,
                                    style: GoogleFonts.montserrat(
                                        color: messages[index]['role'] ==
                                                'assistant'
                                            ? Color(0xffFFFFFF)
                                            : Color(0xffD1D1D1)),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              width: 330,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: messages[index]['role'] == 'assistant'
                                      ? Color(0xff4ECDC4)
                                      : Color(0xff1E1E1E),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 2,
                                        color: Colors.black12)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    messages[index]['role'] == 'assistant'
                                        ? "Chatbot"
                                        : "Meneer",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                    thickness: 0.4,
                                  ),
                                  // Or any other loading indicator
                                  Text(
                                    messages[index]['content']!,
                                    style: GoogleFonts.montserrat(
                                        color: messages[index]['role'] ==
                                                'assistant'
                                            ? Color(0xffFFFFFF)
                                            : Color(0xffD1D1D1)),
                                  ),
                                ],
                              ),
                            ));
                },
                separatorBuilder: (context, index) {
                  return SizedBox(height: 15);
                },
              ),
            ),
          ),
          Container(
            height: 100,
            decoration: BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your message...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xff4ECDC4),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 3,
                              blurRadius: 2,
                              color: Colors.black38)
                        ]),
                    child: IconButton(
                      onPressed: () {
                        _sendMessage(_controller.text);

                        _controller.clear();
                      },
                      icon: Icon(Icons.send),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
