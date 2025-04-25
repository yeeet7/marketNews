
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

abstract class NewsApi {

  static Future<List<NewsItem>?> today() async {
    /// Fetches the news data from Forex Factory
    final url = Uri.parse('https://www.forexfactory.com');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load news data: ${response.statusCode}');
    }

    // Parse the HTML response using BeautifulSoup
    //? document.querySelector('.site .site__inner .site__content .content .layout .layout__row .layout__column .layout__cell .calendar table tbody')
    BeautifulSoup bs = BeautifulSoup(response.body);
    // final calendarTable = bs.find('', selector: '.site .site__inner .site__content .content .layout .layout__row .layout__column .layout__cell .calendar table tbody');
    final rows = bs.findAll('', selector: '.site .site__inner .site__content .content .layout .layout__row');
    final column = rows[1].find('', selector: '.layout__column');
    final calendarTable = column!.find('', selector: '.layout__cell .calendar__table tbody');
    final newsItemsTags = calendarTable?.findAll('', selector: 'tr[data-event-id]');
    
    List<NewsItem> newsItemsList = [];
    String lastDate = '';
    for (var item in newsItemsTags!) {

      // get impact
      late final Impact? impact;
      String impactString = item.find('', selector: 'td.calendar__impact')!.children.first.attributes['class']!.split(' ')[1];
      switch (impactString.split('ff-')[1]) {
        case 'impact-yel':
          impact = Impact.low;
          break;
        case 'impact-ora':
          impact = Impact.medium;
          break;
        case 'impact-red':
          impact = Impact.high;
          break;
        default:
          impact = null;
          break;
      }
      
      // get currency
      late final Currency? currency;
      String currencyString = item.find('', selector: 'td.calendar__currency')!.innerHtml.toUpperCase();
      switch (currencyString) {
        case 'EUR':
          currency = Currency.eur;
          break;
        case 'USD':
          currency = Currency.usd;
          break;
        case 'GBP':
          currency = Currency.gbp;
          break;
        case 'JPY':
          currency = Currency.jpy;
          break;
        case 'AUD':
          currency = Currency.aud;
          break;
        case 'CAD':
          currency = Currency.cad;
          break;
        default:
          currency = Currency.aud;
          break;
      }

      final id = int.parse(item.attributes['data-event-id']!);
      final title = item.find('', selector: 'td.calendar__event span')!.text;
      
      // Parse time and convert to 24-hour format
      String timeString = item.find('', selector: 'td.calendar__time')!.text.trim();
      late TimeType timeType;

      timeString.isEmpty ? timeString = lastDate : lastDate = timeString;
      timeString == 'Tentative' ? timeType = TimeType.tentative : timeString == 'All Day' ? timeType = TimeType.allDay : RegExp(r'(\d+):(\d+)(am|pm)').firstMatch(timeString) != null ? timeType = TimeType.time : timeType = TimeType.unknown;
      
      late DateTime date;
      if(timeType == TimeType.time) {
        final timeParts = RegExp(r'(\d+):(\d+)(am|pm)').firstMatch(timeString);
        final hour = int.parse(timeParts!.group(1)!);
        final minute = int.parse(timeParts.group(2)!);
        final period = timeParts.group(3)!;

        final hour24 = (period == 'pm' && hour != 12) ? hour + 12 : (period == 'am' && hour == 12) ? 0 : hour;
        date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour24, minute);
      } else {
        date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
      }

      final doubleRegex = RegExp(r'-?[\d.,]+');

      // final double? previous = double.tryParse(doubleRegex.firstMatch(item.find('', selector: 'td.calendar__previous span')?.innerHtml ?? '')?.group(0) ?? '');
      bool? isGreen;
      if(item.find('', selector: 'td.calendar__actual span')?.className != null) {
        isGreen = item.find('', selector: 'td.calendar__actual span')!.className.contains('better') ? true : item.find('', selector: 'td.calendar__actual span')!.className.contains('worse') ? false : null;
      }
      final double? forecast = double.tryParse(doubleRegex.firstMatch(item.find('', selector: 'td.calendar__forecast span')?.innerHtml ?? '')?.group(0) ?? '');
      final double? actual = double.tryParse(doubleRegex.firstMatch(item.find('', selector: 'td.calendar__actual span')?.innerHtml ?? '')?.group(0) ?? '');
      
      late UsualEffect? usualEffect;
      switch (isGreen) {
        case true:
          if(actual! > forecast!) {
            usualEffect = UsualEffect.higherGood;
          } else if(actual < forecast) {
            usualEffect = UsualEffect.higherBad;
          } else {
            usualEffect = null;
          }
          break;
        case false:
          if(actual! < forecast!) {
            usualEffect = UsualEffect.higherGood;
          } else if(actual > forecast) {
            usualEffect = UsualEffect.higherBad;
          } else {
            usualEffect = null;
          }
          break;
        default:
          usualEffect = null;
          break;
      }

      newsItemsList.add(NewsItem(
        id: id,
        title: title,
        impact: impact,
        timeType: timeType,
        date: date,
        currency: currency,
        previous: item.find('', selector: 'td.calendar__previous span')?.innerHtml,
        forecast: item.find('', selector: 'td.calendar__forecast span')?.innerHtml,
        actual: item.find('', selector: 'td.calendar__actual span')?.innerHtml,
        usualEffect: usualEffect,
        //calculate volatility (1-10) based on impact and how much bigger/smaller actual is from forecast
      ));
    }

    return newsItemsList;

  }

}

class NewsItem {
  final int id;
  final String title;
  final Impact? impact;
  final TimeType timeType;
  final DateTime date;
  final Currency currency;
  final String? previous;
  final String? forecast;
  final String? actual;
  final UsualEffect? usualEffect;

  NewsItem({
    required this.id,
    required this.title,
    required this.impact,
    required this.timeType,
    required this.date,
    required this.currency,
    required this.previous,
    required this.forecast,
    required this.actual,
    required this.usualEffect,
  });

  @override
  String toString() {
    return 'NewsItem{id: $id, title: $title, impact: $impact, date: $date, currency: $currency}';
  }

}

enum Currency {
  eur,
  usd,
  gbp,
  jpy,
  cad,
  aud,
}

enum Impact {
  low,
  medium,
  high,
}

enum UsualEffect {
  higherGood,
  higherBad,
}

enum TimeType {
  time,
  tentative,
  allDay,
  unknown
}