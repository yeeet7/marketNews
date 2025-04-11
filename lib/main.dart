
import 'package:flutter/material.dart';
import 'package:market_news/services/news_api.dart';
import 'package:market_news/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market News',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blue
      ),
      home: Scaffold(

        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56 + 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TodayDateChip()
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
              return const CircularProgressIndicator();
            }
            if(snapshot.hasError) {
              return SingleChildScrollView(child: Text('Error: ${snapshot.error}\n${snapshot.stackTrace}'));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  ...snapshot.data!.map((e) => NewsItemListTile(impact: e.impact, title: e.title, timeType: e.timeType, date: e.date, currency: e.currency)),                ]
              ),
            );
          }
        ),
      
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