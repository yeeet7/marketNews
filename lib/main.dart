
import 'package:flutter/material.dart';
import 'package:market_news/services/news_api.dart';
import 'package:market_news/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market News',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color(0xFF4A4A4A),
          secondary: const Color(0xFF0E0E0E),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF141414),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Color(0xFF4A4A4A),
          selectedIconTheme: IconThemeData(color: Colors.blue),
          unselectedIconTheme: IconThemeData(color: Color(0xFF4A4A4A)),
        ),
      ),
      home: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        actions: [
          Button(
            'Filters',
            icon: Icons.tune,
            filled: false,
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Filters(onCancel: () => Navigator.pop(context), onApply: (pastEvents, impacts, currencies) => Navigator.pop(context))
              );
            },
          ),
        ],

        bottom: const AppBarBottom(),

      ),
    
      body: FutureBuilder(
        // future: Future(() => [NewsItem(id: 1, title: 'Test', impact: Impact.high, timeType: TimeType.time, date: DateTime.now(), currency: Currency.eur)]),
        future: NewsApi.today(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if(snapshot.hasError) {
            return SingleChildScrollView(child: Text('Error: ${snapshot.error}\n${snapshot.stackTrace}'));
          }
          return SingleChildScrollView(
            child: Calendar([
              for (var e in snapshot.data!)
                MapEntry(e.date, e)
            ]),
          );
        }
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart_sharp), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day_rounded), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    
    );
  }
}

class Calendar extends StatelessWidget {
  const Calendar(
    this.events, {
    super.key,
  });

  final List<MapEntry<DateTime, NewsItem>> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DateText(DateTime.now(), true),
        ...List.generate(24, (index) => Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border(
              // bottom: BorderSide(color: Colors.grey, width: .5),
              top: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
            )
          ),
          child: Row (
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: textToSize('24:00', TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)).width + 16*2,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
                  )
                ),
                child: Center(child: Text('$index:00', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12))),
              ),
              ...events.where((event) => event.key.hour == index).map((event) => NewsItemListTile(impact: event.value.impact, title: event.value.title, timeType: event.value.timeType, date: event.value.date, currency: event.value.currency)),
            ],
          )
        )),
        Container(height: .5, width: MediaQuery.of(context).size.width, color: Theme.of(context).colorScheme.primary),
      ]
    );
  }
}

String monthToString(int month) {
  switch(month) {
    case 1: return 'Jan';
    case 2: return 'Feb';
    case 3: return 'Mar';
    case 4: return 'Apr';
    case 5: return 'May';
    case 6: return 'Jun';
    case 7: return 'Jul';
    case 8: return 'Aug';
    case 9: return 'Sep';
    case 10: return 'Oct';
    case 11: return 'Nov';
    case 12: return 'Dec';
    default: return '';
  }
}

String dayToString(int day) {
  switch(day) {
    case 1: return 'Monday';
    case 2: return 'Tuesday';
    case 3: return 'Wednesday';
    case 4: return 'Thursday';
    case 5: return 'Friday';
    case 6: return 'Saturday';
    case 7: return 'Sunday';
    default: return '';
  }
}