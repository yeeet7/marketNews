
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_news/main.dart';
import 'package:market_news/services/news_api.dart';

class NewsItemListTile extends StatelessWidget {
  const NewsItemListTile({required this.impact, required this.title, required this.timeType, required this.date, required this.currency, super.key});

  final Impact? impact;
  final String title;
  final TimeType timeType;
  final DateTime date;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    
    Color impactColor = impact == Impact.high ? Colors.red : impact == Impact.medium ? Colors.orange.shade400 : impact != null ? Colors.green : Colors.grey[800]!;
    String currencyFlag = currency == Currency.eur ? '🇪🇺' : currency == Currency.usd ? '🇺🇸' : currency == Currency.gbp ? '🇬🇧' : currency == Currency.jpy ? '🇯🇵' : currency == Currency.cad ? '🇨🇦' : currency == Currency.aud ? '🇦🇺' : '';

    return GestureDetector(
      onTap: () => showCupertinoSheet(context: context, pageBuilder: (context) => Scaffold(body: Center(child: Button('done', onTap: () => Navigator.of(context, rootNavigator: true).pop(),),)),),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal  : BorderSide(color: Theme.of(context).colorScheme.primary, width: .125)
          )
        ),
        // color: Colors.red.withOpacity(0.25),
        width: MediaQuery.of(context).size.width - (textToSize('24:00', TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)).width + 16*2),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(flex: 3, fit: FlexFit.tight, child: Center(child: Text('$currencyFlag ${currency.name.toUpperCase()}', style: const TextStyle(fontSize: 16)))),
            Flexible(
              flex: 7,
              fit: FlexFit.tight,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: impactColor.withValues(alpha: .25),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        spreadRadius: 3,
                        color: impactColor.withValues(alpha: .25),
                      )
                    ]
                  ),
                  child: Text(
                    impact == Impact.high ? 'High' : impact == Impact.medium ? 'Medium' : impact != null ? 'Low' : 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      color: impactColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Filters extends StatefulWidget {
  const Filters({required this.onApply, required this.onCancel, super.key});

  final void Function(bool pastEvents, List<bool> impacts, List<bool> currencies) onApply;
  final VoidCallback onCancel;

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {

  bool _pastEvents = true;
  final List<bool> _impacts = List.generate(Impact.values.length, (index) => true);
  final List<bool> _currencies = List.generate(Currency.values.length, (index) => true);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(55 - 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('  Past Events', style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(flex: 1, child: Button('Show', icon: Icons.remove_red_eye_rounded, filled: _pastEvents, onTap: () => setState(() => _pastEvents = true),)),
              Flexible(flex: 1, child: Button('Hide', icon: Icons.remove_red_eye_outlined, filled: !_pastEvents, onTap: () => setState(() => _pastEvents = false),)),
            ],
          ),
          const SizedBox(height: 16),
          Text('  Impact Filter', style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(flex: 1, child: Toggle(text: 'Low', color: Colors.green, isSelected: _impacts[Impact.low.index], onTap: () {_impacts[Impact.low.index] = !_impacts[Impact.low.index]; setState(() {});})),
              Flexible(flex: 1, child: Toggle(text: 'Medium', color: Colors.orange.shade400, isSelected: _impacts[Impact.medium.index], onTap: () {_impacts[Impact.medium.index] = !_impacts[Impact.medium.index]; setState(() {});})),
              Flexible(flex: 1, child: Toggle(text: 'High', color: Colors.red, isSelected: _impacts[Impact.high.index], onTap: () {_impacts[Impact.high.index] = !_impacts[Impact.high.index]; setState(() {});})),
            ],
          ),
          const SizedBox(height: 16),
          Text('  Currency Filter', style: TextStyle(color: Colors.grey[800], fontSize: 18, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(Currency.values.length ~/ 2, (index) => Flexible(flex: 1, child: Button(Currency.values[index].name.toUpperCase(), filled: _currencies[index], onTap: () {_currencies[index] = !_currencies[index]; setState(() {});}))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(Currency.values.length ~/ 2, (index) => Flexible(flex: 1, child: Button(Currency.values[index + 3].name.toUpperCase(), filled: _currencies[index + 3], onTap: () {_currencies[index + 3] = !_currencies[index + 3]; setState(() {});}))),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Flexible(flex: 1, child: Button('cancel', filled: false, onTap: () => widget.onCancel())),
              Flexible(flex: 1, child: Button('apply', onTap: () => widget.onApply(_pastEvents, _impacts, _currencies))),
            ],
          ),
        ],
      ),
    );
  }
}

class Toggle extends StatelessWidget {
  const Toggle({required this.text, required this.color, required this.isSelected, this.onTap, super.key});

  final bool isSelected;
  final Color color;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withValues(alpha: .25) : color.withValues(alpha: 0),
          border: Border.all(
            color: color,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withValues(alpha: .25) : color.withValues(alpha: 0),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ]
        ),
        child: Center(child: Text(text, style: TextStyle(color: color)))
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button(this.text, {this.icon, this.filled = true, this.onTap, super.key});

  final bool filled;
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: filled ? Theme.of(context).primaryColor.withValues(alpha: .25) : Theme.of(context).primaryColor.withValues(alpha: 0),
          border: Border.all(
            color: filled ? Theme.of(context).colorScheme.primary.withValues(alpha: 0) : Theme.of(context).colorScheme.primary,
            strokeAlign: BorderSide.strokeAlignInside,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(icon != null) Icon(icon!, color: filled ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primary),
            if(icon != null) const SizedBox(width: 8),
            Text(text, style: TextStyle(color: filled ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class DateText extends StatelessWidget {
  const DateText(this.date, this.highlight, {super.key});

  final DateTime date;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? Theme.of(context).primaryColor.withValues(alpha: .25) : Theme.of(context).colorScheme.primary.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('${dayToString(date.weekday)} - ${date.day} ${monthToString(date.month)} ${date.year}',
        style: highlight ? TextStyle(color: Theme.of(context).primaryColor) : null
      )
    );
  }
}

class AppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarBottom({super.key});

  @override
  Size get preferredSize => Size.fromHeight(textToSize('${dayToString(DateTime.now().weekday)} - ${DateTime.now().day} ${monthToString(DateTime.now().month)} ${DateTime.now().year}', null).height + 11+16);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: MediaQuery.of(context).size.width, height: 1, color: Theme.of(context).colorScheme.primary),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [DateText(DateTime.now(), true)]),
        Container(width: MediaQuery.of(context).size.width, height: 1, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

Size textToSize(String text, TextStyle? style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size;
}