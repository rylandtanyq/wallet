import 'package:feature_browser/dapp_browser/index.dart';
import 'package:feature_main/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/theme/app_textStyle.dart';
import 'package:shared_utils/wallet_nav.dart';

class DiscoverySelectedFragments extends StatefulWidget {
  const DiscoverySelectedFragments({super.key});

  @override
  State<DiscoverySelectedFragments> createState() => _DiscoverySelectedFragmentsState();
}

class _DiscoverySelectedFragmentsState extends State<DiscoverySelectedFragments> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t.discovery.onchainTrending,
                      style: AppTextStyles.labelMedium.copyWith(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    WalletNav.to(DappBrowser(dappUrl: "https://wpos.pro/"), duration: const Duration(milliseconds: 300));
                  },
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset("assets/images/tt_link.png", width: 38, height: 38)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.discovery.ttDao, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                            Text(
                              t.discovery.ttWalletTagline,
                              style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    WalletNav.to(DappBrowser(dappUrl: "https://raydium.io/"), duration: const Duration(milliseconds: 300));
                  },
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset("assets/images/tt_dao.png", width: 38, height: 38)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.discovery.raydium, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                            Text(
                              t.discovery.raydiumDescription,
                              style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    WalletNav.to(DappBrowser(dappUrl: "https://ave.ai/"), duration: const Duration(milliseconds: 300));
                  },
                  child: Row(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset("assets/images/aave_link.png", width: 38, height: 38)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.discovery.aave, style: AppTextStyles.headline4.copyWith(color: Theme.of(context).colorScheme.onBackground)),
                            Text(
                              t.discovery.aaveDescription,
                              style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child: Text(
              t.discovery.thirdPartyServiceProvided,
              style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
