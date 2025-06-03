import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('helpAndSupport'.tr()),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('faqTitle'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ..._buildFAQItems(context),
          const SizedBox(height: 24),
          Text('contactUs'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildContactInfo(Icons.email, 'duyphanz0v0z@gmail.com'),
          _buildContactInfo(Icons.phone, '+0379674900'),
        ],
      ),
    );
  }

  List<Widget> _buildFAQItems(BuildContext context) {
    return [
      _buildFAQItem(
        context: context,
        question: 'faqItem1'.tr(),
        answer: 'faqAnswer1'.tr(),
      ),
      _buildFAQItem(
        context: context,
        question: 'faqItem2'.tr(),
        answer: 'faqAnswer2'.tr(),
      ),
    ];
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildContactInfo(IconData icon, String info) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryMedium),
      title: Text(info),
    );
  }
}
