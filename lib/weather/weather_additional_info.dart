//  =============================================   Additional info template
import 'package:flutter/material.dart';

class WeatherAdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String lebel;
  final num value;

  const WeatherAdditionalInfo({
    super.key,
    required this.icon,
    required this.lebel,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(height: 7),
        Text(lebel, style: const TextStyle(fontWeight: FontWeight.w400)),
        const SizedBox(height: 7),
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
