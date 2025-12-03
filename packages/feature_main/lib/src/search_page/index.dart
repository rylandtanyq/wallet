import 'dart:async';
import 'package:feature_browser/dapp_browser/index.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:feature_main/src/search_page/fragments/search_page_all_fragments.dart';
import 'package:feature_main/src/search_page/fragments/search_page_contract_fragments.dart';
import 'package:feature_main/src/search_page/fragments/search_page_currency_fragments.dart';
import 'package:feature_main/src/search_page/fragments/search_page_dapp_fragments.dart';
import 'package:feature_main/src/search_page/fragments/search_page_dapp_user_agreement_fragments.dart';
import 'package:feature_main/src/search_page/fragments/search_page_hint_open_dapp_link_fragments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_ui/widget/sticky_tabbar_delegate.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  TabController? _tabController;
  List<String> _search_history = [];
  Timer? _debounce;
  bool _showSuffixIcon = false;
  bool _showHintOpenDappLink = false;
  bool _showSearchHistoryWidget = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _tabController?.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {});
      }
    });
    _getSearchHistoryList();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
    _debounce?.cancel();
  }

  void _ensureControllerWithLength(int newLen) {
    if (_tabController != null && _tabController!.length == newLen) return;
    final oldIndex = _tabController?.index ?? 0;
    _tabController?.dispose();
    final initIndex = newLen == 0 ? 0 : oldIndex.clamp(0, newLen - 1);
    _tabController = TabController(length: newLen, vsync: this, initialIndex: initIndex);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textEditingController.text.trim().isNotEmpty;

    final tabs = <Widget>[if (hasText) Tab(text: t.common.all), Tab(text: t.search.token), Tab(text: t.search.contract), Tab(text: t.search.dapp)];
    final views = <Widget>[
      if (hasText) SearchPageAllFragments(),
      SearchPageCurrencyFragments(),
      SearchPageContractFragments(),
      SearchPageDappFragments(),
    ];
    _ensureControllerWithLength(tabs.length);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            GestureDetector(onTap: () => Navigator.of(context).pop(), child: Icon(Icons.arrow_back_ios)),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: t.search.placeholder,
                  hintStyle: AppTextStyles.size13.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: EdgeInsets.only(right: 14),
                  border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.r)),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onBackground),
                  suffixIcon: _showSuffixIcon ? _suffixIconWidget() : null,
                ),
                onChanged: (e) => _onSearchChange(e),
              ),
            ),
            SizedBox(width: 13.w),
            GestureDetector(
              onTap: () => _addSearchHistoryList(),
              child: Text(t.search.search, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(right: 12.w, left: 12.w, top: 8.w),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  if (!_showSearchHistoryWidget && _search_history.isNotEmpty) SliverToBoxAdapter(child: _searchHistoryWidget()),
                  if (_showHintOpenDappLink)
                    SliverToBoxAdapter(
                      child: SearchPageHintOpenDappLinkFragments(
                        textEditing: _textEditingController.text,
                        onTap: () {
                          _addSearchHistoryList();
                          _showDappUserAgreementModal(_textEditingController.text);
                        },
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: Text(
                      t.search.hotSearch,
                      style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 12.w)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: Theme.of(context).colorScheme.onBackground,
                        // indicatorPadding: EdgeInsets.only(bottom: -6),
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                        labelColor: Theme.of(context).colorScheme.onBackground,
                        padding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.only(right: 22.w),
                        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        dividerColor: Colors.transparent,
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        tabs: tabs,
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(controller: _tabController, children: views),
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchChange(String e) {
    // 每次输入都先取消上一次防抖定时器
    _debounce?.cancel();

    final text = e.trim();

    if (text.isEmpty) {
      setState(() {
        _showSuffixIcon = false;
      });
      return;
    }
    final isUrl = _isPotentialUrl(text);
    if (!isUrl) {
      setState(() {
        // _showSuffixIcon = false;
        _showHintOpenDappLink = false;
        _showSearchHistoryWidget = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _textEditingController.text = text;
        _showSuffixIcon = true;
        _showSearchHistoryWidget = true;
        _showHintOpenDappLink = true;
      });
    });
  }

  bool _isPotentialUrl(String input) {
    final s = input.trim();
    if (s.isEmpty) return false;

    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(s)) return false;

    if (RegExp(r'\s').hasMatch(s)) return false;

    final urlPattern = RegExp(
      r'^(https?:\/\/)?'
      r'(?:www\.)?'
      r'(?:[a-zA-Z0-9-]+\.)+'
      r'(?:[a-zA-Z]{2,}|xn--[a-zA-Z0-9]{2,})'
      r'(?:\:\d{1,5})?'
      r'(?:\/[^\s]*)?'
      r'$',
      caseSensitive: false,
    );

    return urlPattern.hasMatch(s);
  }

  void _getSearchHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _search_history = prefs.getStringList('search_history') ?? <String>[];
    });
  }

  void _addSearchHistoryList() async {
    final prefs = await SharedPreferences.getInstance();
    final content = _textEditingController.text.trim();

    if (content.isEmpty) return;

    setState(() {
      if (!_search_history.contains(content)) {
        _search_history.add(content);
        prefs.setStringList('search_history', _search_history);
      }
    });
  }

  void _selectedSearchHistory(String item) {
    setState(() {
      final isUrl = _isPotentialUrl(item);
      if (isUrl) {
        _showSuffixIcon = true;
        _textEditingController.text = item;
        _showHintOpenDappLink = true;
        _showSearchHistoryWidget = true;
      } else {
        _showSuffixIcon = true;
        _textEditingController.text = item;
        _showHintOpenDappLink = false;
        _showSearchHistoryWidget = true;
      }
    });
  }

  void _removeSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _search_history.clear();
      prefs.remove('search_history');
    });
  }

  Widget _suffixIconWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textEditingController.clear();
          _showSuffixIcon = false;
          _showSearchHistoryWidget = false;
          _showHintOpenDappLink = false;
        });
      },
      child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  Widget _searchHistoryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.common.search_history,
              style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.w500),
            ),
            GestureDetector(onTap: () => _removeSearchHistory(), child: Icon(Icons.delete, size: 20)),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          children: List.generate(_search_history.length, (index) {
            String item = _search_history[index];
            return GestureDetector(
              onTap: () => _selectedSearchHistory(item),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: EdgeInsets.only(right: 8, bottom: 8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10.r)),
                child: Text(item, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _hintOpenDappLink() {
    return GestureDetector(
      onTap: () {
        _addSearchHistoryList();
        Get.to(
          DappBrowser(dappUrl: _textEditingController.text),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 16, color: Theme.of(context).colorScheme.primary),
                    SizedBox(width: 4),
                    Text(t.common.open_link_below, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                  ],
                ),
                Text(_textEditingController.text, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDappUserAgreementModal(String textEditing) async {
    return SearchPageDappUserAgreementFragments.show(context, textEditing: textEditing);
  }
}
