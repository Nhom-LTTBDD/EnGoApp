// lib/core/utils/auth_utils.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/providers/auth/auth_state.dart';

/// Utility class for authentication-related operations
class AuthUtils {
  // Private constructor to prevent instantiation
  AuthUtils._();

  /// Get current user ID from AuthProvider
  ///
  /// Returns the Firebase Authentication UID if user is authenticated,
  /// otherwise returns null.
  ///
  /// Example:
  /// ```dart
  /// final userId = AuthUtils.getCurrentUserId(context);
  /// if (userId != null) {
  ///   // Use userId for flashcard progress
  ///   await progressProvider.markAsMastered(userId, topicId, cardId);
  /// }
  /// ```
  static String? getCurrentUserId(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.state is Authenticated) {
      return (authProvider.state as Authenticated).user.id;
    }
    return null;
  }

  /// Get current user ID without context (listen: false)
  ///
  /// Useful in places where you can't use context.read()
  static String? getCurrentUserIdWithoutContext(AuthProvider authProvider) {
    if (authProvider.state is Authenticated) {
      return (authProvider.state as Authenticated).user.id;
    }
    return null;
  }

  /// Check if user is authenticated
  ///
  /// Returns true if user is logged in, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (AuthUtils.isAuthenticated(context)) {
  ///   // Show flashcard features
  /// } else {
  ///   // Show login prompt
  /// }
  /// ```
  static bool isAuthenticated(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.state is Authenticated;
  }

  /// Get current user email
  ///
  /// Returns the user's email if authenticated, otherwise null.
  static String? getCurrentUserEmail(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.state is Authenticated) {
      return (authProvider.state as Authenticated).user.email;
    }
    return null;
  }

  /// Get current user name
  ///
  /// Returns the user's name if authenticated, otherwise null.
  static String? getCurrentUserName(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.state is Authenticated) {
      return (authProvider.state as Authenticated).user.name;
    }
    return null;
  }

  /// Require authentication - throws error if not authenticated
  ///
  /// Use this when you absolutely need a userId and want to fail fast.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final userId = AuthUtils.requireUserId(context);
  ///   // Use userId safely
  /// } catch (e) {
  ///   // Handle not authenticated error
  /// }
  /// ```
  static String requireUserId(BuildContext context) {
    final userId = getCurrentUserId(context);
    if (userId == null) {
      throw Exception('User must be authenticated to perform this action');
    }
    return userId;
  }
}
