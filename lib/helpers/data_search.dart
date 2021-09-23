import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../models/pair.dart';

class DataSearch extends SearchDelegate<String> {
  final List<Pair<String,String>> products;
  DataSearch(this.products);

  List<TextSpan> highlightOccurrences(String source, String query) {
  if (query == null || query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
    return [ TextSpan(text: source) ];
  }
  final matches = query.toLowerCase().allMatches(source.toLowerCase());

  int lastMatchEnd = 0;

  final List<TextSpan> children = [];
  for (var i = 0; i < matches.length; i++) {
    final match = matches.elementAt(i);

    if (match.start != lastMatchEnd) {
      children.add(TextSpan(
        text: source.substring(lastMatchEnd, match.start),
      ));
    }

    children.add(TextSpan(
      text: source.substring(match.start, match.end),
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    ));

    if (i == matches.length - 1 && match.end != source.length) {
      children.add(TextSpan(
        text: source.substring(match.end, source.length),
      ));
    }

    lastMatchEnd = match.end;
  }
  return children;
}

  final List<Pair<String,String>> recentProducts = [
    Pair('1', 'Apple'),
    Pair('2', 'Orange'),
    Pair('3', 'Banana'),
    Pair('4', 'Something'),
  ];

  @override
  String get searchFieldLabel => 'Search Hyper Store';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.yellow,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.black), 
        onPressed: (){
          query = "";
        }
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.black), 
      onPressed: (){
        Navigator.of(context).pop();
      }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ? recentProducts 
      : products.where((prod) => prod.title.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: (){
          Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: suggestionList[index].id,
          );
        },
        leading: Icon(Icons.fireplace),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.orange),
            children: highlightOccurrences(suggestionList[index].title, query),
          ),
        ),
      ),
    );
  }
  
}