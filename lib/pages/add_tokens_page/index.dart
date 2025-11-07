import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled1/constants/hive_boxes.dart';
import 'package:untitled1/hive/tokens.dart';
import 'package:untitled1/i18n/strings.g.dart';
import 'package:untitled1/pages/add_tokens_page/fragments/hint_fragments.dart';
import 'package:untitled1/pages/add_tokens_page/fragments/shimmer_fragments.dart';
import 'package:untitled1/pages/add_tokens_page/fragments/token_item_fragments.dart';
import 'package:untitled1/pages/add_tokens_page/models/add_tokens_model.dart';
import 'package:untitled1/state/app_provider.dart';
import 'package:untitled1/theme/app_textStyle.dart';
import 'package:untitled1/util/HiveStorage.dart';
import 'package:untitled1/util/image_cache_repo.dart';

class AddingTokens extends ConsumerStatefulWidget {
  const AddingTokens({super.key});

  @override
  ConsumerState<AddingTokens> createState() => _AddingTokensState();
}

class _AddingTokensState extends ConsumerState<AddingTokens> {
  final TextEditingController _textEditingController = TextEditingController();
  String? tokensSearchContent;
  late List<Tokens> _tokenList = [];
  Timer? _debounce;
  String _currentAddr = '';

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

  Future<void> _searchTokens(String e) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    final addr = e.trim();
    setState(() => _currentAddr = addr);
    _debounce = Timer(Duration(milliseconds: 1000), () async {
      if (_currentAddr.isEmpty) return;
      ref.read(getWalletTokensProvide(addr).notifier).fetchWalletTokenData(addr);
    });
  }

  Future<void> _addedToken(String name, String symbol, String image, String mint) async {
    final confirm = await _showDialogWidget(
      title: t.wallet.add,
      content: t.wallet.confirm_add_solana_token(token: name),
    );
    if (!confirm) return;
    try {
      final tokensResult = Tokens(image: image, title: name, subtitle: symbol, price: '0.00', number: '0.00', toadd: true, tokenAddress: mint);
      // 读取已保存的列表
      List<Map> rawList = await HiveStorage().getList<Map>('tokens', boxName: boxTokens) ?? <Map>[];
      final list = rawList.map((e) => Tokens.fromJson(Map<String, dynamic>.from(e))).toList();
      // 防止重复添加
      final exists = list.any((e) => e.title == tokensResult.title);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.wallet.solana_token_added(tokenName: tokensResult.title),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: Duration(seconds: 2),
          ),
        );
        _textEditingController.clear();
        return;
      }
      list.add(tokensResult);
      final listAsMap = list.map((t) => t.toJson()).toList();
      await HiveStorage().putList<Map>('tokens', listAsMap, boxName: boxTokens);
      setState(() {
        _tokenList = list;
      });
      _textEditingController.clear();
      final imgUrl = (image).trim();
      if (imgUrl.isNotEmpty) {
        // 需要 import 'dart:async' 来使用 unawaited（可选；不用也行）
        // unawaited(ImageCacheRepo.I.getOrFetch(imgUrl));
        // 或者：
        Future.microtask(() => ImageCacheRepo.I.getOrFetch(imgUrl));
      }
    } catch (e) {
      debugPrint('代币添加错误：$e');
    }
  }

  Future<void> _deleteTokens(int index) async {
    if (index < 0 || index >= _tokenList.length) return;

    final removed = _tokenList[index];

    setState(() {
      _tokenList.removeAt(index);
    });

    try {
      // 持久化到 Hive
      final listAsMap = _tokenList.map((t) => t.toJson()).toList();
      await HiveStorage().putList<Map>('tokens', listAsMap, boxName: boxTokens);

      // 清理对应图片缓存
      final img = (removed.image).trim();
      if (img.isNotEmpty) {
        ImageCacheRepo.I.invalidateUrl(img);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.wallet.solana_token_deleted(tokenName: removed.title),
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // 回滚 UI
      setState(() {
        _tokenList.insert(index, removed);
      });
      debugPrint('代币删除失败：$e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("代币删除失败"), backgroundColor: Theme.of(context).colorScheme.error));
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
                    _searchTokens(e);
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
          _buildSearchResult(),
          Text(
            t.wallet.token_added,
            style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
          ),
          _tokensListWidget(_tokenList),
        ],
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_currentAddr.isEmpty) return const SizedBox.shrink();
    final async = ref.watch(getWalletTokensProvide(_currentAddr));
    return async.when(
      data: (AddTokensModel data) {
        AddTokensItemModel item = data.result.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.wallet.searched_token,
              style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            TokenItemFragments(
              image: item.image ?? '',
              name: item.name,
              symbol: item.symbol,
              price: '0.00',
              num: '0.00',
              action: TokenTrailingAction.add,
              onTap: () => _addedToken(item.name, item.symbol, item.image ?? '', item.mint),
            ),
            SizedBox(height: 30),
          ],
        );
      },
      error: (e, _) {
        debugPrint('data error: $e');
        return HintFragments(
          icons: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          hitTitle: t.wallet.unknown_error_please_try_again_later,
        );
      },
      loading: () => ShimmerFragments(),
    );
  }

  Widget _tokensListWidget(List<Tokens> tokenList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final item = tokenList[index];
        return TokenItemFragments(
          index: index,
          image: item.image,
          name: item.title,
          symbol: item.subtitle,
          num: '0.00',
          price: '0.00',
          action: TokenTrailingAction.remove,
          onLongPress: () async {
            HapticFeedback.heavyImpact();
            final confirm = await _showDialogWidget(
              title: t.wallet.delete,
              content: t.wallet.confirm_delete_solana_token(token: item.title),
            );
            if (confirm) _deleteTokens(index);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 20);
      },
      itemCount: tokenList.length,
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
