/// Hive Box names（集中管理）
const String boxWallet = 'wallet'; // 钱包相关：obj_currentSelectWallet / col_wallets_data / selected_address
const String boxTokens = 'tokens'; // 代币相关：Tokens 列表/字典等
const String boxTx = 'transactions'; // 交易记录（建议 LazyBox）
const String boxApp = 'appData'; // 默认杂项 KV（尽量少放大对象）

/// 键名前缀（与现有封装一致）
const String kObj = 'obj_'; // 对象
const String kCol = 'col_'; // 集合（List/Map）
