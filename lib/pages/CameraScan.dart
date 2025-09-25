import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/pages/view/CustomAppBar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class Camerascan extends StatefulWidget {
  const Camerascan({super.key});

  @override
  State<Camerascan> createState() => _CamerascanState();
}

class _CamerascanState extends State<Camerascan> {
  late MobileScannerController _mobileScannerController = MobileScannerController();
  final ImagePicker picker = ImagePicker();
  bool _isScanned = false;
  bool _isFlash = false;

  @override
  void initState() {
    super.initState();
    _mobileScannerController = MobileScannerController();
  }

  @override
  void dispose() {
    super.dispose();
    _mobileScannerController.dispose();
  }

  // 闪光灯
  void _flshToggle() {
    _mobileScannerController.toggleTorch();
    setState(() {
      _isFlash = !_isFlash;
    });
  }

  // 相册
  void _albumPermissions() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint('你选择了图片');
    } else {
      debugPrint('你没有选择图片');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "扫描二维码",
        actions: [
          GestureDetector(child: _isFlash ? Icon(Icons.flash_off) : Icon(Icons.flash_on), onTap: () => _flshToggle()),
          SizedBox(width: 12.w),
          GestureDetector(onTap: () => _albumPermissions(), child: Icon(Icons.photo)),
          SizedBox(width: 14.w),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // const Spacer(),
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: _mobileScannerController,
                    fit: BoxFit.cover,
                    onDetect: (capture) {
                      if (_isScanned) return;
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final String? code = barcode.rawValue;
                        if (code != null) {
                          setState(() => _isScanned = true);
                          Get.back(result: code);
                          HapticFeedback.heavyImpact();
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '扫一扫识别收款地址，连接 DApp 或向商户付款',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
