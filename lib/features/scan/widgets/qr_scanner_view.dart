import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({
    required this.onQrDetected,
    this.isProcessing = false,
    super.key,
  });

  final ValueChanged<String> onQrDetected;
  final bool isProcessing;

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  String? _lastCode;
  DateTime? _lastDetectedAt;
  var _isProcessing = false;

  @override
  void dispose() {
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
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primaryLight, width: 4),
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
                'QR kodu çerçevenin içine hizala',
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
    return 'QR tarama bu platformda desteklenmeyebilir. Demo QR butonlarını kullanabilirsin.';
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
