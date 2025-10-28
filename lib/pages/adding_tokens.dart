import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/HiveStorage.dart';

class AddingTokens extends StatefulWidget {
  const AddingTokens({super.key});

  @override
  State<AddingTokens> createState() => _AddingTokensState();
}

class _AddingTokensState extends State<AddingTokens> {
  final TextEditingController _textEditingController = TextEditingController();
  String? tokensSearchContent;
  late List<Tokens> _tokenList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadingTokens();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _debounce?.cancel();
  }

  Future<void> _loadingTokens() async {
    final rawList = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? <Map>[];
    _tokenList = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
    setState(() {});
  }

  Future<void> _addingTokens(String e) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 800), () async {
      if (_textEditingController.text.trim().isEmpty) return;
      final confirm = await _showDialogWidget(
        title: t.wallet.add,
        content: t.wallet.confirm_add_solana_token(token: _textEditingController.text.trim().toUpperCase()),
      );
      if (!confirm) return;
      try {
        final tokensResult = Tokens(
          image: '',
          title: _textEditingController.text.trim().toUpperCase(),
          subtitle: _textEditingController.text.trim().toUpperCase(),
          price: '0.00',
          number: '0.00',
          toadd: true,
        );
        // 读取已保存的列表
        List<Map> rawList = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? <Map>[];
        final list = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
        // 防止重复添加
        final exists = list.any((e) => e.title == tokensResult.title);
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.wallet.solana_token_added(tokenName: tokensResult.title)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        list.add(tokensResult);
        final listAsMap = list.map((t) => t.toJson()).toList();
        await HiveStorage().putList<Map>('tokens', listAsMap, boxName: boxTokens);
        setState(() {
          _tokenList = list;
        });
        _textEditingController.clear();
      } catch (e) {
        debugPrint('代币添加错误：$e');
      }
    });
  }

  Future<void> _deleteTokens(int index) async {
    try {
      final removed = _tokenList.removeAt(index);
      final listAsMap = _tokenList.map((t) => t.toJson()).toList();
      await HiveStorage().putList('tokens', listAsMap, boxName: boxTokens);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.wallet.solana_token_deleted(tokenName: removed.title)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('代币删除失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (result, didPop) {
        if (!result) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leadingWidth: 40,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20.w, color: Theme.of(context).colorScheme.onBackground),
            onPressed: () {
              Feedback.forTap(context);
              Navigator.of(context).pop(true);
            },
          ),
          title: Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Text(t.wallet.add_token, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: t.wallet.token_name_or_contract_address,
                    hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: EdgeInsets.only(right: 14),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                  ),
                  onChanged: (e) {
                    _addingTokens(e);
                  },
                ),
                SizedBox(height: 25),
                _buildTokenContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildTokenContent() {
    if (_tokenList.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/no_transaction.png', width: 108, height: 92),
              SizedBox(height: 8),
              Text(t.wallet.no_token_added_yet, style: AppTextStyles.headline2.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView(
        children: [
          Text(
            t.wallet.token_added,
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          _tokensListWidget(_tokenList),
        ],
      ),
    );
  }

  Widget _tokensListWidget(List<Tokens> _tokenList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final item = _tokenList[index];
        return Container(
          margin: EdgeInsets.only(top: index == 0 ? 30 : 0),
          width: double.infinity,
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/solana_logo.png', width: 40, height: 40),
              SizedBox(width: 10.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                        ),
                        Text(item.subtitle, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '0.00',
                          style: AppTextStyles.size15.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
                        ),
                        Text('¥0.00', style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Icon(Icons.add_circle_outline),
              GestureDetector(
                onLongPress: () async {
                  HapticFeedback.heavyImpact();
                  final confirm = await _showDialogWidget(
                    title: t.wallet.delete,
                    content: t.wallet.confirm_delete_solana_token(token: item.title),
                  );
                  if (confirm) _deleteTokens(index);
                },
                child: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 20);
      },
      itemCount: _tokenList.length,
    );
  }

  Future<bool> _showDialogWidget({required String title, required String content}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 禁止点外部关闭
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            title,
            style: AppTextStyles.size17.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onBackground),
          ),
          content: Text(content, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.wallet.cancel, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.wallet.confirm, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
