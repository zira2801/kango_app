import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class CustomStepper extends StatefulWidget {
  final BuildContext context;
  final int activeStep;
  final List<CustomStep> steps;
  final double stepRadius;
  final Axis direction;
  final bool enableStepTapping;
  final CustomLineStyle lineStyle;
  final Color finishedStepBackgroundColor;
  final Color activeStepBackgroundColor;
  final Color unreachedStepBackgroundColor;
  final Color unreachedStepIconColor;
  final Color unreachedStepBorderColor;
  final bool showTitle;
  final Function(int) onStepReached;

  const CustomStepper({
    Key? key,
    required this.context,
    required this.activeStep,
    required this.steps,
    this.stepRadius = 24.0,
    this.direction = Axis.horizontal,
    this.enableStepTapping = true,
    this.lineStyle = const CustomLineStyle(),
    required this.finishedStepBackgroundColor,
    this.activeStepBackgroundColor = Colors.blue,
    this.unreachedStepBackgroundColor = Colors.grey,
    this.unreachedStepIconColor = Colors.white,
    this.unreachedStepBorderColor = Colors.black54,
    this.showTitle = true,
    required this.onStepReached,
  }) : super(key: key);

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper>
    with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers;
  late final List<Animation<double>> _animations;
  late final List<Animation<Color?>> _colorAnimations;
  late final ScrollController _scrollController;
  late int _previousActiveStep;

  @override
  void initState() {
    super.initState();
    _previousActiveStep = widget.activeStep;
    _scrollController = ScrollController();

    // Khởi tạo controllers và animations
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(CustomStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nếu active step thay đổi, trigger animation phù hợp
    if (widget.activeStep != oldWidget.activeStep) {
      _handleStepChange(oldWidget.activeStep, widget.activeStep);

      // Scroll đến active step
      _scrollToActiveStep();
    }

    // Nếu số lượng steps thay đổi, khởi tạo lại animations
    if (widget.steps.length != oldWidget.steps.length) {
      _disposeAnimations();
      _initializeAnimations();
    }
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.steps.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _animations = List.generate(
      widget.steps.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationControllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    _colorAnimations = List.generate(
      widget.steps.length,
      (index) => ColorTween(
        begin: widget.unreachedStepBackgroundColor,
        end: index < widget.activeStep
            ? widget.finishedStepBackgroundColor
            : (index == widget.activeStep
                ? widget.activeStepBackgroundColor
                : widget.unreachedStepBackgroundColor),
      ).animate(
        CurvedAnimation(
          parent: _animationControllers[index],
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Set initial values
    for (int i = 0; i < widget.steps.length; i++) {
      if (i <= widget.activeStep) {
        _animationControllers[i].value = 1.0;
      }
    }
  }

  void _disposeAnimations() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
  }

  void _handleStepChange(int oldStep, int newStep) {
    _previousActiveStep = oldStep;

    if (newStep > oldStep) {
      // Forward animation for steps between old and new
      for (int i = oldStep; i <= newStep; i++) {
        _animationControllers[i].forward();
      }
    } else {
      // Reverse animation for steps between new and old
      for (int i = newStep + 1; i <= oldStep; i++) {
        _animationControllers[i].reverse();
      }
    }
  }

  void _scrollToActiveStep() {
    // Calculate position to scroll to
    if (widget.direction == Axis.horizontal && _scrollController.hasClients) {
      double offset = (widget.activeStep *
              (2 * widget.stepRadius + widget.lineStyle.lineLength)) -
          (_scrollController.position.viewportDimension / 2);

      // Ensure offset is within scrollable range
      offset = offset.clamp(0.0, _scrollController.position.maxScrollExtent);

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.horizontal
        ? SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildStepperContent(),
            ),
          )
        : SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildStepperContent(),
            ),
          );
  }

  List<Widget> _buildStepperContent() {
    List<Widget> content = [];
    for (int i = 0; i < widget.steps.length; i++) {
      content.add(_buildAnimatedStep(i));
      if (i != widget.steps.length - 1) {
        content.add(_buildAnimatedLine(i));
      }
    }
    return content;
  }

  Widget _buildAnimatedStep(int index) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        final bool isActive = index == widget.activeStep;
        final bool isFinished = index < widget.activeStep;
        final bool wasFinishedOrActive = index <= _previousActiveStep;

        // Scale animation cho active step
        final double scale = isActive
            ? 1.0 + (0.1 * _animations[index].value) // Giảm từ 0.2 xuống 0.1
            : (wasFinishedOrActive && !isFinished
                ? 1.0 - (0.1 * _animations[index].value)
                : 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10.h,
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: isActive ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.2),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: widget.enableStepTapping
                    ? () => widget.onStepReached(index)
                    : null,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.stepRadius * 2,
                    height: widget.stepRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive || isFinished
                          ? LinearGradient(
                              colors: [
                                isActive
                                    ? widget.activeStepBackgroundColor
                                    : widget.finishedStepBackgroundColor,
                                isActive
                                    ? widget.activeStepBackgroundColor
                                        .withOpacity(0.8)
                                    : widget.finishedStepBackgroundColor
                                        .withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !isActive && !isFinished
                          ? widget.unreachedStepBackgroundColor
                          : null,
                      border: Border.all(
                        color: !isActive && !isFinished
                            ? widget.unreachedStepBorderColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isFinished
                          ? _buildAnimatedIcon(
                              widget.steps[index].finishIcon,
                              widget.steps[index].icon,
                              _animations[index].value)
                          : isActive
                              ? widget.steps[index].isActiveLottie
                                  ? _buildAnimatedIcon(
                                      widget.steps[index].activeIcon,
                                      widget.steps[index].icon,
                                      _animations[index].value)
                                  : IconTheme(
                                      data: IconThemeData(
                                        color: widget.unreachedStepIconColor,
                                        size: widget.stepRadius,
                                      ),
                                      child: widget.steps[index].activeIcon
                                          as Widget,
                                    )
                              : IconTheme(
                                  data: IconThemeData(
                                    color: widget.unreachedStepIconColor,
                                    size: widget.stepRadius,
                                  ),
                                  child: widget.steps[index].icon,
                                ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showTitle)
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: isActive
                      ? widget.activeStepBackgroundColor
                      : isFinished
                          ? widget.finishedStepBackgroundColor
                          : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14.sp,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: widget.stepRadius * 3,
                    child: Text(
                      widget.steps[index].title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedIcon(
      dynamic targetIcon, Widget initialIcon, double value) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: animation,
            child: child,
          ),
        );
      },
      child: value >= 0.5
          ? (targetIcon is String && _isLottieFile(targetIcon)
              ? Lottie.asset(
                  targetIcon,
                  width: widget.stepRadius * 1.5,
                  height: widget.stepRadius * 1.5,
                  fit: BoxFit.contain,
                )
              : targetIcon as Widget)
          : initialIcon,
    );
  }

  bool _isLottieFile(String path) {
    return path.toLowerCase().endsWith('.json');
  }

  Widget _buildAnimatedLine(int index) {
    final bool isFinished = index < widget.activeStep;

    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return Container(
          width: widget.direction == Axis.horizontal
              ? widget.lineStyle.lineLength
              : 2,
          height: widget.direction == Axis.vertical
              ? widget.lineStyle.lineLength
              : 2,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: CustomPaint(
            painter: AnimatedLinePainter(
              progress: isFinished ? _animations[index].value : 0.0,
              color: isFinished
                  ? widget.finishedStepBackgroundColor
                  : widget.unreachedStepBorderColor,
              lineType: isFinished
                  ? widget.lineStyle.lineType
                  : widget.lineStyle.unreachedLineType,
              strokeWidth: widget.lineStyle.lineThickness,
            ),
          ),
        );
      },
    );
  }
}

