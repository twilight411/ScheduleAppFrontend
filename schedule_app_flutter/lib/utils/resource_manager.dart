import '../models/spirit_type.dart';

/// 资源管理器 - 对应 iOS 的 ResourceManager.swift
/// 提供所有图片资源的路径字符串
class ResourceManager {
  ResourceManager._(); // 私有构造函数，防止实例化

  // MARK: - 背景图片
  static final Backgrounds backgrounds = Backgrounds._();

  // MARK: - 导航图标
  static final Navigation navigation = Navigation._();

  // MARK: - 日历界面
  static final Calendar calendar = Calendar._();

  // MARK: - 精灵图标
  static final Spirits spirits = Spirits._();

  // MARK: - AI聊天
  static final AIChat aiChat = AIChat._();

  // MARK: - 植物界面
  static final Plant plant = Plant._();

  // MARK: - 个人中心
  static final Profile profile = Profile._();

  // MARK: - 初始化/注册提问页（版本一 三选项）
  static final Onboarding onboarding = Onboarding._();

  // MARK: - 03 基本信息
  static final BasicInfo basicInfo = BasicInfo._();

  // MARK: - 04 登录注册
  static final LoginRegister loginRegister = LoginRegister._();

  /// 根据 SpiritType 获取精灵图标路径
  static String getSpiritIcon(SpiritType type) {
    return Spirits.getSpiritIcon(type);
  }
}

// MARK: - 背景图片
class Backgrounds {
  Backgrounds._(); // 私有构造函数

  /// 主背景图
  String get main => 'assets/images/backgrounds/main_background.png';

  /// 植物状态背景
  String get plantStatus => 'assets/images/backgrounds/plant_status_bg.png';

  /// 植物底部背景
  String get plantBottom => 'assets/images/backgrounds/plant_bottom_bg.png';

  /// AI聊天背景
  String get aiChat => 'assets/images/backgrounds/ai_chat_bg.png';
}

// MARK: - 导航图标
class Navigation {
  Navigation._(); // 私有构造函数

  /// 日历图标
  String get calendar => 'assets/images/navigation/icon_calendar.png';

  /// 植物图标
  String get plant => 'assets/images/navigation/icon_plant.png';

  /// 个人中心图标
  String get profile => 'assets/images/navigation/icon_profile.png';
}

// MARK: - 日历界面
class Calendar {
  Calendar._(); // 私有构造函数

  /// 愿望瓶图标
  String get wishBottle => 'assets/images/calendar/wish_bottle.png';

  /// 添加任务图标
  String get addTask => 'assets/images/calendar/add_task.png';

  /// 日视图叶子图标
  String get leafDay => 'assets/images/calendar/leaf_day.png';

  /// 周视图叶子图标
  String get leafWeek => 'assets/images/calendar/leaf_week.png';

  /// 月视图叶子图标
  String get leafMonth => 'assets/images/calendar/leaf_month.png';

  /// 选中状态叶子图标
  String get leafSelected => 'assets/images/calendar/leaf_selected.png';

  /// 三叶草背景图标
  String get leafInBack => 'assets/images/calendar/leaf_in_back.png';

  /// 完整日历图标
  String get calendarFull => 'assets/images/calendar/calendar_full.png';

  /// 小日历图标
  String get calendarSmall => 'assets/images/calendar/calendar_small.png';
}

// MARK: - 精灵图标
class Spirits {
  Spirits._(); // 私有构造函数

  /// 光精灵图标
  String get light => 'assets/images/spirits/spirit_light.png';

  /// 水精灵图标
  String get water => 'assets/images/spirits/spirit_water.png';

  /// 土壤精灵图标
  String get soil => 'assets/images/spirits/spirit_soil.png';

  /// 空气精灵图标
  String get air => 'assets/images/spirits/spirit_air.png';

  /// 营养精灵图标
  String get nutrition => 'assets/images/spirits/spirit_nutrition.png';

  /// 根据 SpiritType 获取精灵图标路径
  static String getSpiritIcon(SpiritType type) {
    switch (type) {
      case SpiritType.light:
        return 'assets/images/spirits/spirit_light.png';
      case SpiritType.water:
        return 'assets/images/spirits/spirit_water.png';
      case SpiritType.soil:
        return 'assets/images/spirits/spirit_soil.png';
      case SpiritType.air:
        return 'assets/images/spirits/spirit_air.png';
      case SpiritType.nutrition:
        return 'assets/images/spirits/spirit_nutrition.png';
    }
  }

  /// 获取精灵卡片图片路径
  /// [index] 卡片索引 (0-4)
  static String getSpiritCard(int index) {
    if (index < 0 || index > 4) {
      throw ArgumentError('Spirit card index must be between 0 and 4');
    }
    return 'assets/images/spirits/spirit_card_$index.png';
  }

  /// 根据 SpiritType 获取精灵卡片图片路径
  static String getSpiritCardByType(SpiritType type) {
    switch (type) {
      case SpiritType.light:
        return getSpiritCard(0);
      case SpiritType.water:
        return getSpiritCard(1);
      case SpiritType.soil:
        return getSpiritCard(2);
      case SpiritType.air:
        return getSpiritCard(3);
      case SpiritType.nutrition:
        return getSpiritCard(4);
    }
  }
}

// MARK: - AI聊天
class AIChat {
  AIChat._(); // 私有构造函数

  /// 群聊图标
  String get groupChat => 'assets/images/ai_chat/chat_group.png';

  /// 私聊图标
  String get privateChat => 'assets/images/ai_chat/chat_private.png';

  /// 向上箭头
  String get arrowUp => 'assets/images/ai_chat/arrow_up.png';

