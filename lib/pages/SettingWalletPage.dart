import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:untitled1/constants/AppColors.dart';
import 'package:untitled1/widget/CustomAppBar.dart';

import '../../base/base_page.dart';
import '../util/HiveStorage.dart';
import '../hive/Wallet.dart';
import '../main.dart';
import 'BackUpHelperPage.dart';
import '../widget/dialog/UpdateWalletDialog.dart';

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
  bool _showExpandedTitle = false;

  final GlobalKey _headerKey = GlobalKey();
  double _expandedHeight = 500.0.h;
  late Wallet _wallet;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_handleScroll);
    _wallet = Get.arguments;
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 可折叠的 AppBar
          SliverAppBar(
            expandedHeight: 240.h, // 展开时的高度
            floating: false,
            pinned: true, // 固定在顶部
            leadingWidth: 80,
            automaticallyImplyLeading: false, // 禁用默认返回按钮
            leading: _buildIOSBackButton(),
            flexibleSpace: _showExpandedTitle
                ? FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.only(right: 40, left: 40, top: 10), // 补偿右侧按钮宽度
                    title: Container(
                      alignment: Alignment.center,
                      child: Text(
                        _wallet.name,
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  )
                : _buildHeaderContent(),
          ),

          // 列表内容
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: [
                  _buildListItem(
                    icon: '',
                    mainTitle: "修改钱包名称",
                    subTitle: _wallet.name,
                    isVerify: false,
                    onTap: () {
                      showUpdateWalletDialog();
                    },
                  ),
                  _buildListItem(icon: '', mainTitle: "更换头像", subTitle: "", isVerify: false, onTap: () {}),
                  _buildListItem(icon: '', mainTitle: "更换头像", subTitle: "", isVerify: false, onTap: () {}),
                  _buildListItem(icon: '', mainTitle: "查看私钥", subTitle: "", isVerify: false, onTap: () {}),
                  _buildListItem(
                    icon: 'assets/images/ic_wallet_reminder.png',
                    mainTitle: "备份助记词",
                    subTitle: "去备份",
                    isVerify: true,
                    onTap: () {
                      Get.to(BackUpHelperPage());
                    },
                  ),
                  Divider(height: 0.5, color: AppColors.color_E8E8E8),
                  _buildListItem(icon: '', mainTitle: "谷歌验证", subTitle: "未绑定", isVerify: false, onTap: () {}),
                  _buildListItem(icon: '', mainTitle: "授权检测", subTitle: "", isVerify: false, onTap: () {}),
                  _buildListItem(icon: '', mainTitle: "节点设置", subTitle: "", isVerify: false, onTap: () {}),
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
                      child: Text('删除钱包', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new, // iOS样式箭头
        size: 20,
        color: Colors.black,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildHeaderContent() {
    return Container(
      margin: EdgeInsets.only(top: 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset('assets/images/ic_clip_photo.png', width: 60.w, height: 60.w, fit: BoxFit.cover),
          ),
          SizedBox(height: 8.h),
          Text(
            _wallet.name,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: deed...27dc',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.color_757F7F),
                ),
                SizedBox(width: 8.w),
                Image.asset('assets/images/ic_wallet_copy.png', width: 13.w, height: 13.w),
              ],
            ),
          ),
          SizedBox(width: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '安全等级',
                style: TextStyle(fontSize: 12.sp, color: AppColors.color_A5B1B1),
              ),
              SizedBox(width: 2.w),
              Image.asset('assets/images/ic_wallet_safety_error.png', width: 14.w, height: 14.w),
              SizedBox(width: 2.w),
              Text(
                '低',
                style: TextStyle(fontSize: 12.sp, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String icon,
    required String mainTitle,
    required String subTitle,
    required bool isVerify,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.grey.withOpacity(0.1), // 点击效果
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // 主副标题
            Expanded(
              child: Text(mainTitle, style: TextStyle(fontSize: 16.sp)),
            ),
            if (isVerify) Image.asset('assets/images/ic_wallet_reminder.png', width: 19.w, height: 19.w),
            SizedBox(width: 5.w),
            if (subTitle.isNotEmpty)
              Text(
                subTitle,
                style: TextStyle(fontSize: 15.sp, color: isVerify ? Colors.black : AppColors.color_757F7F),
              ),
            SizedBox(width: 13.w),
            // 右侧箭头
            Icon(Icons.arrow_forward_ios, size: 12.w, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void showUpdateWalletDialog() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => UpdateWalletDialog());
  }

  Future<void> deleteWallet() async {
    showLoadingDialog();
    // 1. 获取当前选中的地址和钱包列表
    String? selectedAddress = await HiveStorage().getValue('selected_address');
    List<Wallet> wallets = await HiveStorage().getList<Wallet>('wallets_data') ?? [];
    //判断是否是当前选中的钱包
    if (selectedAddress == _wallet.address) {
      // 如果地址相同，移除匹配的钱包对象
      wallets.removeWhere((wallet) => wallet.address == _wallet.address);

      // 更新selected_address为移除后的第一个钱包地址（如果列表不为空）
      if (wallets.isNotEmpty) {
        selectedAddress = wallets.first.address;
        await HiveStorage().putValue('selected_address', selectedAddress);
        await HiveStorage().putObject('currentSelectWallet', wallets.first);
        Get.offAll(() => MainPage(initialPageIndex: 4));
      } else {
        // 如果钱包列表为空，清空selected_address
        await HiveStorage().putValue('selected_address', '');
        dismissLoading();
        //TODO: 跳转到创建钱包页面
      }
    } else {
      // 如果地址不相同，直接移除匹配的钱包对象
      wallets.removeWhere((wallet) => wallet.address == _wallet.address);
      dismissLoading();
      Get.offAll(() => MainPage(initialPageIndex: 4));
    }

    // 4. 更新钱包列表到Hive
    await HiveStorage().putList('wallets_data', wallets);
  }

  @override
  bool get wantKeepAlive => true;
}
