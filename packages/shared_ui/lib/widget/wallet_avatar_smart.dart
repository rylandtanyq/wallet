// lib/widget/wallet_avatar_smart.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

/// 智能头像：
/// 1) 若 [avatarImagePath] 存在且文件存在 -> 显示本地图片
/// 2) 否则若 [address] 有值 -> 用 random_avatar 基于地址生成随机头像
/// 3) 否则 -> 显示默认占位图 [defaultAsset]
class WalletAvatarSmart extends StatelessWidget {
  final String? address; // 用于生成随机头像的 seed（钱包地址/公钥）
  final String? avatarImagePath; // Hive 里存的本地文件路径
  final double size; // 显示尺寸
  final double radius; // 圆角，= size/2 即圆形
  final String defaultAsset; // 默认占位图资源
  final BoxFit fit;

  const WalletAvatarSmart({
    super.key,
    required this.address,
    required this.avatarImagePath,
    this.size = 48,
    this.radius = 999,
    this.defaultAsset = 'assets/images/default_profile_picture.png',
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    // 1) 本地头像优先
    if (avatarImagePath != null && avatarImagePath!.isNotEmpty && File(avatarImagePath!).existsSync()) {
      child = Image.file(
        File(avatarImagePath!),
        width: size,
        height: size,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => Image.asset(defaultAsset, width: size, height: size, fit: fit),
      );
    }
    // 2) 随机头像（地址为 seed）
    else if (address != null && address!.isNotEmpty) {
      child = SizedBox(width: size, height: size, child: RandomAvatar(address!, trBackground: true));
    }
    // 3) 默认占位
    else {
      child = Image.asset(defaultAsset, width: size, height: size, fit: fit);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}
