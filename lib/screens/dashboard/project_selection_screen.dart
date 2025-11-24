import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:watermeter2/services/platform_utils.dart';
import 'package:watermeter2/utils/pok.dart';

import '../../api/auth_service.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_state.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../constants/theme2.dart';
import '../../constants/ui_config.dart';
import '../../utils/alert_message.dart';
import '../../utils/loader.dart';
import '../../utils/new_loader.dart';
import '../../widgets/customButton.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/chamfered_text_widget.dart';
import '../../widgets/custom_app_bar.dart';
import '../profile/profile_drawer.dart';

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
    final dashboardBloc =
        BlocProvider.of<DashboardBloc>(context, listen: false);
    final projects = dashboardBloc.projects;
    if (projects.length == 1) {
      selectedProject = projects.first;
    } else {
      selectedProject = dashboardBloc.currentFilters.isNotEmpty
          ? dashboardBloc.currentFilters.first
          : null;
    }
  }

  void _navigateToDashboard() async {
    if (selectedProject == null) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Please select a project", AlertType.error);
      return;
    }

    final dashboardBloc =
        BlocProvider.of<DashboardBloc>(context, listen: false);

    try {
      await LoaderUtility.showLoader(
        context,
        () async {
          dashboardBloc.currentFilters.clear();
          dashboardBloc.filterData = null;
          dashboardBloc.clearBillingData();
          dashboardBloc.devicesData = null;

          var filterData = await dashboardBloc.selectProject(
              dashboardBloc.projects.indexOf(selectedProject ?? ""));
          if (filterData != null) {
            await dashboardBloc
                .updateSelectedFilters([selectedProject], filterData);

            dashboardBloc.screenIndex = 0;

            dashboardBloc.switchBottomNavPos(0);
          }
        }(),
      );
    } catch (e) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Error selecting project: ${e.toString()}", AlertType.error);
      return;
    }

    if (dashboardBloc.currentFilters.isEmpty) {
      CustomAlert.showCustomScaffoldMessenger(
          context, "Error loading project data", AlertType.error);
      return;
    }

    Navigator.of(context).pushReplacementNamed('/homePage');
  }

  void _showAddProjectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme =
            Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
        final dialogWidth = UIConfig.getDesktopDialogWidth(context);
        final width = dialogWidth;
        return Dialog(
          backgroundColor: currentTheme.dialogBG,
          elevation: 0,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: UIConfig.dialogMaxHeight,
            ),
            decoration: BoxDecoration(
              color: currentTheme.dialogBG,
              border: Border.all(
                color: currentTheme.gridLineColor,
                width: UIConfig.dialogBorderWidth,
              ),
            ),
            child: Padding(
              padding: UIConfig.paddingDialogBottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChamferedTextWidgetInverted(
                        text: "ADD PROJECT",
                        borderColor: Provider.of<ThemeNotifier>(context)
                            .currentTheme
                            .gridLineColor,
                        fontSize: UIConfig.getResponsiveFontSize(
                            context, ThemeNotifier.medium,
                            desktopWidth: width),
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
                  SizedBox(height: 15.h),
                  Padding(
                    padding: UIConfig.paddingDialogHorizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .profileBorderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .shadowColor,
                            blurRadius: 1.r,
                            offset: Offset(UIConfig.spacingXSmall * 0.75,
                                UIConfig.spacingXSmall),
                          ),
                        ],
                        borderRadius: UIConfig.borderRadiusCircularMedium,
                      ),
                      child: TextField(
                        controller: activationCodeController,
                        decoration: InputDecoration(
                          hintText: "Enter Activation Code",
                          hintStyle: TextStyle(
                            color: Provider.of<ThemeNotifier>(context)
                                .currentTheme
                                .textfieldHintColor,
                            fontFamily: GoogleFonts.robotoMono().fontFamily,
                            fontSize: UIConfig.getResponsiveFontSize(
                                context, ThemeNotifier.medium,
                                desktopWidth: width),
                          ),
                          filled: true,
                          fillColor: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .textFieldFillColor,
                          border: OutlineInputBorder(
                            borderRadius: UIConfig.borderRadiusCircularMedium,
                            borderSide: BorderSide(
                              color: Provider.of<ThemeNotifier>(context)
                                  .currentTheme
                                  .profileBorderColor,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Provider.of<ThemeNotifier>(context)
                              .currentTheme
                              .textfieldTextColor,
                          fontSize: UIConfig.getResponsiveFontSize(
                              context, ThemeNotifier.medium,
                              desktopWidth: width),
                        ),
                      ),
                    ),
                  ),
                  UIConfig.spacingSizedBoxXXLarge,
                  Padding(
                    padding: UIConfig.paddingDialogHorizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: "CANCEL",
                          isRed: true,
                          dynamicWidth: true,
                          fontSize: UIConfig.getResponsiveFontSize(
                              context, ThemeNotifier.small,
                              desktopWidth: width),
                          onPressed: () {
                            activationCodeController.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                        // SizedBox(width: 12.w),
                        CustomButton(
                          text: "CONFIRM",
                          dynamicWidth: true,
                          fontSize: UIConfig.getResponsiveFontSize(
                              context, ThemeNotifier.small,
                              desktopWidth: width),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (activationCodeController.text.isEmpty) {
                              CustomAlert.showCustomScaffoldMessenger(
                                  context,
                                  "Activation code cannot be empty",
                                  AlertType.error);
                              return;
                            }
                            try {
                              var result = await LoaderUtility.showLoader(
                                context,
                                LoginPostRequests.addProject(
                                    activationCodeController.text),
                              );
                              BlocProvider.of<DashboardBloc>(context,
                                      listen: false)
                                  .checkAndAddProject(result);
                              activationCodeController.clear();
                              Navigator.of(context).pop();
                              setState(() {});
                              CustomAlert.showCustomScaffoldMessenger(
                                context,
                                "Project added successfully!",
                                AlertType.success,
                              );
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

  void showProfileDrawer(BuildContext context) async {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (authBloc.state is! AuthAuthenticated) return;

    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: dashboardBloc,
            child: Scaffold(
              body: ProfileDrawer(),
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    final theme = Provider.of<ThemeNotifier>(context).currentTheme;
    final projects = dashboardBloc.projects;
    final width = (MediaQuery.of(context).size.width * 1 / 3);

    if (projects.isEmpty) {
      return Scaffold(
        backgroundColor: theme.bgColor,
        body: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: const CustomLoader(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.bgColor,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        choiceAction: (value) {
          showProfileDrawer(context);
        },
      ),
      body: MediaQuery.removePadding(
        removeTop: true,
        removeBottom: true,
        context: context,
        child: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: UIConfig.accentLineHeight,
                          color: UIConfig.color14414e,
                        ),
                        Center(
                          child: SizedBox(
                            width: PlatformUtils.isMobile
                                ? MediaQuery.of(context).size.width
                                : width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                  horizontal:
                                      PlatformUtils.isMobile ? 16.w : 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/project.svg',
                                            color: Provider.of<ThemeNotifier>(
                                                    context)
                                                .currentTheme
                                                .basicAdvanceTextColor,
                                            height: 30.h,
                                          ),
                                          UIConfig.spacingSizedBoxSmall,
                                          Text(
                                            "SELECT PROJECT",
                                            style: GoogleFonts.robotoMono(
                                              fontSize: UIConfig.fontSizeMedium.responsiveSp,
                                              fontWeight: FontWeight.w500,
                                              color: Provider.of<ThemeNotifier>(
                                                      context)
                                                  .currentTheme
                                                  .loginTitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: _showAddProjectDialog,
                                        child: Container(
                                          height: 30.h,
                                          // width: 30.w,
                                          decoration: BoxDecoration(
                                            borderRadius: UIConfig
                                                .borderRadiusCircularSmall,
                                            border: Border.all(
                                              color:
                                                  (Provider.of<ThemeNotifier>(
                                                          context)
                                                      .currentTheme
                                                      .profileBorderColor),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: theme.basicAdvanceTextColor,
                                            size:
                                                UIConfig.iconSizeSmall.responsiveSp,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 15.h),
                                  CustomDropdownButton2(
                                    fieldName: "PROJECT",
                                    value: selectedProject ??
                                        (projects.length == 1
                                            ? projects.first
                                            : null),
                                    items: projects,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedProject = value;
                                      });
                                    },
                                    width1: PlatformUtils.isMobile ? 360.w : 0,
                                    width2: PlatformUtils.isMobile
                                        ? 350.w
                                        : width - 30,
                                    desktopDropdownWidth: width - 30,
                                    fieldNameVisible: false,
                                  ),
                                  SizedBox(height: UIConfig.spacingHuge),
                                  CustomButton(
                                    text: "DASHBOARD",
                                    onPressed: _navigateToDashboard,
                                    fontSize: ThemeNotifier.large.responsiveSp,
                                    arrowWidget: true,
                                    dynamicWidth: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        // Container(
                        //   height: UIConfig.accentLineHeight,
                        //   color: UIConfig.color14414e,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
