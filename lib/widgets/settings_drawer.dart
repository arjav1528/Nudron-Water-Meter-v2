// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_switch/flutter_switch.dart';import 'package:provider/provider.dart';
//
// import 'package:watermeter2/core/theme/theme_manager.dart';
// import '../containers/MenuBarContainer.dart';
//
// class SettingsDrawer extends StatefulWidget {
//   const SettingsDrawer({Key? key}) : super(key: key);
//
//   @override
//   _SettingsDrawerState createState() {
//     return _SettingsDrawerState();
//   }
// }
//
// class _SettingsDrawerState extends State<SettingsDrawer> {
//
//   bool status = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//             padding: const EdgeInsets.all(9.6),
//             child: Column(
//               children: [
//                 const MenuBarContainer("Display Settings", double.infinity, 36.19),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text("Dark Mode"),
//                       FlutterSwitch(
//                         activeColor: const Color(0xff2186a9),
//                         inactiveColor: const Color(0xffffffff),
//                         inactiveToggleColor: const Color(0xffbfbfbf),
//                         width: 40.0,
//                         height: 20.0,
//                         valueFontSize: 0.0,
//                         toggleSize: 17.0,
//                         value: Provider.of<ThemeProvider>(context, listen: true)
//                             .isDarkMode,
//                         borderRadius: 30.0,
//                         switchBorder: Border.all(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .onPrimaryContainer,
//                             width: 1),
//                         padding: 1,
//                         showOnOff: false,
//                         onToggle: (val) {
//                           if (kDebugMode) {
//                             print(val);
//                           }
//                           Provider.of<ThemeProvider>(context, listen: false)
//                               .toggleTheme(val);
//                           // _themeManager.toggleTheme(val);
//                           // setState(() {
//                           //   status = val;
//                           // });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text("Font Size"),
//                       Container(
//                         // height: 30.78,
//                         // width: 75,
//                         decoration: BoxDecoration(
//                             color:
//                                 Theme.of(context).drawerTheme.backgroundColor,
//                             border: Border.all(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .onPrimaryContainer,
//                                 width: 1),
//                             borderRadius: const BorderRadius.all(Radius.circular(4))),
//                         child: DropdownButtonHideUnderline(
//                           child: ButtonTheme(
//                             // minWidth: 60,
//                             alignedDropdown: true,
//
//                             child: DropdownButton2<String>(
//                               isExpanded: true,
//                               isDense: true,
//                               // elevation: 0,
//                               // dropdownColor:Color(0xff464c5b),
//                               value: Provider.of<ThemeProvider>(context,
//                                       listen: false)
//                                   .dropDownValueForTextSize,
//                               icon: Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Theme.of(context).iconTheme.color,
//                                 size: 14,
//                               ),
//                               style: Theme.of(context).textTheme.bodyMedium,
//                               // underline: Container(
//                               //   height: 2,
//                               //   color: Colors.deepPurpleAccent,
//                               // ),
//                               onChanged: (String? newValue) {
//                                 if (newValue == "Small") {
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setDropDownByTextSize("Small");
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setScaleFactor(1, 30);
//                                 } else if (newValue == "Normal") {
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setDropDownByTextSize("Normal");
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setScaleFactor(1.1, 32);
//                                 } else if (newValue == "Large") {
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setDropDownByTextSize("Large");
//                                   Provider.of<ThemeProvider>(context,
//                                           listen: false)
//                                       .setScaleFactor(1.2, 35);
//                                 }
//                                 setState(() {});
//                               },
//                               buttonHeight: 30,
//                               buttonWidth: 100,
//                               dropdownPadding: EdgeInsets.zero,
//                               itemHeight: 30,
//                               dropdownElevation: 0,
//                               dropdownDecoration: BoxDecoration(
//                                   color:
//                                       Theme.of(context).dialogBackgroundColor,
//                                   border: Border.all(
//                                       color: Theme.of(context)
//                                           .colorScheme
//                                           .onPrimaryContainer,
//                                       width: 1),
//                                   borderRadius:
//                                       const BorderRadius.all(Radius.circular(4))),
//                               // dropdownBorder: null,
//                               items: const [
//                                 DropdownMenuItem<String>(
//                                   alignment: Alignment.centerLeft,
//                                   value: 'Small',
//                                   child: Text(
//                                     "Small",
//                                     style: TextStyle(fontSize: 12.32),
//                                   ),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   alignment: Alignment.centerLeft,
//                                   value: 'Normal',
//                                   child: Text(
//                                     "Normal",
//                                     style: TextStyle(fontSize: 12.32),
//                                   ),
//                                 ),
//                                 DropdownMenuItem<String>(
//                                   alignment: Alignment.centerLeft,
//                                   value: 'Large',
//                                   child: Text(
//                                     "Large",
//                                     style: TextStyle(fontSize: 12.32),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//               ],
//             )),
//       ],
//     );
//   }
// }
