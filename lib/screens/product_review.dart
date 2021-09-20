import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductReview extends StatefulWidget {
  final String prodId, prodTitle;

  ProductReview(this.prodId, this.prodTitle);

  @override
  _ProductReviewState createState() => _ProductReviewState();
}

class _ProductReviewState extends State<ProductReview> {
  double rating = 1;
  String ratingText = 'Loved it', title = 'Loved it', description = '';
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hyper Store'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  widget.prodTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  glowColor: Colors.grey,
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber), 
                  updateOnDrag: true,
                  onRatingUpdate: (rating) {
                    setState(() {
                      this.rating = rating;
                      if(rating == 1)
                        ratingText = 'Hated it';
                      else if(rating == 2)
                        ratingText = 'Disliked it';
                      else if(rating == 3)
                        ratingText = 'It\'s OK';
                      else if(rating == 4)
                        ratingText = 'Liked it';
                      else if(rating == 5)
                        ratingText = 'Loved it';
                    });
                  }
                ),

                const SizedBox(height: 10),

                Text(
                  ratingText + '!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue
                  ),
                ),

                const SizedBox(height: 5),

                Stack(
                  children: [
                    Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height*0.27,
                          margin: EdgeInsets.fromLTRB(mq.width*0.05, mq.height*0.032, mq.width*0.05, mq.height*0.015),
                          padding: EdgeInsets.only(bottom: mq.height*0.014),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 0, 0, 0), width: 2),
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,
                          ),
                          child: Form(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(mq.width*0.07, mq.height*0.02, mq.width*0.07, 0),
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 14.0),
                                    decoration: InputDecoration(
                                      labelText: "Title",
                                    ),
                                    onChanged: (value){
                                      title = value;
                                    }
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(mq.width*0.07, 0, mq.width*0.07, 15),
                                  child: TextFormField(
                                    inputFormatters: [LengthLimitingTextInputFormatter(12)],
                                    maxLines: 2,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      labelText: "Description",
                                    ),
                                    onChanged: (value){
                                      description = value;
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    Positioned(
                      left: MediaQuery.of(context).size.width*0.1,
                      top: MediaQuery.of(context).size.height*0.015,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Text(
                          'Your Review',
                          style: TextStyle(color: Colors.black, fontSize: 24),
                        ),
                      )
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Material(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15),
                                  child: InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      print(title);
                                      print(description);
                                    },
                                    child: Container(
                                      width: 160,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Add Rating",
                                        style: TextStyle(
                                          color: Colors.yellow, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}