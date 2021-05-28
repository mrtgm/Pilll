import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pilll/entity/link_account_type.dart';

part 'signin_sheet_state.freezed.dart';

@freezed
abstract class SigninSheetState implements _$SigninSheetState {
  SigninSheetState._();
  factory SigninSheetState({
    required bool isLoginMode,
  }) = _SigninSheetState;

  String get title => isLoginMode ? "ログイン" : "アカウント登録";
  String get message => isLoginMode
      ? "ログイン前に行った記録は引き継げません。ログインするとログイン時のアカウント情報が表示されます。"
      : "アカウント登録するとデータの引き継ぎが可能になります";
  String get appleButtonText => isLoginMode
      ? LinkAccountType.apple.providerName + "でサインイン"
      : LinkAccountType.apple.providerName + "で登録";
  String get googleButtonText => isLoginMode
      ? LinkAccountType.google.providerName + "でサインイン"
      : LinkAccountType.google.providerName + "で登録";
}
