/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
/// Screen that handles bus ticket payment via WebView and displays QR code
/// for successful payments
class PaymentScreen extends StatefulWidget {
  final String userId;
  final String routeId;
  final String busStopStart;
  final String busStopEnd;
  final int price;
  final String paymentMethod;

  const PaymentScreen({
    super.key,
    required this.userId,
    required this.routeId,
    required this.busStopStart,
    required this.busStopEnd,
    required this.price,
    required this.paymentMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Constants
  static const double _qrSize = 200.0;
  static const double _spacing = 20.0;
  static const double _titleFontSize = 18.0;
  static const double _subtitleFontSize = 16.0;

  // State variables
  String? _ticketId;
  String? _qrCode;
  String? _paymentUrl;
  String? _paymentStatus;
  bool _showWebView = false;
  bool _showQr = false;
  bool _isLoading = true;

  // Updated WebView controller
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _createTicket();

    // Initialize WebViewController
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (_) {
                setState(() => _isLoading = false);
              },
              onNavigationRequest: (NavigationRequest request) {
                // Check for payment confirmation callback URLs
                if (request.url.contains('payment_return') ||
                    request.url.contains('success')) {
                  _handlePaymentSuccess(context);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          );
  }

  void _createTicket() {
    context.read<PaymentBloc>().add(
      CreateTicketEvent(
        userId: widget.userId,
        routeId: widget.routeId,
        busStopStart: widget.busStopStart,
        busStopEnd: widget.busStopEnd,
        price: widget.price,
        paymentMethod: widget.paymentMethod,
      ),
    );
  }

  void _handlePaymentSuccess(BuildContext context) {
    if (_ticketId != null) {
      setState(() => _isLoading = true);
      context.read<PaymentBloc>().add(ConfirmPaymentEvent(_ticketId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán vé xe buýt'),
        centerTitle: true,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: _paymentBlocListener,
        builder: (context, state) {
          if (state is PaymentLoading || _isLoading) {
            return const _LoadingWidget();
          }

          if (_showQr && _qrCode != null) {
            return _buildQrCodeWidget();
          }

          if (_showWebView && _paymentUrl != null) {
            return _buildWebViewWidget(context);
          }

          return const _InitializingWidget();
        },
      ),
    );
  }

  void _paymentBlocListener(BuildContext context, PaymentState state) {
    if (state is CreateTicketSuccess) {
      setState(() {
        _ticketId = state.response.ticketId;
        _qrCode = state.response.qrCode;
        _paymentUrl = state.response.paymentUrl;
        _paymentStatus = state.response.paymentStatus;
        _showWebView = true;
        _showQr = false;
        _isLoading = false;
      });
    } else if (state is ConfirmPaymentSuccess) {
      setState(() {
        _paymentStatus = state.response.paymentStatus;
        _isLoading = false;

        if (state.response.paymentStatus == 'success') {
          _showWebView = false;
          _showQr = true;
          _showPaymentSuccessMessage(context);
        } else {
          _showWebView = true;
          _showQr = false;
        }
      });
    } else if (state is PaymentError) {
      setState(() => _isLoading = false);
      _showErrorMessage(context, state.message);
    }
  }

  void _showPaymentSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thanh toán thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi thanh toán: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildQrCodeWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Quét mã này để xác nhận vé:",
                style: TextStyle(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _spacing),
              _buildQrImage(),
              const SizedBox(height: _spacing),
              Text(
                "Mã vé: $_ticketId",
                style: const TextStyle(fontSize: _subtitleFontSize),
              ),
              const SizedBox(height: _spacing),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrImage() {
    try {
      if (_qrCode == null || !_qrCode!.contains('data:image')) {
        return const _QrErrorWidget();
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.memory(
          Uri.parse(_qrCode!).data!.contentAsBytes(),
          width: _qrSize,
          height: _qrSize,
          errorBuilder: (_, __, ___) => const _QrErrorWidget(),
        ),
      );
    } catch (e) {
      return const _QrErrorWidget();
    }
  }

  Widget _buildWebViewWidget(BuildContext context) {
    if (_paymentUrl != null && _paymentUrl!.isNotEmpty) {
      _webViewController.loadRequest(Uri.parse(_paymentUrl!));
    }

    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: _webViewController)),
        if (_isLoading) const LinearProgressIndicator(),
        if (_paymentStatus == "pending")
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.verified),
              label: const Text('Xác nhận thanh toán'),
              onPressed: () => _handlePaymentSuccess(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Đang xử lý thanh toán..."),
        ],
      ),
    );
  }
}

class _InitializingWidget extends StatelessWidget {
  const _InitializingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Đang khởi tạo thanh toán...", style: TextStyle(fontSize: 16)),
          SizedBox(height: 16),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _QrErrorWidget extends StatelessWidget {
  const _QrErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text("Không thể hiển thị mã QR", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}*/
