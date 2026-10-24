import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Reads only public provider availability. No OAuth client secret is used.
class OAuthProviderSettings {
  OAuthProviderSettings({
    required String supabaseUrl,
    required this.publishableKey,
    required this.provider,
    http.Client? client,
  }) : _url = Uri.parse('$supabaseUrl/auth/v1/settings'),
       _client = client;

  final OAuthProvider provider;
  String get _label => switch (provider) {
    OAuthProvider.apple => 'Apple',
    OAuthProvider.google => 'Google',
    _ => provider.name,
  };

  final Uri _url;
  final String publishableKey;
  final http.Client? _client;

  Future<bool> isEnabled() async {
    try {
      final headers = {'apikey': publishableKey};
      final response =
          await (_client?.get(_url, headers: headers) ??
                  http.get(_url, headers: headers))
              .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw AuthFailure('تعذّر التحقق من خدمة $_label. حاول مرة أخرى.');
      }
      final settings = jsonDecode(response.body);
      if (settings is! Map<String, dynamic> || settings['external'] is! Map) {
        throw const FormatException();
      }
      return (settings['external'] as Map)[provider.name] == true;
    } on TimeoutException {
      throw const AuthFailure(
        'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
      );
    } on http.ClientException {
      throw const AuthFailure(
        'تعذّر الاتصال بالخادم. تحقق من اتصال الإنترنت وحاول مرة أخرى.',
      );
    } on FormatException {
      throw AuthFailure('تعذّر التحقق من خدمة $_label. حاول مرة أخرى.');
    }
  }
}
