import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pilll/emoji/emoji.dart';

part 'reminder_notification_customization.g.dart';
part 'reminder_notification_customization.freezed.dart';

@freezed
class ReminderNotificationCustomization
    with _$ReminderNotificationCustomization {
  @JsonSerializable(explicitToJson: true)
  const factory ReminderNotificationCustomization({
    @Default(pill) String word,
    @Default(false) bool isInVisibleReminderDate,
    @Default(false) bool isInVisiblePillNumber,
    @Default(false) bool isInVisibleDescription,
  }) = _ReminderNotificationCustomization;
  const ReminderNotificationCustomization._();

  factory ReminderNotificationCustomization.fromJson(
          Map<String, dynamic> json) =>
      _$ReminderNotificationCustomizationFromJson(json);
}