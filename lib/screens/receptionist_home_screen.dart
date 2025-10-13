import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubits/request_cubit.dart';
import '../cubits/request_state.dart';
import '../cubits/user_cubit.dart';
import '../widgets/request_card.dart';
import '../widgets/empty_state.dart';
import '../utils/responsive.dart';

class ReceptionistHomeScreen extends StatefulWidget {
  const ReceptionistHomeScreen({super.key});

  @override
  State<ReceptionistHomeScreen> createState() => _ReceptionistHomeScreenState();
}

class _ReceptionistHomeScreenState extends State<ReceptionistHomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedClass = 'Class A';

  final List<String> _classes = ['Class A', 'Class B', 'Class C'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _sendRequest() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a student name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Add request using Cubit
    final currentUser = context.read<UserCubit>().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<RequestCubit>().addRequest(
      studentName: _nameController.text.trim(),
      className: _selectedClass,
      createdBy: currentUser.id,
    );

    _nameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Request sent successfully'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receptionist Panel'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Input Section
            Container(
              padding: Responsive.padding(all: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Name TextField
                  TextField(
                    controller: _nameController,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      labelStyle: TextStyle(fontSize: 14.sp),
                      hintText: 'Enter student name',
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.person_outline, size: 20.r),
                      border: OutlineInputBorder(
                        borderRadius: Responsive.borderRadius(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  Responsive.verticalSpace(16),

                  // Class Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedClass,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Select Class',
                      labelStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.class_outlined, size: 20.r),
                      border: OutlineInputBorder(
                        borderRadius: Responsive.borderRadius(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    items: _classes.map((String className) {
                      return DropdownMenuItem<String>(
                        value: className,
                        child: Text(
                          className,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedClass = newValue;
                        });
                      }
                    },
                  ),
                  Responsive.verticalSpace(20),

                  // Send Request Button
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.buttonHeight(context),
                    child: ElevatedButton.icon(
                      onPressed: _sendRequest,
                      icon: Icon(Icons.send, size: 20.r),
                      label: Text(
                        'Send Request',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: Responsive.borderRadius(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Requests List Section
            Padding(
              padding: Responsive.padding(all: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 20.r,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  Responsive.horizontalSpace(8),
                  Text(
                    'Recent Requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

            // ListView of Requests with BlocBuilder
            Expanded(
              child: BlocBuilder<RequestCubit, RequestState>(
                builder: (context, state) {
                  if (state is RequestLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RequestError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  if (state is RequestLoaded) {
                    final requests = state.requests;

                    if (requests.isEmpty) {
                      return const EmptyState(
                        message: 'No requests yet',
                        subtitle: 'Send your first attendance request above',
                        icon: Icons.inbox_outlined,
                      );
                    }

                    return ListView.builder(
                      padding: Responsive.padding(horizontal: 20),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          child: RequestCard(
                            key: ValueKey(request.id),
                            request: request,
                            showActions: false,
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
