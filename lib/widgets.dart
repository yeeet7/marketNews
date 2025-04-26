
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_news/main.dart';
import 'package:market_news/services/news_api.dart';

class NewsItemListTile extends StatelessWidget {
  const NewsItemListTile({required this.newsItem, super.key});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    
    Color impactColor = newsItem.impact == Impact.high ? Colors.red : newsItem.impact == Impact.medium ? Colors.orange.shade400 : newsItem.impact != null ? Colors.green : Colors.grey[800]!;

    return GestureDetector(
      onTap: () => showCupertinoSheet(context: context, pageBuilder: (context) => NewsItemDetailsWidget(newsItem)),
      child: Container(
        padding: const EdgeInsets.all(8),
        // color: Colors.red.withOpacity(0.25),
        width: MediaQuery.of(context).size.width - (textToSize('24:00', TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)).width + 16*2 + 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(flex: 3, fit: FlexFit.tight, child: Center(child: Text('${currencyFlag(newsItem.currency)} ${newsItem.currency.name.toUpperCase()}', style: const TextStyle(fontSize: 16)))),
            Flexible(
              flex: 7,
              fit: FlexFit.tight,
              child: Text(
                newsItem.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: textToSize('Medium', TextStyle(color: impactColor, fontSize: 16)).width + 16,
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
                  newsItem.impact == Impact.high ? 'High' : newsItem.impact == Impact.medium ? 'Medium' : newsItem.impact != null ? 'Low' : 'None',
                  style: TextStyle(
                    fontSize: 16,
                    color: impactColor,
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

class NewsItemDetailsWidget extends StatelessWidget {
  const NewsItemDetailsWidget(this.newsItem, {super.key});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            //* appBar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${currencyFlag(newsItem.currency)} ${newsItem.currency.name.toUpperCase()}'),
                ),

                CupertinoButton(
                  // minSize: 44,
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text('Done', style: TextStyle(color: Colors.blue))
                ),

              ],
            ),
            Divider(color: Theme.of(context).colorScheme.primary, height: 0),

            //* body
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(8),
              ),

              child: newsItem.date.difference(DateTime.now()).isNegative ? Text('started ${newsItem.date.difference(DateTime.now()).inHours.abs()} hours ago',
                style: TextStyle(color: Theme.of(context).primaryColor)
              ) : Text('starts in ${newsItem.date.difference(DateTime.now()).inHours} hours',
                style: TextStyle(color: Theme.of(context).primaryColor)
              ),
            ),

            //* title
            Text(
              newsItem.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            if(newsItem.usualEffect != null) Box(title: 'Usual effect', description: Text(newsItem.usualEffect == UsualEffect.higherGood ? 'actual > forecast = good' : 'actual < forecast = good'), icon: Icons.trending_up_rounded, color: Colors.purple),
            
            if([newsItem.forecast, newsItem.actual, newsItem.previous].any((element) => element != null)) Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Box(title: 'Impact', width: MediaQuery.of(context).size.width / 2 - 16*2, description: Text(newsItem.impact?.name ?? 'N/A'), color: newsItem.impact == Impact.high ? Colors.red : newsItem.impact == Impact.medium ? Colors.orange.shade400 : Colors.grey[800]),
                    Box(title: 'Previous', width: MediaQuery.of(context).size.width / 2 - 16*2, description: Text(newsItem.previous?.toString() ?? 'N/A'), color: Colors.grey[800]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Box(title: 'Forecast', width: MediaQuery.of(context).size.width / 2 - 16*2, description: Text(newsItem.forecast?.toString() ?? 'N/A'), color: Colors.green),
                    Box(title: 'Actual', width: MediaQuery.of(context).size.width / 2 - 16*2, description: Text(newsItem.actual?.toString() ?? 'N/A'), color: Colors.red),
                  ],
                )
              ],
            )
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

class Box extends StatelessWidget {
  const Box({required this.title, required this.description, this.icon, this.color, this.width, super.key});

  final IconData? icon;
  final String title;
  final Widget description;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color?.withValues(alpha: .5) ?? Theme.of(context).colorScheme.primary.withValues(alpha: .5),
          width: 1,
        )
      ),
      child: Column(
        children: [
          Row(
            children: [
              if(icon != null) Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),                
            ],
          ),
          const SizedBox(height: 8),
          description
        ],
      ),
    );
  }
}

class AppBarBottom extends StatefulWidget implements PreferredSizeWidget {
  // const AppBarBottom(this.events, {super.key});
  const AppBarBottom({this.onSizeChanged, super.key});
  final VoidCallback? onSizeChanged;

  // final List<NewsItem> events;

  @override
  Size get preferredSize => Size.fromHeight(textToSize('${dayToString(DateTime.now().weekday)} - ${DateTime.now().day} ${monthToString(DateTime.now().month)} ${DateTime.now().year}', null).height + 11+16);


  @override
  State<AppBarBottom> createState() => _AppBarBottomState();
}

class _AppBarBottomState extends State<AppBarBottom> {

  final GlobalKey _key = GlobalKey();
  Size _preferredSize = Size.zero;

  @override
  void initState() {
    super.initState();
    // Measure size after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Measure size after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  void _updateSize() {
    if (!mounted) return;
    final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final newSize = renderBox.size;
      if (newSize != _preferredSize) {
        setState(() {
          _preferredSize = newSize;
        });
        widget.onSizeChanged?.call();
      }
    }
    // Schedule another check in case content changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: _key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(width: MediaQuery.of(context).size.width, height: 1, color: Theme.of(context).colorScheme.primary),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [DateText(DateTime.now(), true)]),
          // StreamBuilder( //!/FIXME
          //   stream: todayStreamController.stream,
          //   builder: (context, snapshot) {
          //     if(snapshot.data?.where((e) => e.timeType == TimeType.allDay || e.timeType == TimeType.tentative).isEmpty ?? true) return const SizedBox();
          //     return Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text('All Day', style: TextStyle(color: Colors.grey, fontSize: 12)),
          //         const SizedBox(width: 8),
          //         Column(children: snapshot.data!.where((e) => e.timeType == TimeType.allDay).map((e) => NewsItemListTile(impact: e.impact, title: e.title, timeType: e.timeType, date: e.date, currency: e.currency)).toList(),)
          //         // Icon(Icons.circle, size: 8, color: Theme.of(context).colorScheme.primary.withValues(alpha: .75)),
          //         // const SizedBox(width: 8),
          //         // Text('${snapshot.data?.where((e) => e.timeType == TimeType.allDay || e.timeType == TimeType.tentative).length} events', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          //       ],
          //     );   
          //   }
          // ),
          Container(width: MediaQuery.of(context).size.width, height: 1, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }
  
  // Size.fromHeight(textToSize('${dayToString(DateTime.now().weekday)} - ${DateTime.now().day} ${monthToString(DateTime.now().month)} ${DateTime.now().year}', null).height + 11+16);
  Size get preferredSize => _preferredSize;

}

Size textToSize(String text, TextStyle? style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return textPainter.size;
}

String currencyFlag(currency) => currency == Currency.eur ? '🇪🇺' : currency == Currency.usd ? '🇺🇸' : currency == Currency.gbp ? '🇬🇧' : currency == Currency.jpy ? '🇯🇵' : currency == Currency.cad ? '🇨🇦' : currency == Currency.aud ? '🇦🇺' : '';