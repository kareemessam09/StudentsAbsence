import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/request_model.dart';
import '../utils/responsive.dart';

class RequestCard extends StatefulWidget {
  final RequestModel request;
  final VoidCallback? onAccept;
  final VoidCallback? onNotFound;
  final bool showActions;
  final bool isAnimated;

  const RequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onNotFound,
    this.showActions = false,
    this.isAnimated = false,
  });

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAction(VoidCallback? action) {
    if (action == null) return;

    if (widget.isAnimated) {
      _animationController.forward().then((_) {
        action();
        _animationController.reset();
      });
    } else {
      action();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'not_found':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'not_found':
        return Icons.cancel;
      case 'pending':
      default:
        return Icons.access_time;
    }
  }

  Widget _buildResolvedCard(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          margin: EdgeInsets.only(bottom: 12.h),
          elevation: 0,
          color: _getStatusColor(widget.request.status).withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: Responsive.borderRadius(16),
            side: BorderSide(
              color: _getStatusColor(widget.request.status).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: Responsive.padding(all: 16),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(widget.request.status),
                  color: _getStatusColor(widget.request.status),
                  size: 32.r,
                ),
                Responsive.horizontalSpace(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.studentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        'Marked as ${widget.request.status}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(widget.request.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingCard(ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: Responsive.borderRadius(16)),
      child: Padding(
        padding: Responsive.padding(all: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Student Icon
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24.r,
                  ),
                ),
                Responsive.horizontalSpace(16),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.studentName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Responsive.verticalSpace(4),
                      Row(
                        children: [
                          Icon(
                            Icons.class_outlined,
                            size: 14.r,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          Responsive.horizontalSpace(4),
                          Text(
                            widget.request.className,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontSize: 12.sp,
                            ),
                          ),
                          Responsive.horizontalSpace(12),
                          Icon(
                            Icons.access_time,
                            size: 14.r,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          Responsive.horizontalSpace(4),
                          Text(
                            widget.request.getFormattedTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.request.status,
                    ).withOpacity(0.1),
                    borderRadius: Responsive.borderRadius(20),
                    border: Border.all(
                      color: _getStatusColor(
                        widget.request.status,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(widget.request.status),
                        size: 14.r,
                        color: _getStatusColor(widget.request.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.request.status,
                        style: TextStyle(
                          color: _getStatusColor(widget.request.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action Buttons
            if (widget.showActions) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(widget.onAccept),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('OK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(widget.onNotFound),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Not Found'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isAnimated && widget.request.status.toLowerCase() != 'pending') {
      return _buildResolvedCard(theme);
    }

    return _buildPendingCard(theme);
  }
}
