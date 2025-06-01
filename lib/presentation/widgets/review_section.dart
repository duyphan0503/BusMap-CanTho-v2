import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../core/services/notification_snackbar_service.dart';
import '../../data/model/feedback.dart';
import '../cubits/feedback/feedback_cubit.dart';
import '../cubits/feedback/feedback_state.dart';

class ReviewSection extends StatefulWidget {
  final String routeId;

  const ReviewSection({super.key, required this.routeId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 3.0;

  @override
  void initState() {
    super.initState();
    context.read<FeedbackCubit>().loadFeedback(widget.routeId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onRatingUpdate(double rating) {
    setState(() {
      _userRating = rating;
    });
  }

  void _onCommentChanged(String value) {
    setState(() {});
  }

  Future<void> _onSubmit(BuildContext context, FeedbackState state) async {
    final cubit = context.read<FeedbackCubit>();
    if (state is FeedbackLoaded && state.currentUserFeedback != null) {
      await cubit.update(
        routeId: widget.routeId,
        feedbackId: state.currentUserFeedback!.id,
        rating: _userRating.toInt(),
        content: _commentController.text,
      );
    } else {
      await cubit.submit(
        routeId: widget.routeId,
        rating: _userRating.toInt(),
        content: _commentController.text,
      );
    }
    setState(() {});
    context.showSuccessSnackBar('Đã cập nhật đánh giá: ${_userRating.toInt()} sao');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackCubit, FeedbackState>(
      listener: (context, state) {
        if (state is FeedbackError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is FeedbackLoaded && state.currentUserFeedback != null) {
          _userRating = state.currentUserFeedback!.rating.toDouble();
          _commentController.text = state.currentUserFeedback!.content ?? '';
        }
      },
      builder: (context, state) {
        if (state is FeedbackLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FeedbackLoaded) {
          final currentUserFeedback = state.currentUserFeedback;
          final otherUserReviews = state.otherFeedbacks;
          final allRatings = [
            if (currentUserFeedback != null) currentUserFeedback.rating,
            ...otherUserReviews.map((e) => e.rating),
          ];
          final averageRating =
              allRatings.isNotEmpty
                  ? allRatings.reduce((a, b) => a + b) / allRatings.length
                  : 0.0;
          final totalRatings = allRatings.length;
          final ratingDistribution = List<int>.generate(
            5,
            (i) => allRatings.where((r) => r == i + 1).length,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tổng hợp đánh giá",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                OverallRatingSummary(
                  averageRating: averageRating,
                  totalRatings: totalRatings,
                  ratingDistribution: ratingDistribution,
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 24),
                Text(
                  "Đánh giá của bạn",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: RatingBar.builder(
                    initialRating: _userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder:
                        (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: _onRatingUpdate,
                    unratedColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Nhập nhận xét (không bắt buộc)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onCommentChanged,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onSubmit(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34A853),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Cập nhật đánh giá",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (otherUserReviews.isNotEmpty) ...[
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 24),
                ],
                ...otherUserReviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: UserReviewWidget(review: review),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is FeedbackError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class OverallRatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final List<int> ratingDistribution;

  const OverallRatingSummary({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            RatingBarIndicator(
              rating: averageRating,
              itemBuilder:
                  (context, index) =>
                      const Icon(Icons.star, color: Color(0xFF34A853)),
              itemCount: 5,
              itemSize: 24.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  totalRatings.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.person, size: 16, color: Colors.grey[700]),
              ],
            ),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children:
                List.generate(5, (index) {
                  final starLevel = 5 - index;
                  final count = ratingDistribution[starLevel - 1];
                  final percentage =
                      totalRatings > 0 ? (count / totalRatings) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      children: [
                        Text(
                          '$starLevel',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.grey, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF34A853),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).reversed.toList(),
          ),
        ),
      ],
    );
  }
}

class UserReviewWidget extends StatelessWidget {
  final FeedbackModel review;

  const UserReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(review.createdAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          review.userName ?? 'Người dùng',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            RatingBarIndicator(
              rating: review.rating.toDouble(),
              itemBuilder:
                  (context, index) =>
                      const Icon(Icons.star, color: Color(0xFF34A853)),
              itemCount: 5,
              itemSize: 18.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        if (review.content != null && review.content!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            review.content!,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }
}
