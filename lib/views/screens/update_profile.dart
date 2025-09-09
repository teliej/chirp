import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
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

        String avatarUrl = user.avatarUrl;
        String backgroundUrl = user.backgroundImageUrl;

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
            followers: user.followers,
            following: user.following,
            interests: user.interests,
            posts: user.posts,
            savedPosts: user.savedPosts,
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
    final user = context.watch<UserProvider>().currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
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
                              : NetworkImage(user.backgroundImageUrl) as ImageProvider,
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
                            : NetworkImage(user.avatarUrl) as ImageProvider,
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
              const SizedBox(height: 50),

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
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? "Email cannot be empty" : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
