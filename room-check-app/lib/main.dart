import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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
      home: const MyHomePage(title: '내 첫 번째 Fluttter 앱'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            _isCameraInitialized && _cameraController != null
                ? SizedBox(
                    width: 300,
                    height: 400,
                    child: CameraPreview(_cameraController!),
                  )
                : const Text('카메라를 초기화 중입니다...'),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('사진 찍기'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
