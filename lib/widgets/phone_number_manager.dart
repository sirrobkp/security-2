import 'package:flutter/material.dart';
import '../models/phone_number.dart';

class PhoneNumberManager extends StatefulWidget {
  final List<PhoneNumber> phoneNumbers;
  final Function(PhoneNumber) onAdd;
  final Function(String) onRemove;
  final Function(String) onSetPrimary;

  const PhoneNumberManager({
    super.key,
    required this.phoneNumbers,
    required this.onAdd,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  State<PhoneNumberManager> createState() => _PhoneNumberManagerState();
}

class _PhoneNumberManagerState extends State<PhoneNumberManager> {
  bool _isAdding = false;
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Color(0xFF4ade80),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WhatsApp Numbers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => setState(() => _isAdding = !_isAdding),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3b82f6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isAdding ? Icons.close : Icons.add,
                    color: const Color(0xFF60a5fa),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Receive instant alerts with camera snapshots on WhatsApp',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Add Form
          if (_isAdding) ...[
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
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Contact Name',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      hintText: 'e.g., Security Team',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      hintText: '+255787696568',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3b82f6),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Number',
                      style: TextStyle(color: Colors.white))
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Phone List
          if (widget.phoneNumbers.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.phone,
                    size: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No phone numbers added',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ...widget.phoneNumbers.map((phone) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => widget.onSetPrimary(phone.id),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: phone.isPrimary
                                ? const Color(0xFF22c55e)
                                : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          color: phone.isPrimary
                              ? const Color(0xFF22c55e)
                              : Colors.transparent,
                        ),
                        child: phone.isPrimary
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phone.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            phone.number,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (phone.isPrimary)
                      Container(
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => widget.onRemove(phone.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFf87171),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _handleAdd() {
    if (_nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty) {
      widget.onAdd(
        PhoneNumber(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          number: _numberController.text.trim(),
          isPrimary: widget.phoneNumbers.isEmpty,
        ),
      );
      _nameController.clear();
      _numberController.clear();
      setState(() => _isAdding = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }
}
