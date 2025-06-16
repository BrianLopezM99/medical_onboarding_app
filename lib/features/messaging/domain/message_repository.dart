import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages(String customerId);
  Future<void> saveMessages(String customerId, List<Message> messages);
}
