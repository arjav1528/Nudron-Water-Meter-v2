// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import 'package:watermeter2/core/utils/alert_message.dart';
// import 'package:watermeter2/domain/view_model/loginPostRequests.dart';
//
// class VerifyCode extends StatefulWidget {
//   VerifyCode(
//       {Key? key, required this.isMobile, required this.mobileNumberOrEmail})
//       : super(key: key);
//   bool isMobile;
//   String mobileNumberOrEmail;
//
//   @override
//   State<VerifyCode> createState() => _VerifyCodeState();
// }
//
// class _VerifyCodeState extends State<VerifyCode> {
//   TextEditingController otpFieldController = TextEditingController();
//
//   @override
//   void initState() {
//     SystemChrome.setPreferredOrientations(
//         [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back,
//               color: Theme.of(context).textTheme.bodyMedium?.color),
//           onPressed: () {
//             if (mounted) Navigator.of(context).pop();
//           },
//         ),
//         title: Text(
//           "Verify your ${widget.isMobile ? 'Mobile' : 'Email'}",
//           style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                 fontSize: 20,
//               ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             minHeight: MediaQuery.of(context).size.height -
//                 AppBar().preferredSize.height -
//                 24,
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 40),
//                   // SvgPicture.asset('assets/images/google_auth_logo.svg',
//                   //     width: min(width / 2.5, height / 2.5)),
//                   // const SizedBox(height: 40),
//                   Text(
//                     "Enter the 6-digit code sent to your ${widget.isMobile ? "Mobile" : "Email"} ${widget.mobileNumberOrEmail}",
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                           fontSize: 16,
//                         ),
//                   ),
//                   const SizedBox(height: 25),
//                   PinCodeTextField(
//                     length: 6,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//                     ],
//                     obscureText: false,
//                     animationType: AnimationType.fade,
//                     pinTheme: PinTheme(
//                       shape: PinCodeFieldShape.underline,
//                       borderRadius: BorderRadius.circular(5),
//                       fieldHeight: 50,
//                       fieldWidth: 40,
//                       activeFillColor:
//                           Theme.of(context).textTheme.bodyMedium!.color!,
//                       activeColor: const Color(0xff19647e),
//                       selectedColor:
//                           Theme.of(context).drawerTheme.backgroundColor,
//                       inactiveColor:
//                           Theme.of(context).textTheme.bodyMedium!.color!,
//                       // inactiveColor: Theme.of(context).drawerTheme.backgroundColor,
//                       selectedFillColor:
//                           Theme.of(context).drawerTheme.backgroundColor,
//                     ),
//                     animationDuration: const Duration(milliseconds: 300),
//                     backgroundColor:
//                         Theme.of(context).drawerTheme.backgroundColor,
//                     controller: otpFieldController,
//                     onCompleted: (v) {
//                       if (kDebugMode) {
//                         print("Completed");
//                       }
//                     },
//                     beforeTextPaste: (text) {
//                       //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
//                       //but you can show anything you want here, like your pop up saying wrong paste format or etc
//                       return true;
//                     },
//                     appContext: context,
//                     onChanged: (String value) {},
//                   ),
//                   const SizedBox(height: 40),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: Theme.of(context).elevatedButtonTheme.style,
//                       child: const Text(
//                         "Verify",
//                         style: TextStyle(
//                             fontFamily: 'Roboto',
//                             color: Color(0xffffffff),
//                             fontSize: 12.8),
//                       ),
//                       onPressed: () async {
//                         if (otpFieldController.text.length == 6) {
//                           LoginPostRequests.verifyEmailPhone(
//                                   widget.isMobile
//                                       ? ''
//                                       : otpFieldController.text,
//                                   widget.isMobile
//                                       ? otpFieldController.text
//                                       : '')
//                               .then((a) {
//                             if (mounted) {
//                               Navigator.of(context).pop();
//                             }
//                           }).catchError((e) {
//                             CustomAlert.showCustomScaffoldMessenger(
//                                 context, e.toString(), AlertType.error);
//                           });
//                         } else {
//                           ScaffoldMessenger.of(context)
//                               .showSnackBar(const SnackBar(
//                             content: Text("Please enter a valid code"),
//                             duration: Duration(seconds: 3),
//                           ));
//                         }
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
