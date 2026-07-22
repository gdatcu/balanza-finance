import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Fetch database categories diagnostic', () async {
    print('Initializing Supabase...');
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://rlgnmcqergdjuxknhqhw.supabase.co',
      publishableKey: 'sb_publishable_qI0TdNv5VJQpKvlkSCassA_1slJiy9K',
    );

    final client = Supabase.instance.client;
    print('Signing up diagnostic user...');
    try {
      // Use signInWithPassword or signUp. If user already exists, we catch and sign in.
      try {
        await client.auth.signUp(
          email: 'diag_user_unique_999@example.com',
          password: 'password123',
        );
        print('Signed up successfully.');
      } catch (e) {
        print('Sign up failed with: $e');
        await client.auth.signInWithPassword(
          email: 'diag_user_unique_999@example.com',
          password: 'password123',
        );
        print('Signed in successfully.');
      }

      print('Fetching categories...');
      final response = await client.from('categories').select();
      print('Fetched ${response.length} categories:');
      for (var cat in response) {
        print('Category: id=${cat['id']}, name=${cat['name']}, user_id=${cat['user_id']}');
      }
    } catch (e) {
      print('Error during auth or fetch: $e');
    }
  });
}
