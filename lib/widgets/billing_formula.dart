import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:watermeter2/utils/smallbutton.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../main.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/alert_message.dart';
import '../../utils/new_loader.dart';
import '../../utils/custom_exception.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/customButton.dart';

class BillingFormula extends StatefulWidget {
  const BillingFormula({super.key});

  @override
  State<BillingFormula> createState() => _BillingFormulaState();
}

class _BillingFormulaState extends State<BillingFormula> {
  late DashboardBloc dashboardBloc;
  bool isDialogOpen = false; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Provider.of<ThemeNotifier>(context, listen: false)
              .currentTheme
              .splashColor,
          splashFactory: InkRipple.splashFactory,
          onTap: () async {
            String? billingFormula =
                dashboardBloc.filterData?.summaryFormattedtext;
    
            if (billingFormula == null) {
              CustomAlert.showCustomScaffoldMessenger(
                context,
                "Please select a project in the TRENDS page first.",
                AlertType.error,
              );
              return;
            }
    
            setState(() {
              isDialogOpen = true;
            });
    
            await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext dialogContext) {
                return Dialog(
                  child: BlocProvider.value(
                    value: BlocProvider.of<DashboardBloc>(context),
                    child: BillingFormulaDialog(
                      billingFormula: billingFormula,
                    ),
                  ),
                );
              },
            );
    
            if (mounted) {
              setState(() {
                isDialogOpen = false;
              });
            }
          },
          child: SvgPicture.asset(
            "assets/icons/universalcurrency.svg",
            color: isDialogOpen
                ? CommonColors.green
                : Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .basicAdvanceTextColor,
            height: UIConfig.iconSizeExtraLarge,
          ),
        ),
      ),
    );
  }
}

class BillingFormulaDialog extends StatefulWidget {
  const BillingFormulaDialog({
    super.key,
    required this.billingFormula,
  });

  final String? billingFormula;

  @override
  State<BillingFormulaDialog> createState() => _BillingFormulaDialogState();
}

