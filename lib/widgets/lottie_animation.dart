import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';




class EmptyState extends StatelessWidget {
  final String file;
  final String label;
  const EmptyState({super.key, required this.file, required this.label,});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animation
          Lottie.asset(
            file,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}





























/* 
import 'dart:io';
import 'package:chirp/widgets/post_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:image_picker/image_picker.dart';
import 'package:chirp/models/post/post_model.dart';

import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

import '../../widgets/lottie_animation.dart';


class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _customTagController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = <XFile>[]; // multiple image support
  

  // Example categories/hashtags (multi-select)
  final List<String> _allCategories = <String>[
    "General",
    'Productivity',
    'Motivation',
    'Lifestyle',
    'Tech',
    'Education',
    'Health',
    "Fun",
  ];
  final Set<String> _selectedCategories = <String>{};

  bool _isPosting = false;

  static const int _captionMax = 280; // like Twitter

  bool get _hasContent =>
      _captionController.text.trim().isNotEmpty || _images.isNotEmpty;

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }




  Future<bool> _handlePost() async {

    final post = context.read<PostProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return false;
    }

    if (!_hasContent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption or at least one image')),
      );
      return false;
    }

    if (mounted) setState(() => _isPosting = true);




    final newPost = PostModel(
      id: '', // Firestore will assign one
      userId: currentUser.id,
      text: _captionController.text.trim(),
      mediaUrls: _images.map((x) => x.path).toList(),
      categories: _selectedCategories.toList(),
      createdAt: DateTime.now(),
    );

    // 🔥 Replace with your backend/Firestore upload logic
    // Example payload you might send:
    final payload = {
      'caption': _captionController.text.trim(),
      'categories': _selectedCategories.toList(),
      'images': _images.map((x) => x.path).toList(), // upload the files
      'createdAt': DateTime.now().toIso8601String(),
    };
    debugPrint('POST PAYLOAD => $payload');




    bool showPreview = false;
    bool showPostStatus = false;
    bool postSuccess = false;
    bool posting = false;

    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (!showPreview && !showPostStatus) {
              if (!posting){
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setModalState(() => showPreview = true);
                });
              }
              return SizedBox(
                width: double.infinity,
                height: 200,
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (showPostStatus) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: postSuccess
                      ? EmptyState(
                          file: 'assets/success.json',
                          label: 'Posted successfully!',
                        )
                      : EmptyState(
                          file: 'assets/error.json',
                          label: 'Error: something went wrong!',
                        ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Preview Post',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    PostCard(post: newPost, isPreview: true),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Keep Editing'),
                        ),
                        TextButton(
                          onPressed: () async {

                            setModalState(() {
                              showPreview = false;
                              posting = true;
                            });


                            
                            try {
                              await post.addPost(newPost).timeout(
                                const Duration(minutes: 5),
                                onTimeout: () => throw Exception('Something went wrong!'),
                              );
                            
                              postSuccess = true;
                              setModalState(() {
                                posting = false;
                                showPostStatus = true;
                              });
                              await Future.delayed(const Duration(seconds: 5));
                              
                              // reset state if staying on page
                              _captionController.clear();
                              _images.clear();
                              _selectedCategories.clear();
                              _customTagController.clear();
                              Navigator.pop(ctx, postSuccess);
                            
                            } catch (_) {
                              postSuccess = false;
                              setModalState(() {
                                posting = false;
                                showPostStatus = true;
                              });
                              await Future.delayed(const Duration(seconds: 5));
                              Navigator.pop(ctx, false);
                            }
                          },
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );

    if (mounted) {
      setState(() {
        _isPosting = false;
      });
    }

    return result ?? false;
  }





  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_hasContent) return true;

    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Discard post?', textAlign: TextAlign.center,),
        content: const Text(
          "You have unsaved changes. Do you want to discard this post?",
          maxLines: 5,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard', style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // final viewInsets = MediaQuery.of(context).viewInsets;
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;


    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // keep transparent, content goes behind
          statusBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      );
    });


    return SafeArea(
      child: WillPopScope(
        onWillPop: _confirmDiscardIfNeeded,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          extendBody: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 5,
            leadingWidth: 40,
            leading: IconButton(
              icon: Icon(Icons.close, color: theme.textTheme.bodyLarge?.color),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () async {
          final ok = await _confirmDiscardIfNeeded();
          if (ok && mounted) Navigator.pop(context);
              },
            ),
            titleSpacing: 0,
            title: Row(
              children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(currentUser != null ? currentUser.avatarUrl! : 'https://i.pravatar.cc/150?img=5'),
          ),
          SizedBox(width: 8),
          Text(
            'Create Post',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: theme.textTheme.bodyLarge?.fontWeight,
            ),
          ),
              ],
            ),
            actions: [
              Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
            onPressed: _isPosting || !_hasContent ? null : _handlePost,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.primaryColor,
              disabledBackgroundColor: theme.primaryColor.withOpacity(0.4),
              foregroundColor: theme.textTheme.bodyLarge?.color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isPosting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Preview'),
          ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // fixed bottom padding (space for toolbar)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caption field with counter
              TextField(
                controller: _captionController,
                maxLines: null,
                maxLength: _captionMax,
                decoration: InputDecoration(
            counterText: '', // add counter UI below
            hintText: "What's on your mind?",
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
            '${_captionController.text.characters.length}/$_captionMax',
            style: TextStyle(
              fontSize: 12,
              color: _captionController.text.characters.length >= _captionMax
                  ? Colors.red
                  : theme.textTheme.bodySmall?.color,
            ),
                ),
              ),

              const SizedBox(height: 12),

              // Images grid (with remove buttons)
              if (_images.isNotEmpty)
                GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final img = _images[index];
              return Stack(
                children: [
                  ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: kIsWeb
                  ? Image.network(
                img.path,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                    )
                  : Image.file(
                File(img.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                    ),
                  ),
                  Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => setState(() => _images.removeAt(index)),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
                  ),
                ],
              );
            },

                    const SizedBox(height: 16),

                    // Category selection (multi-select chips) + custom tag
                    Text(
                      'Select Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: -15,
                      children: [
                        ..._allCategories.map((category) {
                          final selected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                            selectedColor: theme.primaryColor.withOpacity(.5),
                            checkmarkColor: theme.textTheme.bodyLarge?.color,
                            backgroundColor: theme.scaffoldBackgroundColor,
                            labelStyle: TextStyle(
                              color: selected
                                  ? theme.textTheme.bodyLarge?.color
                                  : theme.textTheme.bodyLarge?.color,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            side: BorderSide(color: selected ? Colors.transparent : theme.textTheme.bodyMedium?.color ?? Colors.grey),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customTagController,
                            decoration: InputDecoration(
                              hintText: 'Add custom tag (e.g. #NoZeroDays)',
                              hintStyle: TextStyle(
                                color: theme.textTheme.bodyMedium?.color
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  color: theme.textTheme.bodyMedium?.color ?? Colors.grey
                                )

                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addCustomTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addCustomTag,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(theme.scaffoldBackgroundColor),
                            elevation: MaterialStateProperty.all(5),
                            // elevation: MaterialStateProperty.all(Colors.transparent),
                          ),
                          child: Text('Add', style: TextStyle(color: theme.primaryColor),),
                        ),
                      ],
                    ),

                    // const SizedBox(height: 90), // spacing before bottomSheet
                    const SizedBox(height: 10), // spacing before bottomSheet
                  ],
                ),
              ),
            ],
          ),

          // Bottom toolbar that stays above the keyboard using bottomSheet
          bottomSheet:  AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 6,
              bottom: MediaQuery.of(context).viewInsets.bottom, // push above keyboard
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.grey.shade500)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton( 
                  tooltip: 'Add photos',
                  icon: Icon(Icons.photo_library_outlined, color: theme.textTheme.bodyLarge?.color,),
                  onPressed: _pickImages,
                ),
                IconButton(
                  tooltip: 'Add emoji',
                  icon: Icon(Icons.emoji_emotions_outlined, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () async {
                    // Show emoji picker bottom sheet
                    final emoji = await showModalBottomSheet<String>(
                      context: context,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) {
                        // Simple emoji grid, you can use a package like emoji_picker_flutter for more features
                        final emojis = [
                          '😀','😂','😍','🥳','😎','🤔','😢','👍','🙏','🔥','🎉','💯','🥰','😇','😜','🤩','😡','😱','🤗','😴'
                        ];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: emojis.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => Navigator.pop(ctx, emojis[index]),
                                child: Center(
                                  child: Text(
                                  emojis[index],
                                  style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                    if (emoji != null && emoji.isNotEmpty) {
                      // Insert emoji at cursor position in caption
                      final text = _captionController.text;
                      final selection = _captionController.selection;
                      final newText = selection.isValid
                        ? text.replaceRange(selection.start, selection.end, emoji)
                        : text + emoji;
                      _captionController.text = newText;
                      _captionController.selection = TextSelection.collapsed(
                      offset: selection.isValid
                        ? selection.start + emoji.length
                        : _captionController.text.length,
                      );
                      setState(() {});
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Add location',
                  icon: Icon(Icons.location_on_outlined, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () async {
                    
                    // Simple location picker using geolocator
                    // Add geolocator: ^10.0.0 to pubspec.yaml
                    // import 'package:geolocator/geolocator.dart';
                    try {
                      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location services are disabled.')),
                        );
                        return;
                      }
                      LocationPermission permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location permission denied.')),
                          );
                          return;
                        }
                      }
                      if (permission == LocationPermission.deniedForever) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permissions are permanently denied.')),
                        );
                        return;
                      }
                      final position = await Geolocator.getCurrentPosition();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Location added: (${position.latitude}, ${position.longitude})')),
                      );
                      // You can store the location in your post model as needed
                      // Example: setState(() => _postLocation = position);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to get location: $e')),
                      );
                    }
                  },
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isPosting || !_hasContent ? null : _handlePost,
                  icon: const Icon(Icons.send),
                  label: const Text('Preview'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;
    setState(() {
      // Normalize to look like a hashtag
      final normalized = tag.startsWith('#') ? tag : '#$tag';
      _allCategories.add(normalized);
      _selectedCategories.add(normalized);
      _customTagController.clear();
    });
  }
}

/*
📦 pubspec.yaml dependencies needed:

  image_picker: ^1.0.7  // or latest

📌 Android setup: No extra steps for basic usage.
📌 iOS setup: Add usage description in ios/Runner/Info.plist
  <key>NSPhotoLibraryUsageDescription</key>
  <string> I need photo library access to let you attach photos.</string>

Notes:
- Replace _handlePost() body with backend upload logic.
- uploading images, read file with File(x.path) and send to storage (e.g., Firebase Storage), then store URLs with caption/categories.
- in case of needed camera capture: await _picker.pickImage(source: ImageSource.camera);
*/
*/