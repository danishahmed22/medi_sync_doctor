import 'package:medisync_doctor/features/clinic_flow/domain/entities/token_entity.dart';

class GetEstimatedWaitTime {
  const GetEstimatedWaitTime();

  /// Calculates wait time based on patients ahead and clinic average.
  /// 
  /// waitTime = (patientsAhead * avgConsultationTime)
  double call({
    required List<TokenEntity> waitingQueue,
    required double avgConsultationTime,
    required String targetTokenId,
  }) {
    if (waitingQueue.isEmpty) return 0;

    // Find index of target token in the WAITING list
    final index = waitingQueue.indexWhere((t) => t.tokenId == targetTokenId);
    if (index == -1) return 0;

    // Wait time is based on how many people are in front of this token
    return index * avgConsultationTime;
  }
}
