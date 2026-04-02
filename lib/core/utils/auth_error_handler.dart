import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// 인증 관련 에러를 사용자 친화적인 메시지로 변환하는 유틸리티
class AuthErrorHandler {
  static String getErrorMessage(dynamic e, bool isEn) {
    if (e is FirebaseAuthException) {
      return _handleFirebaseAuthError(e.code, isEn);
    } else if (e is PlatformException) {
      return _handlePlatformError(e.code, isEn);
    }

    // 기타 알 수 없는 에러
    final errorStr = e.toString();
    if (errorStr.contains('canceled') || errorStr.contains('cancelled')) {
      return isEn ? 'Login canceled' : '로그인이 취소되었습니다.';
    }

    return isEn ? 'An unknown error occurred' : '알 수 없는 오류가 발생했습니다.';
  }

  static String _handleFirebaseAuthError(String code, bool isEn) {
    switch (code) {
      case 'user-disabled':
        return isEn ? 'This account has been disabled' : '비활성화된 계정입니다.';
      case 'user-not-found':
        return isEn ? 'Account not found' : '등록되지 않은 계정입니다.';
      case 'wrong-password':
        return isEn ? 'Incorrect password' : '비밀번호가 틀렸습니다.';
      case 'email-already-in-use':
        return isEn ? 'This email is already in use' : '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return isEn ? 'Invalid email format' : '유효하지 않은 이메일 형식입니다.';
      case 'operation-not-allowed':
        return isEn ? 'Operation not allowed' : '허용되지 않은 작업입니다.';
      case 'weak-password':
        return isEn ? 'Password is too weak' : '비밀번호가 너무 취약합니다.';
      case 'network-request-failed':
        return isEn
            ? 'Network error. Please check your connection'
            : '네트워크 연결이 원활하지 않습니다.';
      case 'too-many-requests':
        return isEn
            ? 'Too many attempts. Try again later'
            : '너무 많은 시도가 있었습니다. 나중에 다시 시도해주세요.';
      case 'account-exists-with-different-credential':
        return isEn
            ? 'An account already exists with the same email'
            : '이미 동일한 이메일로 가입된 계정이 존재합니다.';
      default:
        return isEn ? 'Authentication failed ($code)' : '인증에 실패했습니다 ($code)';
    }
  }

  static String _handlePlatformError(String code, bool isEn) {
    switch (code) {
      case 'sign_in_canceled':
        return isEn ? 'Login canceled' : '로그인이 취소되었습니다.';
      case 'network_error':
        return isEn
            ? 'Network error. Please check your connection'
            : '네트워크 연결 오류가 발생했습니다.';
      default:
        return isEn ? 'System error ($code)' : '시스템 오류가 발생했습니다 ($code)';
    }
  }
}
