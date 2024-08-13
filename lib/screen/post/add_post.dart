// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';

// class AddPost extends StatefulWidget {
//   const AddPost({super.key});

//   @override
//   State<AddPost> createState() => _AddPostState();
// }

// class _AddPostState extends State<AddPost> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//   File? _image;
//   String? _token;

//   @override
//   void initState() {
//     super.initState();
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/token.txt';
//     final file = File(path);
//     if (await file.exists()) {
//       String token = await file.readAsString();
//       print('Loaded token: $token'); // 디버깅을 위한 출력
//       setState(() {
//         _token = token;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _submitPost() async {
//     if (_formKey.currentState!.validate() && _token != null) {
//       final url = Uri.parse('${dotenv.env['API_URL']}/post/');
//       var request = http.MultipartRequest('POST', url);

//       // Add headers
//       request.headers['Authorization'] = 'Bearer $_token';

//       // Add text fields
//       request.fields['title'] = _titleController.text;
//       request.fields['content'] = _contentController.text;

//       // Add image file
//       if (_image != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath('image', _image!.path),
//         );
//       }

//       final response = await request.send();

//       if (response.statusCode == 201) {
//         final responseBody = await response.stream.bytesToString();
//         final responseData = json.decode(responseBody);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Post created successfully')),
//         );
//         Navigator.of(context).pop(responseData);
//       } else {
//         // Handle error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to create post: ${response.statusCode}')),
//         );
//       }
//     } else if (_token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No token found, please log in first')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Post'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.send),
//             onPressed: _submitPost,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(labelText: 'Title'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _contentController,
//                 decoration: InputDecoration(labelText: 'Content'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter content';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: Text('Pick Image'),
//               ),
//               if (_image != null)
//                 Image.file(
//                   _image!,
//                   height: 200,
//                   fit: BoxFit.cover,
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
