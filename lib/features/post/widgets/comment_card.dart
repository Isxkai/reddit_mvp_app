import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/models/comment_model.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(comment.profilepic),
                radius: 18,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'u/${comment.username}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('u/${comment.text}'),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.reply_sharp)),
              const Text('reply'),
            ],
          ),
        ],
      ),
    );
  }
}
