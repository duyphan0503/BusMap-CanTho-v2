import 'package:equatable/equatable.dart';

import '../../../data/model/feedback.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final FeedbackModel? currentUserFeedback;
  final List<FeedbackModel> otherFeedbacks;

  const FeedbackLoaded({
    required this.currentUserFeedback,
    required this.otherFeedbacks,
  });

  @override
  List<Object?> get props => [currentUserFeedback, otherFeedbacks];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}
