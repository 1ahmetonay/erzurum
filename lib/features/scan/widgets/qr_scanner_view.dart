import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum ScanCameraMode { qr, barcode, photo }

class QrScannerView extends StatefulWidget {
  const QrScannerView({
    required this.onQrDetected,
    this.mode = ScanCameraMode.qr,
    this.isProcessing = false,
    super.key,
  });

  final ValueChanged<String> onQrDetected;
  final ScanCameraMode mode;
  final bool isProcessing;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  late final MobileScannerController _controller;

  String? _lastCode;
  DateTime? _lastDetectedAt;
  var _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: _formatsForMode(widget.mode),
    );
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _handleDetect,
              errorBuilder: (context, error, child) {
                return _ScannerError(message: _scannerErrorMessage(error));
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textPrimary, width: 10),
              ),
            ),
            Center(
              child: Container(
                width: _frameWidth,
                height: _frameHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_frameRadius),
                  border: Border.all(color: AppColors.primaryFixed, width: 4),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Row(
                children: [
                  _ScannerIconButton(
                    icon: Icons.flash_on,
                    tooltip: 'Flaş',
                    onPressed: () => _controller.toggleTorch(),
                  ),
                  const Spacer(),
                  _ScannerIconButton(
                    icon: Icons.cameraswitch_outlined,
                    tooltip: 'Kamerayı değiştir',
                    onPressed: () => _controller.switchCamera(),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Text(
                _instructionText,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            if (widget.isProcessing || _isProcessing)
              Container(
                color: AppColors.textPrimary.withValues(alpha: 0.45),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  void _handleDetect(BarcodeCapture capture) {
    if (widget.mode == ScanCameraMode.photo) return;
    if (widget.isProcessing || _isProcessing) return;

    String? code;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        code = value;
        break;
      }
    }
    if (code == null) return;

    final now = DateTime.now();
    final isRecentDuplicate =
        _lastCode == code &&
        _lastDetectedAt != null &&
        now.difference(_lastDetectedAt!) < const Duration(seconds: 3);
    if (isRecentDuplicate) return;

    setState(() {
      _isProcessing = true;
      _lastCode = code;
      _lastDetectedAt = now;
    });
    widget.onQrDetected(code);

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
    });
  }

  String _scannerErrorMessage(MobileScannerException error) {
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      return 'Kamera izni verilmedi. Ayarlardan kamera erişimine izin ver.';
    }
    return switch (widget.mode) {
      ScanCameraMode.qr =>
        'QR tarama bu platformda desteklenmeyebilir. Demo QR butonlarını kullanabilirsin.',
      ScanCameraMode.barcode =>
        'Barkod tarama bu platformda desteklenmeyebilir. Demo barkod kartını kullanabilirsin.',
      ScanCameraMode.photo =>
        'Fotoğraf önizleme bu platformda desteklenmeyebilir. Demo foto butonunu kullanabilirsin.',
    };
  }

  List<BarcodeFormat> _formatsForMode(ScanCameraMode mode) {
    return switch (mode) {
      ScanCameraMode.qr => const [BarcodeFormat.qrCode],
      ScanCameraMode.barcode => const [
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.codabar,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.itf,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
      ScanCameraMode.photo => const [BarcodeFormat.qrCode],
    };
  }

  double get _frameWidth {
    return switch (widget.mode) {
      ScanCameraMode.qr => 210,
      ScanCameraMode.barcode => 260,
      ScanCameraMode.photo => 250,
    };
  }

  double get _frameHeight {
    return switch (widget.mode) {
      ScanCameraMode.qr => 210,
      ScanCameraMode.barcode => 116,
      ScanCameraMode.photo => 250,
    };
  }

  double get _frameRadius {
    return switch (widget.mode) {
      ScanCameraMode.qr => 24,
      ScanCameraMode.barcode => 18,
      ScanCameraMode.photo => 28,
    };
  }

  String get _instructionText {
    return switch (widget.mode) {
      ScanCameraMode.qr => 'QR kodu çerçeve içine hizala',
      ScanCameraMode.barcode => 'Barkodu çerçeve içine hizala',
      ScanCameraMode.photo => 'Fotoğraf için atığı çerçeveye hizala',
    };
  }
}

class _ScannerIconButton extends StatelessWidget {
  const _ScannerIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(onPressed: onPressed, icon: Icon(icon)),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary),
      ),
    );
  }
}
