import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final bool isLoading;
  final Widget child;

  const SkeletonLoader({Key? key, required this.isLoading, required this.child})
    : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isLoading) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoading
        ? AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => _buildSkeleton(),
          )
        : widget.child;
  }

  Widget _buildSkeleton() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildNavigation(),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) => _buildPostSkeleton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          _buildShimmerBox(32, 32, borderRadius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: _buildShimmerBox(36, double.infinity, borderRadius: 18),
          ),
          const SizedBox(width: 12),
          _buildShimmerBox(36, 36, borderRadius: 18),
          const SizedBox(width: 8),
          _buildShimmerBox(36, 36, borderRadius: 18),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          5,
          (index) => _buildShimmerBox(48, 60, borderRadius: 8),
        ),
      ),
    );
  }

  Widget _buildPostSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(40, 40, borderRadius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(16, 120),
                    const SizedBox(height: 4),
                    _buildShimmerBox(12, 80),
                  ],
                ),
              ),
              _buildShimmerBox(24, 24, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerBox(14, double.infinity),
          const SizedBox(height: 6),
          _buildShimmerBox(14, 200),
          const SizedBox(height: 16),

          _buildShimmerBox(200, double.infinity, borderRadius: 8),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildShimmerBox(32, 60, borderRadius: 16),
              const SizedBox(width: 16),
              _buildShimmerBox(32, 60, borderRadius: 16),
              const SizedBox(width: 16),
              _buildShimmerBox(32, 60, borderRadius: 16),
              const Spacer(),
              _buildShimmerBox(32, 40, borderRadius: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(
    double height,
    double width, {
    double borderRadius = 4,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: const [
            Color(0xFFE4E6EA),
            Color(0xFFF0F2F5),
            Color(0xFFE4E6EA),
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0 + _animation.value, 0),
          end: Alignment(1.0 + _animation.value, 0),
        ),
      ),
    );
  }
}
