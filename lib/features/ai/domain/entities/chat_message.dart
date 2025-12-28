import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? productIds; // For recommended product cards
  final Map<String, dynamic>? cartAction; // For "Add to Cart" JSON

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.productIds,
    this.cartAction,
  });

  @override
  List<Object?> get props => [id, text, isUser, timestamp, productIds, cartAction];
}
