import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    ref
        .read(communityControlerProvider.notifier)
        .createCommunity(
          communityNameController.text.trim(),
          context,
        ); // Logic to create community will go here
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControlerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body:
          isLoading
              ? const Loader()
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Community name '),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: communityNameController, // Add this line
                      decoration: const InputDecoration(
                        // Add const
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        filled: true,
                        border: OutlineInputBorder(),
                        hintText: 'Enter community name',
                      ),
                      maxLength: 21,
                    ),
                    const SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: createCommunity,
                      child: const Text('Create Community'),
                    ),
                  ],
                ),
              ),
    );
  }
}