class _BillingFormulaDialogState extends State<BillingFormulaDialog> {
  List<String> tiers = [];
  List<TextEditingController> amountControllers = [];
  List<TextEditingController> tierControllers = [];
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    _parseBillingFormula();
  }

  void _initializeControllers(int length) {
    for (int i = 0; i < length; i++) {
      amountControllers.add(TextEditingController());
      tierControllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }
  }

  void _parseBillingFormula() {
    String formula = widget.billingFormula ?? "0<0";
    List<String> parts = formula.split('<');
    tiers = ['Fixed'];

    String prevThreshold = "0";
    _initializeControllers(parts.length);

    for (int i = 0; i < parts.length; i++) {
      if (i == 0) {
        amountControllers[0].text = parts[i];
        tierControllers[0].text = "0";
      } else {
        List<String> subParts = parts[i].split(':');
        if (subParts.length == 2) {
          tiers.add('$prevThreshold to ${subParts[0]}');
          amountControllers[i].text = subParts[1];
          tierControllers[i].text = subParts[0];
          prevThreshold = subParts[0];
        } else if (subParts.length == 1) {
          tiers.add('$prevThreshold+');
          amountControllers[i].text = subParts[0];
        }
      }
    }
    setState(() {});
  }

  bool checkBillingFormula() {
    for (int i = 0; i < tiers.length; i++) {
      if (amountControllers[i].text.isEmpty) {
        return false;
      }
    }

    for (int i = 1; i < tierControllers.length - 1; i++) {
      if (tierControllers[i].text.isEmpty) {
        return false;
      }
    }

    for (int i = 1; i < tiers.length - 2; i++) {
      String currentThreshold = tierControllers[i].text;
      String nextThreshold = tierControllers[i + 1].text;

      double currentVal = double.tryParse(currentThreshold) ?? 0;
      double nextVal = double.tryParse(nextThreshold) ?? 0;

      if (currentVal >= nextVal) {
        return false;
      }
    }

    return true;
  }

  String _buildBillingFormula() {
    if (checkBillingFormula() == false) {
      throw CustomException("Please fill all the fields correctly");
    }
    String formula = amountControllers[0].text;

    for (int i = 1; i < tiers.length; i++) {
      if (i == tiers.length - 1) {
        
        formula += '<${amountControllers[i].text}';
      } else {
        String threshold = tierControllers[i].text;
        formula += '<$threshold:${amountControllers[i].text}';
      }
    }

    return formula;
  }

  @override
  Widget build(BuildContext context) {
    if (tiers.length == 2) {
      rightpaddingconstant = 0;
    } else {
      rightpaddingconstant = UIConfig.iconSizeLarge + UIConfig.spacingSmall.w;
    }

    final dialogWidth = UIConfig.getDesktopDialogWidth(context);
    final width = dialogWidth;

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(
        maxHeight: UIConfig.dialogMaxHeight + UIConfig.spacingXXXLarge * 2.5,
      ),
      color: Provider.of<ThemeNotifier>(context).currentTheme.dialogBG,
      child: SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .gridLineColor,
                width: UIConfig.dialogBorderWidth,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogHeader(),
                SizedBox(height: (UIConfig.spacingExtraLarge.h - UIConfig.spacingSmall).clamp(0.0, double.infinity)),
                Container(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .gridLineColor,
                    height: UIConfig.borderWidthThin),
                _buildTable(context),
                Container(
                    color: Provider.of<ThemeNotifier>(context)
                        .currentTheme
                        .gridLineColor,
                    height: UIConfig.borderWidthThin),
                SizedBox(height: UIConfig.spacingExtraLarge),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(width: UIConfig.spacingExtraLarge.w),
                      SmallButton(
                          onPressed: () {
                            if (tiers.length == 7) {
                              CustomAlert.showCustomScaffoldMessenger(
                                mainNavigatorKey.currentContext!,
                                "You can add only 5 tiers",
                                AlertType.error,
                              );
                              return;
                            }

                            setState(() {
                              String lastAmount = amountControllers[
                                      amountControllers.length - 2]
                                  .text;
                              String lastTier =
                                  tierControllers[tierControllers.length - 2]
                                      .text;
                              focusNodes.insert(
                                  focusNodes.length - 1, FocusNode());
                              amountControllers.insert(
                                  amountControllers.length - 1,
                                  TextEditingController(text: lastAmount));
                              tierControllers.insert(tierControllers.length - 1,
                                  TextEditingController(text: lastTier));
                              tiers.insert(
                                  tiers.length - 1, "$lastTier to $lastTier");
                            });
                          },
                          iconData: Icons.add,
                          bgColor: CommonColors.green),
                      Text("ADD TIER",
                          style: GoogleFonts.robotoMono(
                            fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .basicAdvanceTextColor,
                          )),
                    ],
                  ),
                ),
                SizedBox(height: UIConfig.spacingExtraLarge),
                _buildDialogActions(),
                SizedBox(height: UIConfig.spacingExtraLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    final width = UIConfig.getDesktopProjectWidth(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChamferedTextWidgetInverted(
          text: "BILLING FORMULA",
          borderColor:
              Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
          fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
        ),
        IconButton(
          icon: Icon(Icons.close,
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .gridLineColor),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  double rightpaddingconstant = UIConfig.iconSizeLarge + UIConfig.spacingSmall.w;

  Widget _buildEditableTierCell(int index) {
    final width = UIConfig.getDesktopProjectWidth(context);
    if (index == 0) {
      return Padding(
        padding: EdgeInsets.only(right: rightpaddingconstant),
        child: _buildTableCellTextField(
          TextEditingController(text: tiers[index]),
          editable: false,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (index == tiers.length - 1) {
      return Padding(
        padding: EdgeInsets.only(right: rightpaddingconstant),
        child: _buildTableCellTextField(
          tierControllers[index - 1],
          editable: false,
          textAlign: TextAlign.center,
          addPlusSuffix: true,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildTableCellTextField(
            tierControllers[index - 1],
            editable: false,
            textAlign: TextAlign.right, 
          ),
        ),
        Text(" to ",
            style: GoogleFonts.robotoMono(
              fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
              color: Provider.of<ThemeNotifier>(context)
                  .currentTheme
                  .basicAdvanceTextColor,
            )),
        Expanded(
          child: _buildTableCellTextField(
            tierControllers[index], 
            editable: true,
            textAlign: TextAlign.left, 
          ),
        ),
      ],
    );
  }

  Widget _buildTableCellTextField(TextEditingController controller,
      {bool editable = true,
      TextAlign textAlign = TextAlign.start,
      bool addPlusSuffix = false}) {
    final width = UIConfig.getDesktopProjectWidth(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  right: addPlusSuffix ? UIConfig.fontSizeMediumResponsive + 2 : 0),
              child: TextField(
                controller: controller,
                enabled: editable,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                cursorColor: Provider.of<ThemeNotifier>(context)
                    .currentTheme
                    .textfieldCursorColor,
                cursorHeight: UIConfig.textFieldCursorHeight,
                style: GoogleFonts.robotoMono(
                  fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
                  color: Provider.of<ThemeNotifier>(context)
                      .currentTheme
                      .basicAdvanceTextColor,
                  decoration: editable
                      ? TextDecoration.underline
                      : null, 
                  decorationColor: editable
                      ? Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .basicAdvanceTextColor
                          .withOpacity(UIConfig.opacityHigh)
                      : null,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: textAlign,
                decoration: InputDecoration(
                  isDense: true,
                  
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: CommonColors.blue,
                    ),
                  ),
                  border: editable
                      ? UnderlineInputBorder()
                      : InputBorder.none, 
                ),
                readOnly: !editable,
                maxLines: 1,
                scrollPhysics: AlwaysScrollableScrollPhysics(),
              ),
            ),
            if (addPlusSuffix)
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, TextEditingValue value, child) {
                  
                  final textSpan = TextSpan(
                    text: value.text,
                    style: GoogleFonts.robotoMono(
                      fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
                      color: Provider.of<ThemeNotifier>(context)
                          .currentTheme
                          .basicAdvanceTextColor,
                    ),
                  );
                  final textPainter = TextPainter(
                    text: textSpan,
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  )..layout();

                  final textWidth = textPainter.width;
                  final availableWidth = constraints.maxWidth;

                  double plusPosition;

                  if (textWidth < availableWidth) {
                    
                        plusPosition =
                        ((availableWidth - UIConfig.fontSizeMediumResponsive + 2) /
                                2) -
                            (textWidth / 2) +
                            textWidth;
                  } else {
                    
                    plusPosition = availableWidth - UIConfig.fontSizeMediumResponsive;
                  }

                  return Positioned(
                    left: plusPosition,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        "+",
                        style: TextStyle(
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .basicAdvanceTextColor,
                          fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: 18.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildTableCellTextFieldAmount(TextEditingController controller) {
    final width = UIConfig.getDesktopProjectWidth(context);
    return Center(
      child: TextField(
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        cursorColor: Provider.of<ThemeNotifier>(context)
            .currentTheme
            .textfieldCursorColor,
        cursorHeight: UIConfig.textFieldCursorHeight,
        style: GoogleFonts.robotoMono(
          fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
          color: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .basicAdvanceTextColor,
          decoration: TextDecoration.underline, 
          decorationColor: Provider.of<ThemeNotifier>(context)
              .currentTheme
              .basicAdvanceTextColor
              .withOpacity(UIConfig.opacityHigh),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        
        decoration: InputDecoration(
          isDense: true,
          contentPadding: UIConfig.paddingSymmetricVerticalSmall,
          border: InputBorder.none, 
          focusedBorder: InputBorder.none, 
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(
          color: Provider.of<ThemeNotifier>(context).currentTheme.gridLineColor,
          width: UIConfig.borderWidthThin,
        ),
      ),
      children: [
        TableRow(
          children: [
            _buildTableHeaderCell("Tier", rightpaddingconstant),
            _buildTableHeaderCell("Amount", 0),
          ],
        ),
        for (int i = 0; i < tiers.length; i++)
          TableRow(
            children: [
              Row(
                children: [
                  Expanded(child: _buildEditableTierCell(i)),
                  if (i != 0 && i != tiers.length - 1)
                    SmallButton(
                        onPressed: () {
                          setState(() {
                            tiers.removeAt(i);
                            amountControllers.removeAt(i);
                            tierControllers.removeAt(i);
                            focusNodes.removeAt(i);
                          });
                          
                        },
                        iconData: Icons.delete,
                        bgColor: CommonColors.red)
                ],
              ),
              _buildTableCellTextFieldAmount(amountControllers[i]),
            ],
          ),
      ],
    );
  }

  Widget _buildDialogActions() {
    final width = UIConfig.getDesktopProjectWidth(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButton(
          text: "CANCEL",
          isRed: true,
          dynamicWidth: true,
          fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.small, desktopWidth: width),
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        CustomButton(
          text: "SUBMIT",
          dynamicWidth: true,
          fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.small, desktopWidth: width),
          onPressed: () {
            String newFormula = _buildBillingFormula();
            
            LoaderUtility.showLoader(
              context,
              BlocProvider.of<DashboardBloc>(context)
                  .setBillingFormula(newFormula),
            ).then((s) {
              if (mounted) {
                
                CustomAlert.showCustomScaffoldMessenger(
                  mainNavigatorKey.currentContext!,
                  "Billing formula set successfully",
                  AlertType.success,
                );

                Future.microtask(() {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            }).catchError((error) {
              if (mounted) {
                
                CustomAlert.showCustomScaffoldMessenger(
                  mainNavigatorKey.currentContext!,
                  error.toString(),
                  AlertType.error,
                );

                Future.microtask(() {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildTableHeaderCell(String text, double padding) {
    final width = UIConfig.getDesktopProjectWidth(context);
    return Container(
      height: UIConfig.dropdownItemHeight,
      padding: EdgeInsets.only(right: padding),
      
      alignment: Alignment.center,
      
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: UIConfig.getResponsiveFontSize(context, ThemeNotifier.medium, desktopWidth: width),
            fontWeight: FontWeight.bold,
            color: Provider.of<ThemeNotifier>(context)
                .currentTheme
                .basicAdvanceTextColor,
          ),
        ),
      ),
    );
  }
}
