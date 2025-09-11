// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../../theme.dart';
// import '../../models/order_model.dart';
// import '../../models/payment_model.dart';
// import '../../services/api_service.dart';
// import '../../utils/image_utils.dart';

// class PaymentScreen extends StatefulWidget {
//   final Order order;

//   const PaymentScreen({super.key, required this.order});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final _phoneController = TextEditingController();
//   bool _isLoading = false;
//   bool _paymentInitiated = false;
//   String? _paymentId;
//   Timer? _statusCheckTimer;

//   @override
//   void initState() {
//     super.initState();
//     if (ApiService.currentUser?.phone != null) {
//       _phoneController.text = ApiService.currentUser!.phone!;
//     }
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _statusCheckTimer?.cancel();
//     super.dispose();
//   }

//   double get _totalAmount {
//     return widget.order.items.fold(0.0, (sum, item) {
//       return sum + (item.price * item.quantity);
//     });
//   }

//   Future<void> _initiatePayment() async {
//     if (_phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid phone number'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final response = await ApiService.initiateMpesaPayment(
//         orderId: widget.order.id!,
//         phoneNumber: _phoneController.text.trim(),
//       );

//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _paymentInitiated = true;
//           _paymentId = response.data?.paymentId;
//         });

//         // Start checking payment status
//         _startPaymentStatusCheck();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Payment failed: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _startPaymentStatusCheck() {
//     if (_paymentId == null) return;

//     _statusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
//       try {
//         final paymentData = await ApiService.checkPaymentStatus(_paymentId!);

//         if (mounted) {
//           if (paymentData.status == 'completed') {
//             timer.cancel();
//             _showPaymentSuccessDialog();
//           } else if (paymentData.status == 'failed') {
//             timer.cancel();
//             _showPaymentFailedDialog();
//           }
//         }
//       } catch (e) {
//         // Continue checking
//       }
//     });
//   }

//   void _showPaymentSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Payment Successful!'),
//         content: const Text('Your payment has been processed successfully. You will receive a confirmation shortly.'),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context); // Go back to previous screen
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPaymentFailedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Payment Failed'),
//         content: const Text('Your payment was not successful. Please try again.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _initiatePayment();
//             },
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment'),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(defaultPadding),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(defaultPadding),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Order Summary',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     ...widget.order.items.map((item) => Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                   child:
//                                       Text('${item.name} x${item.quantity}')),
//                               Text(
//                                   'KES ${(item.price * item.quantity).toStringAsFixed(2)}'),
//                             ],
//                           ),
//                         )),
//                     const Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text('Total',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text('KES ${_totalAmount.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: primaryColor)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(defaultPadding),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.phone_android, color: Colors.green),
//                         const SizedBox(width: 8),
//                         const Text('M-Pesa Payment',
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     const Text('Phone Number',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       decoration: const InputDecoration(
//                         hintText: 'Enter M-Pesa phone number (e.g., 0712345678)',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.phone),
//                         suffixIcon: Icon(Icons.phone_android, color: Colors.green),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _initiatePayment,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white)))
//                     : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.phone_android, size: 20),
//                           const SizedBox(width: 8),
//                           const Text('Pay with M-Pesa',
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//               ),
//             ),
//             if (_paymentInitiated) ...[
//               const SizedBox(height: 16),
//               Card(
//                 color: Colors.blue.shade50,
//                 child: Padding(
//                   padding: const EdgeInsets.all(defaultPadding),
//                   child: Row(
//                     children: [
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                       const SizedBox(width: 12),
//                       const Expanded(
//                         child: Text(
//                           'Checking payment status...',
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 16),
//             Card(
//               color: Colors.orange.shade50,
//               child: Padding(
//                 padding: const EdgeInsets.all(defaultPadding),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.orange.shade700),
//                         const SizedBox(width: 8),
//                         const Text('M-Pesa Payment Instructions',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       '• Ensure your phone number is registered with M-Pesa\n'
//                       '• You will receive an STK push notification\n'
//                       '• Enter your M-Pesa PIN when prompted\n'
//                       '• Payment will be processed automatically\n'
//                       '• You will receive an SMS confirmation',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
