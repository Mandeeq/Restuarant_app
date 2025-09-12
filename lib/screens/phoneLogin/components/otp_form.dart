import 'package:flutter/material.dart';
import '../../../entry_point.dart';
import '../../../services/api_service.dart';

import 'package:form_field_validator/form_field_validator.dart';

import '../../../theme.dart';

class OtpForm extends StatefulWidget {
  final String phoneNumber;

  const OtpForm({super.key, required this.phoneNumber});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  final _otp1Controller = TextEditingController();
  final _otp2Controller = TextEditingController();
  final _otp3Controller = TextEditingController();
  final _otp4Controller = TextEditingController();
  final _otp5Controller = TextEditingController();
  final _otp6Controller = TextEditingController();

  FocusNode? _pin1Node;
  FocusNode? _pin2Node;
  FocusNode? _pin3Node;
  FocusNode? _pin4Node;
  FocusNode? _pin5Node;
  FocusNode? _pin6Node;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pin1Node = FocusNode();
    _pin2Node = FocusNode();
    _pin3Node = FocusNode();
    _pin4Node = FocusNode();
    _pin5Node = FocusNode();
    _pin6Node = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _pin1Node!.dispose();
    _pin2Node!.dispose();
    _pin3Node!.dispose();
    _pin4Node!.dispose();
    _pin5Node!.dispose();
    _pin6Node!.dispose();
    _otp1Controller.dispose();
    _otp2Controller.dispose();
    _otp3Controller.dispose();
    _otp4Controller.dispose();
    _otp5Controller.dispose();
    _otp6Controller.dispose();
  }

  void _handleVerifyOtp() {
    _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Collect OTP from all fields
      final otp =
          '${_otp1Controller.text}${_otp2Controller.text}${_otp3Controller.text}${_otp4Controller.text}${_otp5Controller.text}${_otp6Controller.text}';

      if (otp.length != 6) {
        throw Exception('Please enter a 6-digit OTP');
      }

      await ApiService.verifyPhoneOtp(widget.phoneNumber, otp);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const EntryPoint(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp1Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin2Node!.requestFocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  autofocus: true,
                  maxLength: 1,
                  focusNode: _pin1Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp2Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin3Node!.requestFocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  maxLength: 1,
                  focusNode: _pin2Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp3Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin4Node!.requestFocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  maxLength: 1,
                  focusNode: _pin3Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp4Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin5Node!.requestFocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  maxLength: 1,
                  focusNode: _pin4Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp5Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin6Node!.requestFocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  maxLength: 1,
                  focusNode: _pin5Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
              SizedBox(
                width: 40,
                height: 48,
                child: TextFormField(
                  controller: _otp6Controller,
                  onChanged: (value) {
                    if (value.length == 1) _pin6Node!.unfocus();
                  },
                  validator: RequiredValidator(errorText: '').call,
                  maxLength: 1,
                  focusNode: _pin6Node,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding * 2),
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              ),
              child: Text(
                _isLoading ? "Verifying..." : "Continue",
                style: kButtonTextStyle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
