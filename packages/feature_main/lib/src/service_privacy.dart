import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_ui/theme/app_textStyle.dart';

class ServicePrivacy extends StatelessWidget {
  const ServicePrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appBarTitleStyle = AppTextStyles.headline4.copyWith(color: colorScheme.onBackground, fontWeight: FontWeight.w600);
    final pageTitleStyle = AppTextStyles.headline2.copyWith(color: colorScheme.onBackground, fontWeight: FontWeight.w800);
    final sectionTitleStyle = AppTextStyles.headline3.copyWith(color: colorScheme.onBackground, fontWeight: FontWeight.w700);
    final bodyStyle = AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface, height: 1.5);
    final boldBodyStyle = bodyStyle.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Feedback.forTap(context);
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back_ios_new, size: 20.w, color: colorScheme.onBackground),
        ),
        title: Text('服务与隐私声明', style: appBarTitleStyle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TT钱包用户服务与隐私政策', style: pageTitleStyle),
              SizedBox(height: 8.h),
              Text('生效日期：2025年12月2日\n最近更新：2025年12月2日', style: bodyStyle),
              SizedBox(height: 16.h),
              Text(
                '感谢您选择使用 TT钱包（以下简称“本软件”或“TT钱包”）。本《TT钱包用户服务与隐私政策》（以下简称“本协议”或“本政策”）由易利科技有限公司（以下简称“本公司”或“我们”）与使用 TT钱包服务的自然人或其他主体（以下简称“用户”或“您”）共同订立，对您使用 TT钱包相关服务的全过程具有法律约束力。',
                style: bodyStyle,
              ),
              SizedBox(height: 8.h),
              Text(
                '在您下载、安装、打开、注册、导入或使用 TT钱包之前，请务必仔细阅读并充分理解本协议全部内容，尤其是其中以加粗形式提示的条款，这些条款可能对您的合法权益具有重大影响，包括但不限于责任限制、风险提示、隐私保护、法律适用等。',
                style: bodyStyle,
              ),
              SizedBox(height: 8.h),
              Text('若您不同意本协议的任一内容，请不要下载、安装或使用 TT钱包。您一旦下载、安装、创建或导入钱包，或以任何方式使用 TT钱包，即视为您已阅读并充分理解本协议，并同意受其约束。', style: boldBodyStyle),

              SizedBox(height: 24.h),
              Text('第一部分  总则与定义', style: sectionTitleStyle),
              SizedBox(height: 12.h),

              Text('一、协议主体与适用范围', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 协议主体\n'
                '（1）本协议由您与易利科技有限公司订立。\n'
                '（2）易利科技有限公司依法运营并对 TT钱包软件及相关服务享有合法权利，但不对用户在区块链上的行为承担控制或干预能力。\n\n'
                '2. 适用范围\n'
                '（1）本协议适用于您通过移动端、桌面端或其他终端设备使用 TT钱包提供的钱包管理、资产展示、转账收款、DApp 连接、授权签名等功能。\n'
                '（2）除本协议外，本公司还可能就具体功能发布专项条款、公告、操作规则等，上述内容一经发布即为本协议不可分割的组成部分，与本协议具有同等法律效力。\n\n'
                '3. 协议更新\n'
                '（1）我们有权根据业务发展、法律法规或监管政策变化，对本协议进行修订，并通过应用内公告、弹窗或其他合理方式进行提示。\n'
                '（2）本协议更新后，若您继续使用 TT钱包，即视为您已充分阅读、理解并同意更新后的内容；如您不同意，应立即停止使用 TT钱包。',
                style: bodyStyle,
              ),

              SizedBox(height: 12.h),
              Text('二、术语定义', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '除非本协议另有约定，下列术语具有如下含义：\n\n'
                '1. 数字资产 / 加密资产：基于区块链或类似技术、以密码学为基础的、具有一定价值或功能的代币、通证等（例如 BTC、ETH、SOL 及其他兼容公链上的 Token）。\n'
                '2. 区块链网络 / 公链：去中心化的区块链系统，如 Bitcoin、Ethereum、Solana 等。\n'
                '3. 钱包地址：由公钥或其他加密算法生成的字符序列，用于接收和查看链上资产。\n'
                '4. 私钥：用于生成数字签名、控制和支配对应钱包地址及其资产的核心数据，一旦泄露或丢失，可能导致资产被永久转移且无法追回。\n'
                '5. 助记词：按照特定算法从私钥生成的一组单词，用于备份和恢复钱包，是私钥的可读形式。\n'
                '6. Keystore / 密钥库：由私钥或助记词经过加密算法与钱包密码保护生成的数据文件，用于在本地设备中保存加密后的密钥信息。\n'
                '7. 钱包密码（本地密码）：您在创建或导入钱包时设置的密码，用于加密存储在本地设备中的私钥、助记词或 Keystore。TT钱包不会也无法获取该密码。\n'
                '8. 去中心化钱包：私钥仅存储在用户本地设备中，由用户自行保管，本公司不保存、不托管用户的私钥、助记词或钱包密码，也无法为用户找回。\n'
                '9. DApp（去中心化应用）：运行在区块链网络上的应用程序，可能由第三方独立开发和运营，TT钱包仅作为网络入口和签名/授权工具。',
                style: bodyStyle,
              ),

              SizedBox(height: 24.h),
              Text('第二部分  服务内容与使用规则', style: sectionTitleStyle),
              SizedBox(height: 12.h),

              Text('一、服务内容', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 基础功能\n'
                'TT钱包提供包括但不限于以下功能：\n'
                '（1）创建或导入多链去中心化钱包；\n'
                '（2）查看和管理多个区块链网络及地址下的数字资产余额与交易记录；\n'
                '（3）发起和签名链上转账及其他交易操作；\n'
                '（4）通过二维码或链接方式连接 DApp，并对 DApp 请求进行授权或签名；\n'
                '（5）显示部分代币价格、市场信息、交易记录或其他链上数据（如有）；\n'
                '（6）提供本地安全相关功能，如应用锁、生物识别解锁等；\n'
                '（7）根据产品迭代不时新增或调整的其他功能。\n\n'
                '2. 第三方服务与 DApp 接入\n'
                '（1）TT钱包可能集成或提供跳转至第三方 DApp、交易平台、质押/理财服务、跨链桥、法币买卖通道等服务接口。\n'
                '（2）上述第三方服务由相应第三方独立提供与运营，本公司不对第三方服务的内容、质量、安全性、合法性或可用性做出任何明示或默示担保。\n'
                '（3）您应在使用任何第三方服务前，仔细阅读其《用户协议》《隐私政策》等规则，因使用第三方服务产生的任何争议或损失，由您与第三方自行解决。\n\n'
                '3. 服务性质与限制\n'
                '（1）TT钱包为非托管、工具性质的钱包软件，不提供法定货币兑换服务、不代为托管用户数字资产、不代理用户进行任何投资或交易决策。\n'
                '（2）TT钱包不保证支持所有存在的数字资产或所有公链网络。您不应将 TT钱包用于存取或操作不被支持的资产，否则可能导致资产永久丢失，由您自行承担相关损失。',
                style: bodyStyle,
              ),

              SizedBox(height: 12.h),
              Text('二、用户资格与合规使用', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 用户资格\n'
                '（1）您应具备完全民事行为能力，能够独立承担相应法律责任。\n'
                '（2）如您为未成年人或限制民事行为能力人，应在监护人参与下使用 TT钱包，并由监护人承担相关法律责任。\n'
                '（3）如您所在国家/地区的法律或监管规定禁止使用类似服务，或对数字资产有特殊合规要求，您应自行确保使用 TT钱包不违反所在司法辖区法律，因违反当地法律法规导致的一切后果由您自行承担。\n\n'
                '2. 合规使用义务\n'
                '您承诺在使用 TT钱包过程中：\n'
                '（1）不利用 TT钱包从事任何违法犯罪活动，包括但不限于洗钱、恐怖融资、诈骗、赌博、非法集资、传销等；\n'
                '（2）不利用技术手段攻击或破坏 TT钱包、区块链网络、安全设施或他人合法权益；\n'
                '（3）不恶意上传或传播病毒、木马、恶意代码、钓鱼链接等内容；\n'
                '（4）遵守本协议及本公司不时发布的公告、规则等。\n\n'
                '3. 设备与网络要求\n'
                '（1）您需自行准备终端设备、网络环境及必要的安全防护措施。\n'
                '（2）因设备故障、网络中断、电力中断、系统崩溃等造成服务中断或数据丢失，本公司不承担由此产生的损失责任。',
                style: bodyStyle,
              ),

              SizedBox(height: 24.h),
              Text('第三部分  钱包安全与风险提示', style: sectionTitleStyle),
              SizedBox(height: 12.h),

              Text('一、私钥、助记词和密码的自主管理', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 当您在 TT钱包中创建或导入钱包时，应用将在您的本地设备中生成或导入私钥，并可能以助记词或 Keystore 形式进行本地加密存储。\n'
                '2. 私钥、助记词、Keystore 和钱包密码仅存储在您的本地设备或您选择的备份介质中，TT钱包及本公司不会也无法获取、保存或同步上述信息。\n'
                '3. 因您未备份或不慎遗失、泄露私钥、助记词、Keystore 或密码而导致的资产损失，由您自行承担全部后果，本公司无法为您找回或恢复。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('二、妥善保管义务', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '您应当：\n'
                '（1）在安全、隔离的环境中备份私钥/助记词（建议离线纸质备份或硬件安全设备）；\n'
                '（2）不以截图、照片、云笔记、即时通讯工具等不安全方式存储私钥/助记词/密码；\n'
                '（3）不向任何人透露私钥、助记词、Keystore 或钱包密码，包括自称为“客服”“官方”的人员；\n'
                '（4）一旦发现设备遗失、被盗或存在恶意软件风险，应第一时间更换设备并转移资产。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('三、生物识别与解锁方式', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. TT钱包可能提供指纹、人脸识别等解锁方式，本质上是对本地密码的加密封装。\n'
                '2. 生物识别功能依赖于您设备操作系统或第三方服务的实现，本公司不保证其绝对安全，也不对由此产生的风险承担责任。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('四、交易操作的不可撤销性', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 区块链交易一旦广播至网络并被确认，在技术上通常不可撤销或更改。\n'
                '2. 在发起任何转账、授权、签名操作前，请务必仔细核对目标地址、资产种类、金额、Gas/手续费等信息。\n'
                '3. 因您自身操作失误导致的任何交易或资产损失，概由您自行承担。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('五、风险提示', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 市场风险：数字资产价格波动剧烈，可能大幅上涨或归零，您应自行承担全部投资风险，本公司不对任何收益作出承诺或担保。\n'
                '2. 技术风险：区块链网络可能存在缺陷、分叉、节点故障、共识攻击、合约漏洞等风险，设备也可能遭受病毒、木马、恶意软件、钓鱼网站攻击等风险。\n'
                '3. 合约与 DApp 风险：您通过 TT钱包连接的智能合约、DeFi 协议、GameFi、NFT 市场等可能存在逻辑漏洞、项目方作恶、运营方跑路、监管介入等风险，本公司不参与第三方 DApp 的开发与运营，也不对其安全性、稳定性或合规性提供担保。\n'
                '4. 法律与监管风险：各国/地区对数字资产及相关服务的监管政策可能随时变化，导致交易受限、资产被冻结、服务被禁止等风险，您应自觉关注并遵守所在司法辖区法律法规。\n'
                '5. 其他不可抗力因素：自然灾害、战争、罢工、政府行为、电力中断、基础网络中断等不可抗力可能导致服务中断或资产损失。',
                style: bodyStyle,
              ),

              SizedBox(height: 24.h),
              Text('第四部分  责任限制与免责', style: sectionTitleStyle),
              SizedBox(height: 12.h),
              Text(
                '1. TT钱包及相关服务基于现有技术和条件提供，我们不保证服务完全无错误、无中断、无缺陷，也不保证其完全符合您的特定使用需求。\n'
                '2. 在适用法律允许的最大范围内，本公司不对以下情况承担责任，包括但不限于：\n'
                '   · 您未妥善备份或泄露私钥、助记词、Keystore 或钱包密码；\n'
                '   · 您下载、安装非官方版本或通过非官方渠道获取 TT钱包而遭受损失；\n'
                '   · 您将设备借给他人使用，或允许他人访问您的钱包；\n'
                '   · 您输入错误的收款地址、选择错误的公链或不受支持的代币；\n'
                '   · 您因不熟悉区块链知识或操作失误导致的交易失败或资产损失；\n'
                '   · 任何第三方 DApp、交易所、法币渠道或其他第三方服务引发的争议或损失；\n'
                '   · 系统延迟、网络拥堵、区块链网络故障等导致的交易确认异常、显示延迟或记录不准确。\n'
                '3. 对于因使用或无法使用 TT钱包而引发的任何间接、附带、特殊或惩罚性损失（包括但不限于利润损失、业务中断、数据丢失等），本公司在任何情况下均不承担赔偿责任。\n'
                '4. 如适用法律要求本公司对您承担赔偿责任，在不违反强制性法律规定的前提下，我们对您承担的赔偿责任总额以您最近十二个月内因使用 TT钱包服务而向本公司支付的直接服务费用总额为上限（如 TT钱包服务本身为免费，则该上限可以为零）。',
                style: bodyStyle,
              ),

              SizedBox(height: 24.h),
              Text('第五部分  知识产权与服务变更', style: sectionTitleStyle),
              SizedBox(height: 12.h),
              Text(
                '1. 知识产权\n'
                '（1）TT钱包软件及其相关文档、界面设计、图标、Logo、源代码、目标代码等由本公司或相关权利人依法享有知识产权。\n'
                '（2）未经本公司事先书面授权，您不得对 TT钱包进行反向工程、反向编译、反汇编、修改、复制、出租、发行、再许可，或基于 TT钱包制作衍生作品。\n\n'
                '2. 服务变更、中断与终止\n'
                '（1）我们有权基于业务调整、系统维护、法律法规或监管要求等原因，对 TT钱包服务进行升级、调整、中断或终止，并通过应用内公告、官网或其他合理方式通知您（紧急情况除外）。\n'
                '（2）若发生以下任一情形，本公司有权在不事先通知的情况下中止或终止对您提供部分或全部服务，并视情节决定是否限制或取消您使用 TT钱包部分功能：\n'
                '   · 您违反本协议约定或相关法律法规；\n'
                '   · 您被司法或行政机构认定为具有违法或高风险行为；\n'
                '   · 出于安全原因（如重大安全漏洞风险、异常操作、涉嫌欺诈等）。\n'
                '（3）在服务中止或终止后，您仍应自行完成资产迁移或备份，本公司不对您未及时处理所造成的任何损失负责。',
                style: bodyStyle,
              ),

              SizedBox(height: 24.h),
              Text('第六部分  个人信息与隐私保护', style: sectionTitleStyle),
              SizedBox(height: 12.h),

              Text('一、隐私保护总则', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 本公司高度重视用户的个人信息和隐私保护，将按照合法、正当、必要的原则处理您的相关信息。\n'
                '2. TT钱包为去中心化钱包，本公司不收集、不存储您的私钥、助记词、Keystore 或钱包密码，这些信息仅存储于您的本地设备，由您自行保管。\n'
                '3. 除非本政策另有说明或法律法规另有规定，我们不会超出本政策所述目的和范围收集、使用您的个人信息。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('二、我们可能收集的信息类型', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '在您使用 TT钱包服务的过程中，我们可能会在必要范围内收集以下信息：\n'
                '1. 设备信息与日志信息：包括设备型号、操作系统版本、设备标识符、语言设置、时区、应用版本、崩溃日志、网络信息等；\n'
                '2. 钱包相关信息：包括您在 TT钱包中创建或导入的钱包地址、添加的代币、网络配置，以及为展示资产和交易记录而从区块链网络读取的公开信息；\n'
                '3. 使用行为信息：如使用频率、停留时长、页面访问记录、功能点击情况等，一般以去标识化或汇总统计方式使用；\n'
                '4. 交易相关信息：如交易发起请求、交易 Hash、目标地址、资产种类、金额、Gas/手续费、交易状态等（此类信息多为链上公开信息）；\n'
                '5. 客服与反馈信息：如您在反馈、投诉、咨询中主动提供的联系方式、问题描述、截图、日志等；\n'
                '6. 依法需收集的信息：在法律法规、监管要求或有权机关要求的情形下，我们可能根据相关规定收集、保存并在必要时提供相关信息。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('三、我们如何使用这些信息', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '我们收集您的信息主要用于：\n'
                '1. 提供 TT钱包的基础功能和服务，确保服务正常运行；\n'
                '2. 保障产品和服务的安全性，防范风险与欺诈；\n'
                '3. 改进和优化产品体验，例如通过统计分析了解不同功能的使用情况；\n'
                '4. 向您发送与服务相关的重要通知，如版本更新、协议或政策更新等；\n'
                '5. 在符合法律法规与监管要求的前提下，用于合规审计、数据分析与研究；\n'
                '6. 其他经您同意或法律允许的用途。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('四、信息共享、转让与公开披露', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 共享：除以下情形外，我们不会与本公司以外的任何公司、组织和个人共享您的个人信息：\n'
                '   · 在获得您明示同意的情况下共享；\n'
                '   · 在法律法规、行政或司法机关要求的情况下，向有权机关共享；\n'
                '   · 与为我们提供技术支持、数据分析、安全服务等的合作伙伴在必要范围内共享，并采取脱敏或去标识化处理；\n'
                '   · 在 TT钱包与第三方服务集成场景下，在您主动使用第三方服务时向其传递必要信息（如钱包地址），该等信息将受第三方隐私政策约束。\n\n'
                '2. 转让：除非获得您的明示同意，或在公司合并、重组、收购等情形下且新的持有方继续受本政策约束，我们不会向任何公司、组织和个人转让您的个人信息。\n\n'
                '3. 公开披露：我们不会公开披露您的个人信息，但在法律法规规定或行政、司法机关的强制性要求下，在必要范围内公开披露。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('五、第三方服务和 DApp 的隐私责任', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '当您通过 TT钱包跳转或连接到第三方 DApp、网站或服务时，您在该等第三方服务中提交或产生的个人信息，将由相关第三方独立收集和处理，该等信息处理不受本政策约束，本公司也不承担相应隐私保护责任。在使用第三方服务前，请您务必仔细阅读并理解其《用户协议》《隐私政策》等内容。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('六、信息存储与安全保障', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text(
                '1. 我们仅在实现本政策所述目的所必需的期限内保存您的个人信息，超出期限后将根据法律法规要求删除或匿名化处理。但为遵守法律法规、履行本协议或维护合法权益所必需的情形下，我们可能在更长时间内保存相关信息。\n'
                '2. 为保护您的信息安全，我们采取合理、可行的安全保护措施，包括但不限于加密存储、访问控制、安全审计等，但任何安全系统都存在一定风险，我们无法保证信息在任何情况下均绝对安全。\n'
                '3. 私钥、助记词、Keystore 和钱包密码仅存储在您的本地设备中，TT钱包不以任何形式上传或存储这些信息。一旦您遗失或泄露上述信息，可能造成不可逆的资产损失，本公司无法为您找回或恢复。',
                style: bodyStyle,
              ),

              SizedBox(height: 8.h),
              Text('七、您对个人信息的控制权', style: boldBodyStyle),
              SizedBox(height: 4.h),
              Text('在适用法律法规允许的范围内，您对您的个人信息享有访问、更正、删除、撤回授权等权利。对于暂不支持通过产品界面直接操作的，您可以通过本协议列明的联系方式与我们取得联系，我们将在合理期限内予以处理。', style: bodyStyle),

              SizedBox(height: 24.h),
              Text('第七部分  协议变更、适用法律与争议解决', style: sectionTitleStyle),
              SizedBox(height: 12.h),
              Text(
                '1. 我们可能根据实际情况不时对本协议内容进行调整或更新。重大变更我们会通过 TT钱包内显著位置弹窗、公告等方式提示您。如您在本协议变更后继续使用 TT钱包，即视为您接受变更后的协议。\n'
                '2. 本协议的订立、解释、效力、履行及争议解决，均适用中华人民共和国法律（不含香港特别行政区、澳门特别行政区及台湾地区法律）。\n'
                '3. 因本协议引起的或与本协议有关的任何争议，双方应首先友好协商；协商不成的，任何一方均可向易利科技有限公司所在地有管辖权的人民法院提起诉讼。\n'
                '4. 若本协议的任何条款被有权机关认定为无效或不可执行，该条款在必要范围内视为无效，但不影响本协议其他条款的效力。',
                style: bodyStyle,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
