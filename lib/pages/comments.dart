import 'package:flutter/material.dart';
import 'package:social_share/widgets/header.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postOwnerId, this.postMediaUrl});

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postMediaUrl: this.postMediaUrl,
        postOwnerId: this.postOwnerId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commetController = TextEditingController();

  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});

  buildComment() {
    return Text("comments");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Comments",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComment(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: commetController,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Write a comment ....",
              ),
            ),
            trailing: OutlineButton(
              borderSide: BorderSide.none,
              child: Icon(
                Icons.send,
                color: Colors.blue,
              ),
              onPressed: () => print("Post a commnt"),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
