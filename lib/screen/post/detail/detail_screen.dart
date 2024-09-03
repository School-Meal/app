import 'package:flutter/material.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({super.key});

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("세부정보"),
      ),
    );
  }
}
