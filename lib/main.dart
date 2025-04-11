
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
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.grey.shade700
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey.shade900,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.shade800,
          selectedIconTheme: const IconThemeData(color: Colors.blue),
          unselectedIconTheme: IconThemeData(color: Colors.grey.shade800),
        ),
      ),
      home: Scaffold(
        
        body: const App(),
        
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart_sharp), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),

      )
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56 + 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button('${DateTime.now().day} ${monthToString(DateTime.now().month)}', filled: false),
                  Button(
                    'Filters',
                    icon: Icons.tune,
                    filled: false,
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Filters(onCancel: () => Navigator.pop(context), onApply: (pastEvents, impacts, currencies) {print(pastEvents);})
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        )
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
            child: Column(
              children: [
                ...snapshot.data!.map((e) => NewsItemListTile(impact: e.impact, title: e.title, timeType: e.timeType, date: e.date, currency: e.currency)),
                // Container(
                //   width: MediaQuery.of(context).size.width - 32,
                //   height: MediaQuery.of(context).size.width - 32,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(55 - 32),
                //     border: Border.all(color: Colors.grey.shade800, width: 1.5)
                //   ),
                //   child: const Filters()
                // )
              ]
            ),
          );
        }
      ),
    
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