// Cấu trúc dữ liệu cho mỗi step
class CustomStep {
  final Widget icon;
  final dynamic activeIcon; // Có thể là Widget hoặc String path của Lottie
  final Widget finishIcon;
  final String title;
  final bool isActiveLottie; // Flag để xác định activeIcon có phải là Lottie

  const CustomStep({
    required this.icon,
    required this.activeIcon,
    required this.finishIcon,
    required this.title,
    this.isActiveLottie = false,
  });
}

enum CustomLineType { normal, dotted, dashed }

class CustomLineStyle {
  final double lineLength;
  final double lineThickness;
  final CustomLineType lineType;
  final CustomLineType unreachedLineType;

  const CustomLineStyle({
    this.lineLength = 70.0,
    this.lineThickness = 2.0,
    this.lineType = CustomLineType.normal,
    this.unreachedLineType = CustomLineType.dotted,
  });
}

class AnimatedLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final CustomLineType lineType;
  final double strokeWidth;

  AnimatedLinePainter({
    required this.progress,
    required this.color,
    required this.lineType,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final bool isHorizontal = size.width > size.height;
    final double startX = isHorizontal ? 0 : size.width / 2;
    final double startY = isHorizontal ? size.height / 2 : 0;
    final double endX = isHorizontal ? size.width * progress : size.width / 2;
    final double endY = isHorizontal ? size.height / 2 : size.height * progress;

    // Nếu progress = 0, vẽ đường màu xám mờ (chưa hoàn thành)
    if (progress < 0.01) {
      _drawUnreachedLine(canvas, size, paint);
      return;
    }

    switch (lineType) {
      case CustomLineType.normal:
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        break;
      case CustomLineType.dotted:
        final Path path = Path();
        double distance = 0.0;
        const double dashWidth = 4.0;
        const double dashSpace = 4.0;

        final double maxDistance =
            isHorizontal ? size.width * progress : size.height * progress;

        while (distance < maxDistance) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          double dashEnd = distance + dashWidth;
          dashEnd = dashEnd > maxDistance ? maxDistance : dashEnd;

          path.lineTo(
              isHorizontal ? dashEnd : startX, isHorizontal ? startY : dashEnd);

          distance += dashWidth + dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
      case CustomLineType.dashed:
        final Path path = Path();
        double distance = 0.0;
        const double dashWidth = 8.0;
        const double dashSpace = 6.0;

        final double maxDistance =
            isHorizontal ? size.width * progress : size.height * progress;

        while (distance < maxDistance) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          double dashEnd = distance + dashWidth;
          dashEnd = dashEnd > maxDistance ? maxDistance : dashEnd;

          path.lineTo(
              isHorizontal ? dashEnd : startX, isHorizontal ? startY : dashEnd);

          distance += dashWidth + dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
    }

    // Vẽ phần còn lại của đường màu xám
    if (progress < 1.0) {
      _drawRemainingLine(canvas, size, paint, progress);
    }
  }

  void _drawUnreachedLine(Canvas canvas, Size size, Paint paint) {
    final bool isHorizontal = size.width > size.height;
    final double startX = isHorizontal ? 0 : size.width / 2;
    final double startY = isHorizontal ? size.height / 2 : 0;
    final double endX = isHorizontal ? size.width : size.width / 2;
    final double endY = isHorizontal ? size.height / 2 : size.height;

    // Lưu lại màu hiện tại
    final Color originalColor = paint.color;

    // Đổi màu thành xám mờ
    paint.color = Colors.grey.withOpacity(0.5);

    switch (lineType) {
      case CustomLineType.normal:
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        break;
      case CustomLineType.dotted:
        final Path path = Path();
        double distance = 0.0;
        const double dashWidth = 4.0;
        const double dashSpace = 4.0;

        while (distance < (isHorizontal ? size.width : size.height)) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          distance += dashWidth;

          path.lineTo(
              isHorizontal
                  ? (distance > size.width ? size.width : distance)
                  : startX,
              isHorizontal
                  ? startY
                  : (distance > size.height ? size.height : distance));

          distance += dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
      case CustomLineType.dashed:
        final Path path = Path();
        double distance = 0.0;
        const double dashWidth = 8.0;
        const double dashSpace = 6.0;

        while (distance < (isHorizontal ? size.width : size.height)) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          distance += dashWidth;

          path.lineTo(
              isHorizontal
                  ? (distance > size.width ? size.width : distance)
                  : startX,
              isHorizontal
                  ? startY
                  : (distance > size.height ? size.height : distance));

          distance += dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
    }

    // Khôi phục màu ban đầu
    paint.color = originalColor;
  }

  void _drawRemainingLine(
      Canvas canvas, Size size, Paint paint, double progress) {
    final bool isHorizontal = size.width > size.height;
    final double startX = isHorizontal ? size.width * progress : size.width / 2;
    final double startY =
        isHorizontal ? size.height / 2 : size.height * progress;
    final double endX = isHorizontal ? size.width : size.width / 2;
    final double endY = isHorizontal ? size.height / 2 : size.height;

    // Lưu lại màu hiện tại
    final Color originalColor = paint.color;

    // Đổi màu thành xám mờ
    paint.color = Colors.grey.withOpacity(0.5);

    switch (lineType) {
      case CustomLineType.normal:
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        break;
      case CustomLineType.dotted:
        final Path path = Path();
        double distance =
            isHorizontal ? size.width * progress : size.height * progress;
        const double dashWidth = 4.0;
        const double dashSpace = 4.0;

        while (distance < (isHorizontal ? size.width : size.height)) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          distance += dashWidth;

          path.lineTo(
              isHorizontal
                  ? (distance > size.width ? size.width : distance)
                  : startX,
              isHorizontal
                  ? startY
                  : (distance > size.height ? size.height : distance));

          distance += dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
      case CustomLineType.dashed:
        final Path path = Path();
        double distance =
            isHorizontal ? size.width * progress : size.height * progress;
        const double dashWidth = 8.0;
        const double dashSpace = 6.0;

        while (distance < (isHorizontal ? size.width : size.height)) {
          path.moveTo(isHorizontal ? distance : startX,
              isHorizontal ? startY : distance);

          distance += dashWidth;

          path.lineTo(
              isHorizontal
                  ? (distance > size.width ? size.width : distance)
                  : startX,
              isHorizontal
                  ? startY
                  : (distance > size.height ? size.height : distance));

          distance += dashSpace;
        }
        canvas.drawPath(path, paint);
        break;
    }

    // Khôi phục màu ban đầu
    paint.color = originalColor;
  }

  @override
  bool shouldRepaint(AnimatedLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.lineType != lineType ||
      oldDelegate.strokeWidth != strokeWidth;
}
