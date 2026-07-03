import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/profile_image_service.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    if (data != null && mounted) {
      setState(() => _avatarUrl = data['avatar_url'] as String?);
    }
  }

  void _pickImage(ImageSource source) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final svc = ProfileImageService();
    final file = source == ImageSource.gallery
        ? await svc.pickFromGallery()
        : await svc.pickFromCamera();
    if (file == null) return;
    final url = await svc.upload(userId, file);
    if (url == null || !mounted) return;
    await Supabase.instance.client
        .from('profiles')
        .upsert({'id': userId, 'avatar_url': url});
    setState(() => _avatarUrl = url);
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.t.tr('choose_from_gallery')),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.t.tr('take_a_photo')),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(_avatarUrl!)
              : const AssetImage("assets/images/mahmoud.jpg") as ImageProvider,
        ),
        Positioned(
          bottom: 10,
          right: 0,
          child: InkWell(
            onTap: _showPicker,
            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black,
              ),
              child: Padding(
                padding: EdgeInsets.all(7.0.w),
                child: SvgPicture.asset("assets/icons/cameraIcon.svg"),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
