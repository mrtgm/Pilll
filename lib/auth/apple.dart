import 'package:firebase_auth/firebase_auth.dart';
import 'package:pilll/auth/hash.dart';
import 'package:pilll/auth/link_value_container.dart';
import 'package:pilll/util/environment.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final appleProviderID = "apple.com";

enum SigninWithAppleState { determined, cancel }

Future<LinkValueContainer?> linkWithApple(User user) async {
  try {
    final rawNonce = generateNonce();
    final state = generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: Environment.siwaServiceIdentifier,
        redirectUri: Uri.parse(Environment.androidSiwaRedirectURL),
      ),
      nonce: sha256ofString(rawNonce).toString(),
      state: state,
    );
    print("appleCredential: $appleCredential");
    if (state != appleCredential.state) {
      throw AssertionError('state not matched!');
    }
    final email = appleCredential.email;
    final credential = OAuthProvider(appleProviderID).credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );
    final linkedCredential = await user.linkWithCredential(credential);
    return Future.value(LinkValueContainer(linkedCredential, email));
  } on SignInWithAppleAuthorizationException catch (e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      return Future.value(null);
    }
    rethrow;
  }
}

Future<UserCredential?> signInWithApple() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FormatException("Anonymous User not found");
  }
  try {
    // NOTE: Challenge to confirm for exists linked account
    try {
      final rawNonce = generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: Environment.siwaServiceIdentifier,
          redirectUri: Uri.parse(Environment.androidSiwaRedirectURL),
        ),
        nonce: sha256ofString(rawNonce).toString(),
      );
      final credential = OAuthProvider(appleProviderID).credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      final linkedCredential = await user.linkWithCredential(credential);
      return Future.value(linkedCredential);
    } on FirebaseAuthException catch (e) {
      print(
          "Catch exception about Challenge to confirm for exists linked user FirebaseAuthException: $e");
      if (e.code != "credential-already-in-use") rethrow;
    } catch (e) {
      print(
          "Catch exception about Challenge to confirm for exists linked user Unknown Exception: $e");
      rethrow;
    }

    print("It is not exists linked apple user");
    final rawNonce = generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: Environment.siwaServiceIdentifier,
        redirectUri: Uri.parse(Environment.androidSiwaRedirectURL),
      ),
      nonce: sha256ofString(rawNonce).toString(),
    );
    final credential = OAuthProvider(appleProviderID).credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on SignInWithAppleAuthorizationException catch (e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      return Future.value(null);
    }
    rethrow;
  }
}

bool isLinkedApple() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return false;
  }
  return isLinkedAppleFor(user);
}

bool isLinkedAppleFor(User user) {
  return user.providerData
      .where((element) => element.providerId == appleProviderID)
      .isNotEmpty;
}
