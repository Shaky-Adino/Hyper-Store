import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class ConvertImageToFile{

  static Future<File> urlToFile(String imageUrl) async {

    var rng = new Random();

    Directory tempDir = await getTemporaryDirectory();

    String tempPath = tempDir.path;

    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');

    var url = Uri.parse(imageUrl);
    
    http.Response response = await http.get(url);
    
    await file.writeAsBytes(response.bodyBytes);
    
    return file;
  }
  
}