import 'package:medical_onboarding_app/features/messaging/data/message_api.dart';
import 'package:medical_onboarding_app/features/messaging/data/message_model.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApi api;

  MessageRepositoryImpl(this.api);

  @override
  Future<List<Message>> getMessages(String customerId) async {
    final models = await api.fetchMessages(customerId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveMessages(String customerId, List<Message> messages) {
    final models = messages.map((e) => MessageModel.fromEntity(e)).toList();
    return api.saveMessages(customerId, models);
  }
}
