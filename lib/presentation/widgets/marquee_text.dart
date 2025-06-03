import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // pixels per second
  final Duration pauseBetweenLoops;
  final Duration initialDelay;
  final double gapWidth;

  const MarqueeText({
    Key? key,
    required this.text,
    this.style,
    this.velocity = 30.0,
    this.pauseBetweenLoops = const Duration(seconds: 2),
    this.initialDelay = const Duration(seconds: 1),
    this.gapWidth = 50.0, // Default gap between text repetitions
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  final ScrollController _scrollController = ScrollController();
  double _textWidth = 0.0;
  double _containerWidth = 0.0;
  bool _isScrolling = false;
  bool _scrollCycleInProgress = false;

  @override
  void initState() {
    super.initState();
    // Initialization will be triggered by LayoutBuilder
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.style != oldWidget.style ||
        widget.velocity != oldWidget.velocity) {
      _resetAndReInitMarquee();
    }
  }

  void _resetAndReInitMarquee() {
    _stopScrolling();
    if (mounted && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // Force remeasure by resetting textWidth, containerWidth will be updated by LayoutBuilder
    _textWidth = 0.0; 
    // _initMarquee will be called by LayoutBuilder when constraints are available
    // or if it's already built, we might need to trigger it if containerWidth is known
    if (mounted && _containerWidth > 0) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initMarquee();
      });
    }
  }

  void _initMarquee() {
    if (!mounted || _containerWidth == 0.0) return;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    
    final newTextWidth = textPainter.width;

    // Check if re-initialization is actually needed
    if (newTextWidth == _textWidth && _isScrolling == (newTextWidth > _containerWidth)) {
      // If text width and scrolling status haven't changed, no need to re-init fully
      // unless scrollCycle is not in progress and it should be.
      if (_isScrolling && !_scrollCycleInProgress) {
        _startScrollCycleWithDelay();
      }
      return;
    }
    _textWidth = newTextWidth;

    _stopScrolling();

    if (_textWidth > _containerWidth) {
      _isScrolling = true;
      if (!_scrollCycleInProgress) {
         _startScrollCycleWithDelay();
      }
    } else {
      _isScrolling = false;
    }

    if (mounted) {
      setState(() {});
    }
  }
  
  void _startScrollCycleWithDelay() {
    Future.delayed(widget.initialDelay, () {
      if (mounted && _isScrolling && !_scrollCycleInProgress) {
        _scrollCycle();
      }
    });
  }

  Future<void> _scrollCycle() async {
    if (!mounted || !_isScrolling || !_scrollController.hasClients) {
      _scrollCycleInProgress = false;
      return;
    }
    _scrollCycleInProgress = true;

    try {
      double targetScrollPosition = _textWidth + widget.gapWidth;
      Duration scrollDuration = Duration(
          milliseconds: ((_textWidth + widget.gapWidth) / widget.velocity * 1000).round());

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          targetScrollPosition,
          duration: scrollDuration,
          curve: Curves.linear,
        );
      }

      if (!mounted || !_isScrolling) {
        _scrollCycleInProgress = false;
        return;
      }

      await Future.delayed(widget.pauseBetweenLoops);

      if (!mounted || !_isScrolling || !_scrollController.hasClients) {
        _scrollCycleInProgress = false;
        return;
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      if (mounted && _isScrolling) {
        // Add a microtask delay to allow the frame with jumpTo(0) to render
        // before starting the next animation cycle.
        Future.microtask(() {
          if (mounted && _isScrolling) {
            _scrollCycle();
          } else {
            _scrollCycleInProgress = false;
          }
        });
      } else {
        _scrollCycleInProgress = false;
      }
    } catch (e) {
      // In case of error (e.g. widget disposed during animation)
      _scrollCycleInProgress = false;
      if (mounted) _stopScrolling();
    }
  }

  void _stopScrolling() {
    _isScrolling = false; // Stops new cycles from starting
    _scrollCycleInProgress = false; 
    // Note: Current animation might finish. For immediate stop, more complex handling is needed.
  }

  @override
  void dispose() {
    _stopScrolling();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update containerWidth and re-initialize if it changes
        if (_containerWidth != constraints.maxWidth) {
          _containerWidth = constraints.maxWidth;
          // Defer initialization to ensure everything is laid out
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _initMarquee();
          });
        }

        // If text width is not yet calculated or text fits, display normally
        if (_textWidth == 0.0 || !_isScrolling) {
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Fallback for non-scrolling text
          );
        }

        // Build the marquee
        return ClipRect(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(), // Controlled programmatically
            child: Row(
              children: [
                Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
                SizedBox(width: widget.gapWidth),
                Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
