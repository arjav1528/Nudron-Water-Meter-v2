import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/utils/pok.dart';


import '../../api/auth_service.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';
import '../../constants/theme2.dart';
import '../../utils/alert_message.dart';
import '../../utils/loader.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/chamfered_text_widget.dart';


class ProjectSelectionPage extends StatefulWidget {
  const ProjectSelectionPage({super.key});

  @override
  State<ProjectSelectionPage> createState() => _ProjectSelectionPageState();
}

class _ProjectSelectionPageState extends State<ProjectSelectionPage> {
  String? selectedProject;
  TextEditingController activationCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);
    final projects = dashboardBloc.projects;
    if (projects.length == 1) {
      selectedProject = projects.first;
      
    } else {
      selectedProject = dashboardBloc.currentFilters.isNotEmpty
          ? dashboardBloc.currentFilters.first
          : null;
    }
  }

  

  // Add a separate method for dashboard button navigation
  void _navigateToDashboard() async {

    if (selectedProject == null) return;

    final dashboardBloc = BlocProvider.of<DashboardBloc>(context, listen: false);

    try {
      await LoaderUtility.showLoader(
        context,
        () async {
          // Clear current filters and data
          dashboardBloc.currentFilters.clear();
          dashboardBloc.filterData = null;
          dashboardBloc.summaryData = null;
          dashboardBloc.devicesData = null;

          // Select project and get filter data
          var filterData = await dashboardBloc.selectProject(dashboardBloc.projects.indexOf(selectedProject ?? ""));
          if (filterData != null) {
            // Update selected filters - this will load all data in parallel with caching
            await dashboardBloc.updateSelectedFilters([selectedProject], filterData);

            setState(() {
              selectedProject = selectedProject;
            });
          }
        }(),
      );
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(
        context,
        "Error selecting project: ${e.toString()}",
        AlertType.error
      );
    }

    if (selectedProject == null && dashboardBloc.currentFilters.isEmpty) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please select a project", AlertType.error);
      return;
    }
    
    // Switch to trends tab and emit navigation event
    dashboardBloc.switchBottomNavPos(1);
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
        return Dialog(
          backgroundColor: currentTheme.dialogBG,
            elevation: 0,
          child: Container(
            decoration: BoxDecoration(
                color: currentTheme.dialogBG, // Match BillingFormula dialog BG
                border: Border.all(
                  color: currentTheme.gridLineColor, // Match BillingFormula border color
                  width: 3.responsiveSp, // Match BillingFormula border width
                ),
                // Remove or comment out the boxShadow if you want it to look exactly like BillingFormula
                // boxShadow: [
                //   BoxShadow(
                //     color: currentTheme.profileBorderColor,
                //     blurRadius: 10.r,
                //     offset: Offset(0, 4.h),
                //   ),
                // ],
              ),
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      // color: Colors.green,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChamferedTextWidgetInverted(
                            text: "ADD PROJECT",
                            borderColor: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .gridLineColor,
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Provider.of<ThemeNotifier>(context)
                                    .currentTheme
                                    .gridLineColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.only(left: 24.w,right: 24.w),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Provider.of<ThemeNotifier>(context).currentTheme.profileBorderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Provider.of<ThemeNotifier>(context).currentTheme.shadowColor,
                            blurRadius: 1.r,
                            offset: Offset(3.w, 4.h),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextField(
                        controller: activationCodeController,
                        decoration: InputDecoration(
                          hintText: "Enter Activation Code",
                          hintStyle: TextStyle(
                            color: Provider.of<ThemeNotifier>(context).currentTheme.textfieldHintColor,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                          ),
                          filled: true,
                          fillColor: Provider.of<ThemeNotifier>(context).currentTheme.textFieldFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: Provider.of<ThemeNotifier>(context).currentTheme.profileBorderColor,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Provider.of<ThemeNotifier>(context).currentTheme.textfieldTextColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.only(left: 24.w,right: 24.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: "CANCEL",
                          isRed: true,
                          onPressed: () {
                            activationCodeController.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                        CustomButton(
                          text: "CONFIRM",
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (activationCodeController.text.isEmpty) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context, "Activation code cannot be empty", AlertType.error);
                              return;
                            }
                            try {
                              var result = await LoaderUtility.showLoader(
                                context,
                                LoginPostRequests.addProject(activationCodeController.text),
                              );
                              BlocProvider.of<DashboardBloc>(context, listen: false).checkAndAddProject(result);
                              activationCodeController.clear();
                              Navigator.of(context).pop();
                              setState(() {}); // Refresh project list
                            } catch (e) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context, e.toString(), AlertType.error);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final projects = dashboardBloc.projects;

    if (projects.isEmpty) {
      // Show loader while projects are being fetched
      return const CustomLoader();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 3.h,
          color: Color(0xFF14414e),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset('assets/icons/project.svg',
                        color: Provider.of<ThemeNotifier>(context).currentTheme.basicAdvanceTextColor,
                        height: 30.h,
    
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "SELECT PROJECT",
                        style: GoogleFonts.robotoMono(
                          fontSize: 18.responsiveSp,
                          fontWeight: FontWeight.w500,
                          color: Provider.of<ThemeNotifier>(context).currentTheme.loginTitleColor,
                      ),
                    ),
                    ],
                  ),
                  // IconButton(
                  //   onPressed: _showAddProjectDialog,
              
                  //   icon: Icon(
                  //     Icons.add,
                  //     color: theme.basicAdvanceTextColor,
                  //     size: 24.responsiveSp,
                  //   ),
                  //   style: ButtonStyle(
                  //     backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  //     shape: MaterialStateProperty.all(
                  //       RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12.r),

                  //         side: BorderSide(
                  //           color: (Provider.of<ThemeNotifier>(context).currentTheme.profileBorderColor), // Border color
                  //           width: 2, // Border width
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // )
                  GestureDetector(
                    onTap: _showAddProjectDialog,
                    child: Container(
                      height: 30.h,
                      width: 30.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          color: (Provider.of<ThemeNotifier>(context).currentTheme.profileBorderColor), // Border color
                          width: 2, // Border width
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.basicAdvanceTextColor,
                        size: 24.h,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 15.h),
              CustomDropdownButton2(
                fieldName: "PROJECT",
                value: selectedProject ?? (projects.length == 1 ? projects.first : null),
                items: projects,
                onChanged: (value) {
                  setState(() {
                    selectedProject = value;
                  });
                },
                width1: 400.w,
                width2: 360.w,
                fieldNameVisible: false,
              ),
              SizedBox(height: 470.h),
              CustomButton(
                text: "DASHBOARD",
                onPressed: _navigateToDashboard,
                arrowWidget: true,
                dynamicWidth: true,
              ),
              
            ],
          ),
        ),
        Spacer(),
        Container(
          height: 3.h,
          color: Color(0xFF14414e),
        )
      ],
    );
  }
}
