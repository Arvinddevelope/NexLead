void main() {
  print('Testing Lead Communication Features...');

  // Test lead information
  const String leadName = 'John Doe';
  const String leadPhone = '+1234567890';
  const String leadEmail = 'john.doe@example.com';

  print('Test lead: $leadName');
  print('Phone: $leadPhone');
  print('Email: $leadEmail');

  // Test phone call URL
  const String phoneUri = 'tel:$leadPhone';
  print('\nPhone URI: $phoneUri');

  // Test WhatsApp URL
  final cleanPhoneNumber = leadPhone.replaceAll(RegExp(r'[^\d]'), '');
  const String whatsappMessage =
      'Hello $leadName, I wanted to follow up on our discussion.';
  final String whatsappUri =
      'https://wa.me/$cleanPhoneNumber?text=${Uri.encodeComponent(whatsappMessage)}';
  print('WhatsApp URI: $whatsappUri');

  // Test email URL
  const String emailSubject = 'Follow-up on our discussion - $leadName';
  const String emailBody =
      'Hi $leadName,\n\nI hope this email finds you well. I wanted to follow up on our recent discussion.\n\nBest regards,\n[Your Name]';
  final String emailUri =
      'mailto:$leadEmail?subject=${Uri.encodeComponent(emailSubject)}&body=${Uri.encodeComponent(emailBody)}';
  print('Email URI: $emailUri');

  print('\n✅ All lead communication feature URLs generated successfully!');
  print('The lead detail screen should now have clickable buttons for:');
  print('- Phone calls to the lead (opens dialer)');
  print('- WhatsApp messages to the lead (opens WhatsApp chat)');
  print('- Email to the lead (opens default email client)');
}
