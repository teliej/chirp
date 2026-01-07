import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

import '../../models/user/user_model.dart';
import '../../services/post_service.dart';


class UpdateProfilePage extends StatefulWidget {
    const UpdateProfilePage({super.key});

    @override
    State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
    final _formKey = GlobalKey<FormState>();

    late TextEditingController _nameController;
    late TextEditingController _usernameController;
    late TextEditingController _emailController;
    late TextEditingController _bioController;
    late TextEditingController _bioLinkController;
    late TextEditingController _bioLinkTextController;

    File? _avatarImage;
    File? _backgroundImage;

    @override
    void initState() {
        super.initState();
        final user = context.read<UserProvider>().currentUser!;
        _nameController = TextEditingController(text: user.name);
        _usernameController = TextEditingController(text: user.username);
        _emailController = TextEditingController(text: user.email);
        _bioController = TextEditingController(text: user.bio);
        _bioLinkController = TextEditingController(text: user.bioLink);
        _bioLinkTextController = TextEditingController(text: user.bioLinkText);
    }
    
    Future<void> _pickImage(bool isAvatar) async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
            setState(() {
            if (isAvatar) {
                _avatarImage = File(picked.path);
            } else {
                _backgroundImage = File(picked.path);
            }
            });
        }
    }
    

    Future<void> _saveProfile() async {
        if (!_formKey.currentState!.validate()) return;

        final userProvider = context.read<UserProvider>();
        final user = userProvider.currentUser!;
        final postService = PostService();

        String? avatarUrl = user.avatarUrl;
        String? backgroundUrl = user.backgroundImageUrl;

        // Upload avatar if selected
        if (_avatarImage != null) {
            final urls = await postService.uploadMedia([_avatarImage!.path], user.id);
            avatarUrl = urls.first;
        }

        // Upload background if selected
        if (_backgroundImage != null) {
            final urls = await postService.uploadMedia([_backgroundImage!.path], user.id);
            backgroundUrl = urls.first;
        }

        final updatedUser = UserModel(
            id: user.id,
            username: _usernameController.text.trim(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            avatarUrl: avatarUrl,
            backgroundImageUrl: backgroundUrl,
            bio: _bioController.text.trim(),
            bioLink: _bioLinkController.text.trim(),
            followersCount: user.followersCount,
            followingCount: user.followingCount,
            interests: user.interests,
            postsCount: user.postsCount,
            // savedPosts: user.savedPosts,
            isVerified: user.isVerified,
            role: user.role,
            createdAt: user.createdAt,
            updatedAt: DateTime.now(),
            lastActive: user.lastActive,
            location: user.location,
    );

    await userProvider.updateUser(updatedUser);
    if (mounted) Navigator.pop(context);
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().currentUser!;

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


    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text("Edit Profile", 
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: theme.textTheme.bodyLarge?.color),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Background Image
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: _backgroundImage != null
                              ? FileImage(_backgroundImage!)
                              : NetworkImage(user.backgroundImageUrl!) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : NetworkImage(user.avatarUrl!) as ImageProvider,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 12),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) => v!.isEmpty ? "Username cannot be empty" : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  // suffixIcon: Icon(Icons.lock, size: 16, color: theme.textTheme.bodyMedium?.color)
                  suffixIcon: Icon(Icons.lock, size: 16, color: theme.textTheme.bodyMedium?.color)
                ),
                validator: (v) => v!.isEmpty ? "Email cannot be empty" : null,
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Bio Link
              TextFormField(
                controller: _bioLinkController,
                decoration: const InputDecoration(labelText: "Bio Link"),
              ),
              const SizedBox(height: 24),

              // Bio Link
              TextFormField(
                controller: _bioLinkTextController,
                decoration: const InputDecoration(labelText: "Bio Link Text"),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
