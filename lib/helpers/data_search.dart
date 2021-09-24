import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../models/tuple.dart';

class DataSearch extends SearchDelegate<String> {
  final List<Tuple<String,String,String>> products;
  final List<Tuple<String,String,String>> recentProducts = [];
  DataSearch(this.products){
    for(int i=0;i<4;i++)
      recentProducts.add(Tuple(products[i].id, products[i].title, products[i].imageUrl));
  }

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

  @override
  String get searchFieldLabel => 'Search Hyper Store';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Colors.yellow,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionHandleColor: Colors.black,
        selectionColor: Colors.orange,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Colors.black), 
        onPressed: (){
          query = "";
          showSuggestions(context);
        }
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
        color: Colors.black,
      ), 
      onPressed: (){
        Navigator.of(context).pop();
      }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty ? recentProducts 
      : products.where((prod) => prod.title.toLowerCase().contains(query.toLowerCase())).toList();

    if(suggestionList.length == 0)
      return Center(
        child: Text('No items match your search'),
      );

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: (){
          Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: suggestionList[index].id,
          );
        },
        leading: CircleAvatar(
            backgroundColor: Colors.orange,
            backgroundImage: CachedNetworkImageProvider(suggestionList[index].imageUrl),
          ),
        title: Text(suggestionList[index].title, style: TextStyle(color: Colors.orange),),
        trailing: query.isEmpty ? 
          Text(
            'trending',
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic
            ),
          ) : null,
      ),
    );
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
        leading: CircleAvatar(
            backgroundColor: Colors.orange,
            backgroundImage: CachedNetworkImageProvider(suggestionList[index].imageUrl),
          ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.orange),
            children: highlightOccurrences(suggestionList[index].title, query),
          ),
        ),
        trailing: query.isEmpty ? 
          Text(
            'trending',
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic
            ),
          ) : null,
      ),
    );
  }
  
}