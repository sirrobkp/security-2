import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/alert.dart';
import '../models/phone_number.dart';

class WhatsAppModal extends StatefulWidget {
  final Alert alert;
  final List<PhoneNumber> phoneNumbers;

  const WhatsAppModal({
    super.key,
    required this.alert,
    required this.phoneNumbers,
  });

  @override
  State<WhatsAppModal> createState() => _WhatsAppModalState();
}

class _WhatsAppModalState extends State<WhatsAppModal> {
  late List<String> _selectedNumbers;
  bool _isSending = false;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    _selectedNumbers = widget.phoneNumbers
        .where((p) => p.isPrimary)
        .map((p) => p.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Send Alert via WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share threat detection with your team',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Snapshot Preview
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white30,
                              size: 48,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.alert.type.toUpperCase()} DETECTED',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Confidence: ${widget.alert.confidence}%',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Message Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Message Preview:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🚨 *SECURITY ALERT*\n\n'
                          '*${widget.alert.type.toUpperCase()} DETECTED*\n'
                          'Confidence: ${widget.alert.confidence}%\n'
                          'Time: ${widget.alert.timestamp.toString()}\n\n'
                          'Please check the attached image.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recipients
                  const Text(
                    'Send to:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (widget.phoneNumbers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'No phone numbers configured',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Add numbers in settings',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...widget.phoneNumbers.map((phone) {
                      final isSelected = _selectedNumbers.contains(phone.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              _selectedNumbers.add(phone.id);
                            } else {
                              _selectedNumbers.remove(phone.id);
                            }
                          });
                        },
                        title: Text(
                          phone.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          phone.number,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                        secondary: phone.isPrimary
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22c55e).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Primary',
                                  style: TextStyle(
                                    color: Color(0xFF4ade80),
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : null,
                      );
                    }),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectedNumbers.isEmpty || _isSending || _isSent
                              ? null
                              : _handleSend,
                          icon: Icon(
                            _isSent ? Icons.check : Icons.send,
                          ),
                          label: Text(
                            _isSent
                                ? 'Sent!'
                                : _isSending
                                    ? 'Sending...'
                                    : 'Send (${_selectedNumbers.length})',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    setState(() => _isSending = true);

    // Simulate sending
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, you would:
    // 1. Send WhatsApp message using url_launcher
    // 2. Upload snapshot to server
    // 3. Send link via WhatsApp API

    for (final phoneId in _selectedNumbers) {
      final phone = widget.phoneNumbers.firstWhere((p) => p.id == phoneId);
      final message = '🚨 *SECURITY ALERT*\n\n'
          '*${widget.alert.type.toUpperCase()} DETECTED*\n'
          'Confidence: ${widget.alert.confidence}%\n'
          'Time: ${widget.alert.timestamp}\n\n'
          'Please check immediately.';

      final whatsappUrl = 'whatsapp://send?phone=${phone.number}&text=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      }
    }

    setState(() {
      _isSending = false;
      _isSent = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
