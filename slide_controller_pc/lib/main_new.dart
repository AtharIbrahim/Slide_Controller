import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'bloc/server_bloc.dart';
import 'bloc/server_event.dart';
import 'bloc/server_state.dart';
import 'widgets/responsive_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => ServerBloc()..add(InitializeServer()),
          child: MaterialApp(
            title: 'Slide Controller Server',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const MyHomePage(title: 'Slide Controller Server'),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: ResponsiveWidget(
          mobile: _buildMobileTitle(context),
          desktop: _buildDesktopTitle(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocBuilder<ServerBloc, ServerState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getMaxWidth(context),
                ),
                child: ResponsiveWidget(
                  mobile: _buildMobileLayout(context, state),
                  desktop: _buildDesktopLayout(context, state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileTitle(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.slideshow, color: Theme.of(context).colorScheme.primary, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ],
    );
  }

  Widget _buildDesktopTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.slideshow, color: Theme.of(context).colorScheme.primary, size: 28.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ServerState state) {
    return Column(
      children: [
        _buildStatusCard(context, state),
        SizedBox(height: 16.h),
        _buildIPCard(context, state),
        SizedBox(height: 24.h),
        _buildControlButtons(context, state),
        SizedBox(height: 24.h),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ServerState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatusCard(context, state)),
            SizedBox(width: 24.w),
            Expanded(child: _buildIPCard(context, state)),
          ],
        ),
        SizedBox(height: 32.h),
        _buildControlButtons(context, state),
        SizedBox(height: 32.h),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, ServerState state) {
    Color statusColor;
    IconData statusIcon;
    
    if (state.isLoading) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
    } else if (state.serverRunning) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16.w : 24.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: ResponsiveHelper.isMobile(context) ? 24.sp : 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Server Status',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  if (state.isLoading)
                    SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(statusIcon, color: statusColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      state.statusMessage,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.isMobile(context) ? 14.sp : 16.sp,
                        color: statusColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIPCard(BuildContext context, ServerState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16.w : 24.w),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: Theme.of(context).colorScheme.primary,
                  size: ResponsiveHelper.isMobile(context) ? 24.sp : 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Network Information',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 18.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.computer,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IP Address:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          state.ipAddress,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.isMobile(context) ? 16.sp : 18.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.ipAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text('IP Address "${state.ipAddress}" copied to clipboard!'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy IP Address',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, ServerState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.isMobile(context) ? 48.h : 56.h,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () {
              context.read<ServerBloc>().add(StartServer());
            },
            icon: state.isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(
              state.isLoading ? 'Processing...' : 'Start Server',
              style: TextStyle(
                fontSize: ResponsiveHelper.isMobile(context) ? 14.sp : 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        ResponsiveWidget(
          mobile: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ServerBloc>().add(GetIpAddress()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh IP'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ServerBloc>().add(RestartServer()),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
          desktop: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<ServerBloc>().add(GetIpAddress()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh IP'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<ServerBloc>().add(RestartServer()),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Restart'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Slide Controller Server v1.0\nManage your presentation server with ease',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.isMobile(context) ? 12.sp : 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