  /// 向下箭头
  String get arrowDown => 'assets/images/ai_chat/arrow_down.png';

  /// 输入框背景
  String get inputBoxBg => 'assets/images/ai_chat/input_box_bg.png';
}

// MARK: - 植物界面
class Plant {
  Plant._(); // 私有构造函数

  /// 植物树图片
  String get treeSample => 'assets/images/plant/tree_sample.png';

  /// 左箭头
  String get arrowLeft => 'assets/images/plant/arrow_left.png';

  /// 右箭头
  String get arrowRight => 'assets/images/plant/arrow_right.png';

  /// 分享标签
  String get shareTag => 'assets/images/plant/share_tag.png';

  /// 雷达图背景
  String get radarSample => 'assets/images/plant/radar_sample.png';

  /// 月果实图片
  String get monthFruit => 'assets/images/plant/month_fruit_sample.png';

  /// 果实架子背景
  String get shelfBackground => 'assets/images/plant/shelf_background.png';

  /// 获取果实样本图片路径
  /// [index] 果实索引 (1-5)
  static String getFruitSample(int index) {
    if (index < 1 || index > 5) {
      throw ArgumentError('Fruit sample index must be between 1 and 5');
    }
    return 'assets/images/plant/fruit_sample_$index.png';
  }
}

// MARK: - 个人中心
class Profile {
  Profile._(); // 私有构造函数

  /// 分享图标
  String get share => 'assets/images/profile/icon_share.png';

  /// 性格图标
  String get personality => 'assets/images/profile/icon_personality.png';

  /// 装饰图标
  String get decoration => 'assets/images/profile/icon_decoration.png';

  /// 小组件图标
  String get widget => 'assets/images/profile/icon_widget.png';

  /// 联系图标
  String get contact => 'assets/images/profile/icon_contact.png';

  /// 设置图标
  String get settings => 'assets/images/profile/icon_settings.png';

  /// 退出图标
  String get logout => 'assets/images/profile/icon_logout.png';

  /// 订阅项背景
  String get subscriptionItemBg => 'assets/images/profile/subscription_item_bg.png';

  /// 个人中心背景矩形
  String get backgroundRect => 'assets/images/profile/最大矩形.png';
}

// MARK: - 初始化提问页（版本一）
class Onboarding {
  Onboarding._();

  String get background => 'assets/images/onboarding/bg.png';

  /// 版本一提问页背景（含叶子和 A/B/C 字母，无需单独贴叶子和字母）
  String get backgroundWithLeavesAndLetters =>
      'assets/images/onboarding/bg_with_leaves_and_letters.png';

  String get bubbleLong => 'assets/images/onboarding/bubble_long.png';
  String get bubbleMedium => 'assets/images/onboarding/bubble_medium.png';
  String get bubbleShort => 'assets/images/onboarding/bubble_short.png';
  String get arrowLeft => 'assets/images/onboarding/arrow_left.png';
  String get arrowRight => 'assets/images/onboarding/arrow_right.png';
  String get leafLeft => 'assets/images/onboarding/leaf_left.png';
  String get leafRight => 'assets/images/onboarding/leaf_right.png';
  String get optA => 'assets/images/onboarding/opt_a.png';
  String get optB => 'assets/images/onboarding/opt_b.png';
  String get optC => 'assets/images/onboarding/opt_c.png';

  static String getSpiritIcon(String name) {
    return 'assets/images/onboarding/spirits/spirit_$name.png';
  }

  String get spiritSoil => getSpiritIcon('soil');
  String get spiritWater => getSpiritIcon('water');
  String get spiritLight => getSpiritIcon('light');
  String get spiritAir => getSpiritIcon('air');
  String get spiritNutrition => getSpiritIcon('nutrition');

  /// 版本二提问页背景（多选项气泡页）
  String get v2Background => 'assets/images/onboarding/v2_bg.png';
}

// MARK: - 03 基本信息
class BasicInfo {
  BasicInfo._();

  /// 身份页背景（浅色纹理 + 种子/草地插画）
  String get identityBackground => 'assets/images/basic_info/identity_bg.png';

  /// 昵称页 / 进入状态页 背景（与身份页同风格可共用 identity_bg，或单独放图）
  String get nicknameBackground => 'assets/images/basic_info/identity_bg.png';
  String get enterStateBackground => 'assets/images/basic_info/identity_bg.png';
}

// MARK: - 04 登录注册
class LoginRegister {
  LoginRegister._();

  /// 登录注册-手机号页背景（已含叶子和底部框）
  String get background => 'assets/images/login_register/bg.png';

  /// 登录注册-验证码页背景
  String get backgroundVerify => 'assets/images/login_register/bg(1).png';

  /// 右上角叶子装饰（已合入 background，一般无需单独使用）
  String get leaf => 'assets/images/login_register/叶子.png';

  /// 一键登录/注册 按钮背景（深橄榄绿矩形）
  String get oneClickButton => 'assets/images/login_register/一键登录_注册矩形.png';

  /// 其他手机号登录 区域
  String get otherPhone => 'assets/images/login_register/选择非默认手机号.png';

  /// 协议未勾选圆圈（白）
  String get agreementCircleWhite => 'assets/images/login_register/协议圆圈-白色.png';

  /// 知情同意勾选圆
  String get agreementCircleChecked => 'assets/images/login_register/知情同意圆.png';

  /// 登录按钮白底
  String get loginButtonWhite => 'assets/images/login_register/登录白色矩形.png';

  /// 登录按钮绿底
  String get loginButtonGreen => 'assets/images/login_register/登录绿色矩形.png';

  /// 注册底部矩形
  String get registerBottom => 'assets/images/login_register/注册底部矩形.png';
}
