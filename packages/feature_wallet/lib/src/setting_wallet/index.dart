import 'dart:io';

import 'package:feature_wallet/add_wallet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_ui/widget/base_page.dart';
import 'package:shared_utils/app_routes.dart';
import 'package:shared_utils/hive_storage.dart';
import 'package:shared_utils/constants/app_colors.dart';
import 'package:shared_utils/constants/app_value_notifier.dart';
import 'package:shared_utils/hive_boxes.dart';
import 'package:feature_wallet/i18n/strings.g.dart';
import 'package:path/path.dart' as p;
import 'package:feature_wallet/src/setting_wallet/fragments/setting_wallet_build_back_button_fragments.dart';
import 'package:feature_wallet/src/setting_wallet/fragments/setting_wallet_header_content_fragments.dart';
import 'package:feature_wallet/src/setting_wallet/common/setting_wallet_list_item.dart';
import 'package:feature_wallet/src/setting_wallet/screen/view_private_key_screen.dart';
import 'package:feature_wallet/hive/Wallet.dart';
import 'package:shared_utils/wallet_nav.dart';
import 'package:shared_utils/wallet_snack.dart';
import 'fragments/setting_wallet_update_wallet_dialog_fragments.dart';

/*
 * 设置钱包
 */
class SettingWalletPage extends StatefulWidget {
  const SettingWalletPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingWalletPageState();
}

