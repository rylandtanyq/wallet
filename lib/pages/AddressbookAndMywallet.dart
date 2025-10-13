import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';

class Addressbookandmywallet extends StatefulWidget {
  const Addressbookandmywallet({super.key});

  @override
  State<Addressbookandmywallet> createState() => _AddressbookandmywalletState();
}

class _AddressbookandmywalletState extends State<Addressbookandmywallet> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Theme(
          data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory, highlightColor: Colors.transparent),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.onBackground,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            labelColor: Theme.of(context).colorScheme.onBackground,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
            labelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(child: Text(t.common.addressBook, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Tab(child: Text(t.common.myWallet, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        centerTitle: true,
        actions: [SizedBox(width: 47.w)],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 12.w),
        child: TabBarView(controller: _tabController, children: [_buildAddressBookWidget(context), _buildMyWalletWidget(context)]),
      ),
    );
  }
}

Widget _buildAddressBookWidget(BuildContext context) {
  return SafeArea(
    child: Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                child: Image.asset('assets/images/addressBook.png', width: 60.w, height: 60.w),
              ),
              SizedBox(height: 10),
              Text(
                t.common.noAddress,
                style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
              ),
              Text(t.common.tipFillAddress, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(50.r)),
          child: Text(t.common.addNewAddress, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
        ),
      ],
    ),
  );
}

Widget _buildMyWalletWidget(BuildContext context) {
  return SafeArea(
    child: Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
                child: Image.asset('assets/images/addressBook.png', width: 60.w, height: 60.w),
              ),
              SizedBox(height: 10),
              Text(
                t.common.noAddress,
                style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
              ),
              Text(t.common.tipFillAddress, style: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ],
          ),
        ),
      ],
    ),
  );
}
