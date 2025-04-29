/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

Widget buildAccountLinkingSection() {
  return BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AccountLinkingSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account linking successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    builder: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const SizedBox.shrink();

      final hasEmailProvider = user.providerData.any(
        (provider) => provider.providerId == 'password',
      );
      final hasGoogleProvider = user.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );
      final hasPhoneProvider = user.providerData.any(
        (provider) => provider.providerId == 'phone',
      );

      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login Methods',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (hasEmailProvider)
                const ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email/Password'),
                ),
              if (hasGoogleProvider)
                const ListTile(
                  leading: Icon(Icons.g_mobiledata),
                  title: Text('Google'),
                ),
              if (hasPhoneProvider)
                const ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone'),
                ),
              const Divider(),
              if (!hasGoogleProvider && hasEmailProvider)
                ListTile(
                  leading:
                      state is AuthLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.g_mobiledata),
                  title: const Text('Link Google Account'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  enabled: state is! AuthLoading,
                  onTap:
                      () => context.read<AuthBloc>().add(
                        LinkGoogleAccountEvent(),
                      ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
*/