class _SettingWalletPageState extends State<SettingWalletPage> with BasePage<SettingWalletPage>, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker picker = ImagePicker();
  bool _showExpandedTitle = false;
  bool _inited = false;

  final GlobalKey _headerKey = GlobalKey();
  double _expandedHeight = 500.0.h;
  late Wallet _wallet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    _scrollController.addListener(_handleScroll);
    _wallet = ModalRoute.of(context)?.settings.arguments ?? Get.arguments;
  }

  void _handleScroll() {
    final double offset = _scrollController.offset;
    final bool isOverThreshold = offset > 100; // 调整这个阈值

    if (isOverThreshold != _showExpandedTitle) {
      setState(() {
        _showExpandedTitle = isOverThreshold;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          _expandedHeight = renderBox.size.height;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 可折叠的 AppBar
            SliverAppBar(
              expandedHeight: 240.h, // 展开时的高度
              floating: false,
              pinned: true, // 固定在顶部
              leadingWidth: 80,
              automaticallyImplyLeading: false, // 禁用默认返回按钮
              leading: SettingWalletBuildBackButtonFragments(),
              flexibleSpace: _showExpandedTitle
                  ? FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: EdgeInsets.only(right: 40, left: 40, top: 10),
                      title: Container(
                        alignment: Alignment.center,
                        child: Text(
                          _wallet.name,
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    )
                  : SettingWalletHeaderContentFragments(wallet: _wallet),
            ),

            // 列表内容
            SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  children: [
                    SettingWalletListItem(
                      icon: '',
                      mainTitle: t.wallet.edit_wallet_name,
                      subTitle: _wallet.name,
                      isVerify: false,
                      onTap: () => showUpdateWalletDialog(_wallet),
                    ),
                    SettingWalletListItem(
                      icon: '',
                      mainTitle: t.wallet.change_avatar,
                      subTitle: "",
                      isVerify: false,
                      onTap: () => _albumPermissions(),
                    ),
                    SettingWalletListItem(
                      icon: '',
                      mainTitle: t.wallet.view_private_key,
                      subTitle: "",
                      isVerify: false,
                      onTap: () {
                        WalletNav.to(
                          ViewPrivateKeyScreen(
                            title: t.wallet.view_private_key,
                            privateKey: _wallet.privateKey,
                            hideContent: t.wallet.hidePrivateKey,
                          ),
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                    ),
                    if (_wallet.isBackUp)
                      SettingWalletListItem(
                        icon: '',
                        mainTitle: t.wallet.viewMnemonic,
                        subTitle: "",
                        isVerify: false,
                        onTap: () {
                          WalletNav.to(
                            ViewPrivateKeyScreen(
                              title: t.wallet.viewMnemonic,
                              privateKey: _wallet.mnemonic!.join(' '),
                              hideContent: t.wallet.hide_mnemonic,
                            ),
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      ),
                    Divider(height: 0.5, color: AppColors.color_E8E8E8),
                    SettingWalletListItem(
                      icon: '',
                      mainTitle: t.wallet.google_verification,
                      subTitle: t.wallet.not_bound,
                      isVerify: false,
                      onTap: () {},
                    ),
                    SettingWalletListItem(icon: '', mainTitle: t.wallet.authorization_check, subTitle: "", isVerify: false, onTap: () {}),
                    SettingWalletListItem(icon: '', mainTitle: t.wallet.node_settings, subTitle: "", isVerify: false, onTap: () {}),
                    Padding(
                      padding: EdgeInsets.all(15.w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.color_F3607B,
                          minimumSize: Size(double.infinity, 48.h),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          textStyle: TextStyle(fontSize: 18.sp),
                          side: BorderSide(color: AppColors.color_F3607B, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.5)),
                        ),
                        onPressed: () {
                          deleteWallet();
                        },
                        child: Text(t.wallet.delete_wallet, style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showUpdateWalletDialog(Wallet wallet) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SettingWalletUpdateWalletDialogFragments(wallet: wallet),
    );
    if (result != null) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _albumPermissions() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024, imageQuality: 92);
    if (image == null) return;

    // 私有持久目录
    final baseDir = await getApplicationSupportDirectory();
    final avatarDir = Directory(p.join(baseDir.path, 'avatars'));
    if (!avatarDir.existsSync()) avatarDir.createSync(recursive: true);

    // 生成文件名并复制
    final ext = p.extension(image.path).toLowerCase();
    final fileName = 'avatar_${_wallet.key}_${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.jpg' : ext}';
    final savedPath = p.join(avatarDir.path, fileName);
    await File(image.path).copy(savedPath);

    // 删除旧头像
    final old = _wallet.avatarImagePath;
    if (old != null && old.isNotEmpty) {
      final f = File(old);
      if (await f.exists()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }

    final wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? <Wallet>[];
    if (wallets.isEmpty) return;

    int idx = wallets.indexWhere((e) => e.address.toLowerCase() == _wallet.address.toLowerCase());
    if (idx == -1) return;

    wallets[idx].avatarImagePath = savedPath;
    await HiveStorage().putList<Wallet>('wallets_data', wallets, boxName: boxWallet);

    final selectedAddr = (await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '').trim().toLowerCase();

    if (selectedAddr == wallets[idx].address.toLowerCase()) {
      final current = await HiveStorage().getObject<Wallet>('currentSelectWallet', boxName: boxWallet);
      if (current != null && current.address.toLowerCase() == wallets[idx].address.toLowerCase()) {
        current.avatarImagePath = savedPath;
        await HiveStorage().putObject<Wallet>('currentSelectWallet', current, boxName: boxWallet);
      }
    }

    if (mounted) {
      setState(() {
        _wallet.avatarImagePath = savedPath;
      });
    }

    Navigator.of(context).pop();
    debugPrint('avatar saved: $savedPath');
  }

  Future<void> deleteWallet() async {
    showLoadingDialog();
    try {
      // 取当前选中地址 & 列表
      final String selectedAddress = await HiveStorage().getValue<String>('selected_address', boxName: boxWallet) ?? '';
      final List<Wallet> wallets = await HiveStorage().getList<Wallet>('wallets_data', boxName: boxWallet) ?? <Wallet>[];

      // 找到要删的钱包下标 不区分大小写
      final int idx = wallets.indexWhere((w) => (w.address).toLowerCase() == (_wallet.address).toLowerCase());

      if (idx == -1) {
        dismissLoading();
        WalletSnack.show('提示', '未找到要删除的钱包');
        return;
      }

      // 先保存目标项信息, 再删除, 避免越界/错位
      final Wallet target = wallets[idx];
      final String targetAddress = target.address;
      final String? targetAvatarPath = target.avatarImagePath;

      // 删除目标钱包, 使用下标删除，避免大小写不一致导致 removeWhere 失败
      wallets.removeAt(idx);

      // 头像清理: 仅当没有其他钱包引用同一路径时才删除
      if (targetAvatarPath != null && targetAvatarPath.isNotEmpty) {
        final bool stillUsed = wallets.any((w) => (w.avatarImagePath ?? '') == targetAvatarPath);
        if (!stillUsed) {
          try {
            final f = File(targetAvatarPath);
            if (await f.exists()) {
              await f.delete();
            }
          } catch (_) {}
        }
      }

      // 计算新的选中地址, 删除的是当前选中时，把第一个设为选中: 否则保持不变
      if (wallets.isNotEmpty) {
        final bool isDeletingSelected = selectedAddress.isNotEmpty && selectedAddress.toLowerCase() == targetAddress.toLowerCase();
        final String nextSelected = isDeletingSelected ? wallets.first.address : selectedAddress;

        // 写回 Hive
        await HiveStorage().putList<Wallet>('wallets_data', wallets, boxName: boxWallet);
        await HiveStorage().putValue('selected_address', nextSelected, boxName: boxWallet);

        // 同步 currentSelectWallet
        final Wallet nextWallet = wallets.firstWhere((w) => w.address.toLowerCase() == nextSelected.toLowerCase(), orElse: () => wallets.first);
        await HiveStorage().putObject<Wallet>('currentSelectWallet', nextWallet, boxName: boxWallet);

        dismissLoading();
        OneShotFlag.value.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WalletNav.offAllNamed(AppRoutes.main, arguments: {'initialPageIndex': 4});
        });
      } else {
        await HiveStorage().putList<Wallet>('wallets_data', <Wallet>[], boxName: boxWallet);
        await HiveStorage().putValue('selected_address', '', boxName: boxWallet);
        await HiveStorage().delete('currentSelectWallet', boxName: boxWallet);

        dismissLoading();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WalletNav.offAll(AddWalletPage());
        });
      }
    } catch (e) {
      dismissLoading();
      WalletSnack.show('错误', '删除失败：$e');
    }
  }

  @override
  bool get wantKeepAlive => true;
}
