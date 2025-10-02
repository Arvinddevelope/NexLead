void main() async {
  print('Testing Communication Features...');

  // Test phone number
  const String testPhoneNumber = '+1234567890';

  // Test email
  const String testEmail = 'support@example.com';

  // Test message
  const String testMessage = 'Hello, I need help with the app.';

  print('Test phone number: $testPhoneNumber');
  print('Test email: $testEmail');
  print('Test message: $testMessage');

  // Test phone call URL
  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: testPhoneNumber,
  );
  print('\nPhone URI: $phoneUri');

  // Test WhatsApp URL
  final cleanPhoneNumber = testPhoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  final Uri whatsappUri = Uri(
    scheme: 'https',
    host: 'wa.me',
    path: cleanPhoneNumber,
    queryParameters: {'text': testMessage},
  );
  print('WhatsApp URI: $whatsappUri');

  // Test email URL
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: testEmail,
    queryParameters: {
      'subject': 'Support Request',
      'body': testMessage,
    },
  );
  print('Email URI: $emailUri');

  print('\n✅ All communication feature URLs generated successfully!');
  print('The dashboard should now have clickable buttons for:');
  print('- Phone calls (opens dialer)');
  print('- WhatsApp messages (opens WhatsApp chat)');
  print('- Email (opens default email client)');
}
