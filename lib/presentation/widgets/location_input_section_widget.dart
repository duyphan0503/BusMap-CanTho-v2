import 'package:busmapcantho/core/utils/string_utils.dart';
import 'package:busmapcantho/presentation/widgets/gradient_border_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';

class LocationInputSection<
  CubitType extends StateStreamable<StateType>,
  StateType
>
    extends StatefulWidget {
  // Static configurations and callbacks
  final IconData startIcon;
  final IconData endIcon;
  final Color startIconColor;
  final Color endIconColor;
  final String startPlaceholder;
  final String endPlaceholder;
  final VoidCallback? onSelectStart; // Re-added
  final VoidCallback? onSelectEnd; // Re-added
  final VoidCallback? onSwap; // Re-added
  final bool showSwapButton;
  final bool isReadOnly;
  final bool useCardWrapper; // New parameter

  // Functions to extract dynamic names from the StateType
  final String? Function(StateType state) getStartName;
  final String? Function(StateType state) getEndName;
  final bool Function(StateType state)
  getStartInputError; // New: to get start error status
  final bool Function(StateType state)
  getEndInputError; // New: to get end error status

  const LocationInputSection({
    super.key,
    required this.getStartName,
    required this.getEndName,
    required this.getStartInputError, // New
    required this.getEndInputError, // New
    required this.startIcon,
    required this.endIcon,
    required this.startIconColor,
    required this.endIconColor,
    required this.startPlaceholder,
    required this.endPlaceholder,
    this.onSelectStart, // Re-added
    this.onSelectEnd, // Re-added
    this.onSwap, // Re-added
    this.showSwapButton = true,
    this.isReadOnly = false,
    this.useCardWrapper = true, // Default to true for existing behavior
  });

  @override
  State<LocationInputSection<CubitType, StateType>> createState() =>
      _LocationInputSectionState<CubitType, StateType>();
}

class _LocationInputSectionState<
  CubitType extends StateStreamable<StateType>,
  StateType
>
    extends State<LocationInputSection<CubitType, StateType>>
    with TickerProviderStateMixin {
  AnimationController? _startErrorAnimationController;
  Animation<Color?>? _startErrorColorAnimation;
  AnimationController? _endErrorAnimationController;
  Animation<Color?>? _endErrorColorAnimation;

  @override
  void initState() {
    super.initState();
    _startErrorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _endErrorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize animations here because Theme.of(context) is available
    _startErrorColorAnimation = ColorTween(
      begin:
          Colors.transparent, // Or widget.startIconColor or theme.primaryColor
      end: Colors.red,
    ).animate(_startErrorAnimationController!);

    _endErrorColorAnimation = ColorTween(
      begin: Colors.transparent, // Or widget.endIconColor or theme.primaryColor
      end: Colors.red,
    ).animate(_endErrorAnimationController!);
  }

  @override
  void dispose() {
    _startErrorAnimationController?.dispose();
    _endErrorAnimationController?.dispose();
    super.dispose();
  }

  void _triggerErrorAnimation(AnimationController? controller) {
    controller?.forward().then((_) {
      controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CubitType, StateType>(
      listener: (context, state) {
        if (widget.getStartInputError(state)) {
          _triggerErrorAnimation(_startErrorAnimationController);
        }
        if (widget.getEndInputError(state)) {
          _triggerErrorAnimation(_endErrorAnimationController);
        }
      },
      builder: (context, state) {
        final currentStartName = widget.getStartName(state);
        final currentEndName = widget.getEndName(state);

        final content = Stack(
          alignment: Alignment.centerRight,
          children: [
            Column(
              children: [
                AnimatedBuilder(
                  animation: _startErrorColorAnimation!,
                  builder: (context, child) {
                    return _buildLocationRow(
                      context: context,
                      label: 'fromLabel'.tr(),
                      icon: widget.startIcon,
                      iconColor: widget.startIconColor,
                      name: currentStartName,
                      onTap: widget.isReadOnly ? null : widget.onSelectStart,
                      placeholder: widget.startPlaceholder,
                      borderColor:
                          _startErrorColorAnimation!.value ??
                          AppColors.primaryMedium,
                    );
                  },
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _endErrorColorAnimation!,
                  builder: (context, child) {
                    return _buildLocationRow(
                      context: context,
                      label: 'toLabel'.tr(),
                      icon: widget.endIcon,
                      iconColor: widget.endIconColor,
                      name: currentEndName,
                      onTap: widget.isReadOnly ? null : widget.onSelectEnd,
                      placeholder: widget.endPlaceholder,
                      borderColor:
                          _endErrorColorAnimation!.value ??
                          AppColors.primaryMedium,
                    );
                  },
                ),
              ],
            ),
            if (widget.showSwapButton)
              Positioned(top: 32, child: _buildSwapButton(context, theme)),
          ],
        );

        if (widget.useCardWrapper) {
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(51),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: content,
          );
        }
        return content; // Return content directly if no card wrapper
      },
    );
  }

  Widget _buildSwapButton(BuildContext context, ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
        border: Border.all(color: theme.dividerColor),
      ),
      child: IconButton(
        icon: const Icon(Icons.swap_vert, color: Colors.white),
        tooltip: 'swapTooltip'.tr(),
        onPressed: widget.isReadOnly ? null : widget.onSwap,
      ),
    );
  }

  Widget _buildLocationRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? name,
    required VoidCallback? onTap,
    required String placeholder,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = StringUtils.getShortName(
      name,
    ); // Sử dụng StringUtils.getShortName
    final bool hasName = displayName.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: GradientBorderWidget(
          borderColor: Colors.white,
          borderWidth: 2,
          borderRadius: 8,
          gradientWidth: 26,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                const SizedBox(width: 12),
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasName ? displayName : placeholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          hasName
                              ? colorScheme.onSurface
                              : theme.textTheme.bodyMedium?.color?.withAlpha(
                                150,
                              ),
                      fontWeight: hasName ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
