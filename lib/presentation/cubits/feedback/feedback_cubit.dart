import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/feedback/get_current_user_feedback_for_route_usecase.dart';
import '../../../domain/usecases/feedback/get_feedbacks_by_route_excluding_current_user_usecase.dart';
import '../../../domain/usecases/feedback/send_feedback_usecase.dart';
import '../../../domain/usecases/feedback/update_feedback_usecase.dart';
import 'feedback_state.dart';

@injectable
class FeedbackCubit extends Cubit<FeedbackState> {
  final GetCurrentUserFeedbackForRouteUseCase getCurrentUserFeedbackForRoute;
  final GetFeedbacksByRouteExcludingCurrentUserUseCase getOtherFeedbacks;
  final SendFeedbackUseCase sendFeedback;
  final UpdateFeedbackUseCase updateFeedback;

  FeedbackCubit({
    required this.getCurrentUserFeedbackForRoute,
    required this.getOtherFeedbacks,
    required this.sendFeedback,
    required this.updateFeedback,
  }) : super(FeedbackInitial());

  Future<void> loadFeedback(String routeId) async {
    emit(FeedbackLoading());
    try {
      final userFeedback = await getCurrentUserFeedbackForRoute(routeId);
      final others = await getOtherFeedbacks(routeId);
      emit(
        FeedbackLoaded(
          currentUserFeedback: userFeedback,
          otherFeedbacks: others,
        ),
      );
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> submit({
    required String routeId,
    required int rating,
    String? content,
  }) async {
    emit(FeedbackLoading());
    try {
      await sendFeedback(routeId: routeId, rating: rating, content: content);
      await loadFeedback(routeId);
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> update({
    required String routeId,
    required String feedbackId,
    required int rating,
    String? content,
  }) async {
    emit(FeedbackLoading());
    try {
      await updateFeedback(
        feedbackId: feedbackId,
        rating: rating,
        content: content,
      );
      await loadFeedback(routeId);
    } catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }
}
