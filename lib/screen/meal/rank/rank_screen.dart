import 'package:flutter/material.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        centerTitle: false,
        title: const Text(
          "랭킹",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 60),
                      width: 400,
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                Image.asset('assets/images/award2.png'),
                                Text(""),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                Image.asset('assets/images/award3.png'),
                                Text("asdf"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        children: [
                          Image.asset('assets/images/award1.png'),
                          Text("경북소프트웨어고등학교 "),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
