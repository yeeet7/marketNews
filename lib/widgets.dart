
import 'package:flutter/material.dart';
import 'package:market_news/main.dart';
import 'package:market_news/services/news_api.dart';

class NewsItemWidget extends StatelessWidget {
  const NewsItemWidget({required this.impact, required this.title, required this.timeType, required this.date, required this.currency, super.key});

  final Impact? impact;
  final String title;
  final TimeType timeType;
  final DateTime date;
  final Currency currency;

  @override
  Widget build(BuildContext context) {

    Color impactColor = impact == Impact.high ? Colors.red : impact == Impact.medium ? Colors.yellow : impact != null ? Colors.green : Colors.grey[800]!;
    String currencyFlag = currency == Currency.eur ? '🇪🇺' : currency == Currency.usd ? '🇺🇸' : currency == Currency.gbp ? '🇬🇧' : currency == Currency.jpy ? '🇯🇵' : currency == Currency.cad ? '🇨🇦' : currency == Currency.aud ? '🇦🇺' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[900],
        border: Border.all(
          color: impactColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: impactColor.withOpacity(0.25),
            blurRadius: 10,
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('$currencyFlag   ', style: const TextStyle(fontSize: 16)),
                  Text(timeType == TimeType.time ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}' : timeType == TimeType.tentative ? 'Tentative' : 'All Day',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                impact == Impact.high ? 'High' : impact == Impact.medium ? 'Medium' : impact != null ? 'Low' : 'Unknown',
                style: TextStyle(
                  fontSize: 16,
                  color: impactColor,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TodayDateChip extends StatelessWidget {
  const TodayDateChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Text('${DateTime.now().day} ${monthToString(DateTime.now().month)}',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}