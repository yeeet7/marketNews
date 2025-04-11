
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
      darkTheme: ThemeData.dark(),
      home: Scaffold(

        appBar: AppBar(
          leadingWidth: 56 + 16,
          leading: Text('   ${DateTime.now().day} ${monthToString(DateTime.now().month)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          backgroundColor: Colors.grey[900],
        ),
      
        body: Center(
          child: FutureBuilder(
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
                  children: snapshot.data!.map((e) => NewsItemWidget(impact: e.impact, title: e.title, timeType: e.timeType, date: e.date, currency: e.currency)).toList()
                ),
              );
            }
          )
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