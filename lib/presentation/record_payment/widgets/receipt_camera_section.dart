import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReceiptCameraSection extends StatefulWidget {
  final Function(XFile?) onImageCaptured;

  const ReceiptCameraSection({
    Key? key,
    required this.onImageCaptured,
  }) : super(key: key);

  @override
  State<ReceiptCameraSection> createState() => _ReceiptCameraSectionState();
}

class _ReceiptCameraSectionState extends State<ReceiptCameraSection> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  XFile? _capturedImage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = "Camera permission is required to capture receipts";
          _isInitializing = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = "No cameras available on this device";
          _isInitializing = false;
        });
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      setState(() {
        _isCameraInitialized = true;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize camera";
        _isInitializing = false;
      });
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported, continue without it
        }
      }
    } catch (e) {
      // Settings not supported, continue without them
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      widget.onImageCaptured(photo);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to capture photo";
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
    widget.onImageCaptured(null);
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInitializing) {
      return Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 2.h),
              Text(
                "Initializing camera...",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'camera_alt',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 48,
          ),
        ),
      );
    }

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: kIsWeb
            ? Image.network(
                _capturedImage!.path,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Image.asset(
                _capturedImage!.path,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceVariant(isLight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getOutlineColor(isLight),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                "Receipt Photo (Optional)",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Text(
            "Capture a photo of the payment receipt for your records",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isLight
                      ? AppTheme.onSurfaceVariantLight
                      : AppTheme.onSurfaceVariantDark,
                ),
          ),

          SizedBox(height: 3.h),

          // Camera Preview or Image Preview
          _capturedImage != null ? _buildImagePreview() : _buildCameraPreview(),

          SizedBox(height: 3.h),

          // Action Buttons
          Row(
            children: [
              if (_capturedImage != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakePhoto,
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    label: Text("Retake"),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Image is already captured and passed to parent
                    },
                    icon: CustomIconWidget(
                      iconName: 'check',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text("Use Photo"),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isCameraInitialized ? _capturePhoto : null,
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: _isCameraInitialized
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    label: Text("Capture Receipt"),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
