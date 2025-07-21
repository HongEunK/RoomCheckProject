import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart'; //image_picker를 쓰기 위한 import
import 'package:http/http.dart' as http; //이미지를 서버로 전송(post)하기 위한 패키지
import 'dart:convert'; //base64로 encode해서 서버로 보내기 위해 선언

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Check App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Room Check App'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// class AddProductScreen extends StatefulWidget {
//   final File? image;

//   const AddProductScreen({Key? key, this.image}) : super(key: key);

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  File? _image; // 이미지 담을 변수
  final ImagePicker picker = ImagePicker(); // 인스턴스

  @override
  void initState() {
    super.initState();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.medium,
      );
      _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized) return;
    try {
      final image = await _cameraController!.takePicture();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('사진 저장 경로: ${image.path}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('사진 촬영 실패: $e')));
    }
  }

  Future getImage(ImageSource imageSource) async {
    // 이미지를 가져오기 위한 코드
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      // 사용자가 이미지를 선택했는지 확인
      setState(() {
        // UI를 갱신?
        _image = File(pickedFile.path); // 이미지를 파일 형식으로 변환해 _image라는 변수에 저장
      });
    }
  }

  // 클릭시 파일(갤러리)에 있는 이미지 불러오기
  ElevatedButton _buildElevatedButton(String label, ImageSource imageSource) {
    return ElevatedButton.icon(
      onPressed: () => getImage(imageSource),
      icon: const Icon(Icons.image),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  // photoArea를 사용하여 불러온 이미지 보여주기
  // Widget _buildPhotoArea() {
  //   return _image != null
  //       ? SizedBox(width: 300, height: 300, child: Image.file(_image!))
  //       : Container(width: 300, height: 300, color: Colors.grey);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상담의 앱 바
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title), // 위에서 설정한 title 가져오기
      ),
      body: SingleChildScrollView(
        // 스크롤 가능하도록
        padding: const EdgeInsets.all(16),
        child: Column(
          // 위젯을 세로로 정렬
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 모서리 둥글게
              ),
              child: Padding(
                padding: const EdgeInsets.all(16), // 상, 하, 좌, 우 여백 16을 준다
                child: Column(
                  children: [
                    const Text('버튼을 누른 횟수:', style: TextStyle(fontSize: 18)),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    _isCameraInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 300,
                              child: CameraPreview(_cameraController!),
                            ),
                          )
                        : const Text('카메라 초기화 중...'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _takePicture, // 누르면 takePicture가 불러와짐
                      icon: const Icon(Icons.camera),
                      label: const Text('사진 찍기'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // if (_image != null) // 이미지가 null이 아니라면 이미지를 보여주는 함수 이지만 오류로 주석처리
                    //   Column(
                    //     children: [
                    //       const Text(
                    //         '선택한 이미지:',
                    //         style: TextStyle(fontSize: 16),
                    //       ),
                    //       const SizedBox(height: 10),
                    //       ClipRRect(
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Image.file(_image!, height: 200),
                    //       ),
                    //     ],
                    //   ),
                    const SizedBox(height: 20),
                    _buildElevatedButton("갤러리에서 불러오기", ImageSource.gallery),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
