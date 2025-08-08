import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/theme/pallet.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;

  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfieImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref
        .read(communityControlerProvider.notifier)
        .editCommunity(
          community: community,
          bannerFile: bannerFile,
          profileFile: profileFile,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControlerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data:
              (community) => Scaffold(
                backgroundColor: currentTheme.scaffoldBackgroundColor,
                appBar: AppBar(
                  title: const Text('edit community'),
                  centerTitle: false,
                  actions: [
                    TextButton(
                      onPressed: () => save(community),
                      child: const Text('save'),
                    ),
                  ],
                ),
                body:
                    isLoading
                        ? const Loader()
                        : Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: selectBannerImage,
                                    child: DottedBorder(
                                      child: Container(
                                        width: double.infinity,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child:
                                            bannerFile != null
                                                ? Image.file(bannerFile!)
                                                : community.banner.isEmpty ||
                                                    community.banner ==
                                                        Constants.bannerDefault
                                                ? const Center(
                                                  child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40,
                                                  ),
                                                )
                                                : Image.network(
                                                  community.banner,
                                                ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    child: GestureDetector(
                                      onTap: selectProfieImage,
                                      child:
                                          profileFile != null
                                              ? CircleAvatar(
                                                backgroundImage: FileImage(
                                                  profileFile!,
                                                ),
                                              )
                                              : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  community.avatar,
                                                ),
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
              ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
