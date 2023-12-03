import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class Result extends StatefulWidget {
  const Result({superKey, Key? key}) : super(key: superKey);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  final Dio dio = Dio();
  late Response response;
  String responseData = '';

  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;
  String? responseGpt = '';

  Future<void> fetchGPT3Response(String responseData) async {
    setState(() {
      isLoading = true;
    });

    try {
      const apiKey = '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';
      const apiUrl = 'https://api.openai.com/v1/chat/completions';

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $apiKey';

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing dialog on tap outside
        builder: (BuildContext dialogContext) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          );
        },
      );

      Response response = await dio.post(
        apiUrl,
        data: {
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Suggestion the smoothy, 3 Menu and preparation by using these ingredients: $responseData"
            }
          ],
          "temperature": 0.7
        },
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final generatedText = data["choices"][0]["message"]["content"];
        setState(() {
          isLoading = false;
          responseGpt = generatedText;
        });
      } else {
        setState(() {
          isLoading = false;
          responseGpt = 'Failed to fetch GPT-3 response';
        });
      }
    } catch (e) {
      // Handle DioError or other exceptions here
      setState(() {
        isLoading = false;
        responseGpt = 'Failed to fetch GPT-3 response: $e';
      });
    }
  }

  File? _imageFile;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _sentImage(_imageFile!, context);
        debugPrint(pickedFile.path);
        debugPrint(_imageFile.toString());
      } else {
        if (kDebugMode) {
          print('No image selected.');
        }
      }
    });
  }

  Future<void> _sentImage(File imageFile, BuildContext context) async {
    Dio dio = Dio();
    String url = 'https://smoothie.thistine.com/detect';

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog on tap outside
      builder: (BuildContext dialogContext) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    try {
      FormData formData = FormData.fromMap({
        'image':
            await MultipartFile.fromFile(imageFile.path, filename: 'image.jpg'),
      });

      Response response = await dio.post(url, data: formData);

      Navigator.pop(context); // Close loading dialog
      debugPrint(response.toString());

      setState(() {
        responseData = response.toString();
      });
      debugPrint(responseData);
    } catch (e) {
      // Handle DioError or other exceptions here
      debugPrint("Error: $e");
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBar(
              action: SnackBarAction(
                label: 'Ok',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              content: Text('Can not detect image. $e')),
        ),
      );
    }
  }

  Widget _buildResizedImage(File? file) {
    if (file == null) {
      return Container(
          width: 250,
          height: 250,
          color: const Color.fromARGB(255, 250, 232, 238),
          child: const Center(
            child: Text(
              'Please pick a photo',
            ),
          ));
    } else {
      return SizedBox(
          width: 250, height: 250, child: Image.file(file, fit: BoxFit.cover));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: _buildResizedImage(_imageFile)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            children: [
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    pickImage(ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    backgroundColor:
                        Color.fromRGBO(228, 93, 93, 100), // <-- Button color
                    // <-- Splash color
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Color.fromARGB(255, 255, 255, 255), size: 30),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    pickImage(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: const Color.fromRGBO(
                        228, 93, 93, 100), // <-- Button color
                    // <-- Splash color
                  ),
                  child: const Icon(Icons.image,
                      color: Color.fromARGB(255, 255, 255, 255), size: 30),
                ),
              ),
            ],
          ),
        ),
        responseData != '' ? Text("Result : $responseData") : Container(),
        Column(
          children: [
            TextButton(
              onPressed: () {
                if (responseData != '') {
                  fetchGPT3Response(responseData);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Can not generate suggestion.'),
                      action: SnackBarAction(
                        label: 'Ok',
                        onPressed: () {
                          // Some code to undo the change.
                        },
                      ),
                    ),
                  );
                }
              },
              child: const Text('Generate Suggestion'),
            ),
          ],
        ),
        responseGpt == ''
            ? Container()
            : AlertDialog(
                title: const Text('Suggestions Menu'),
                content:
                    SizedBox(width: double.infinity, child: Text(responseGpt!)),
                backgroundColor: Color.fromRGBO(228, 93, 93, 100),
              )
      ],
    );
  }
}
