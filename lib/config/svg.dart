export 'package:flutter_svg/flutter_svg.dart';

class Svg {
  factory Svg() {
    return _singleton;
  }

  Svg._internal();

  static final Svg _singleton = Svg._internal();

  static const START = 'assets/svgs/';
  static const END = '.svg';

  static String quote = 'quote'.svg;
  static String morning = 'afternoon'.svg;
  static String night = 'night'.svg;
  static String noon = 'noon'.svg;
  static String afternoon = 'afternoon'.svg;
  static String musicList = 'music_list'.svg;
  static String musicLast = 'music_last'.svg;
  static String musicNext = 'music_next'.svg;
  static String musicPlay = 'music_play'.svg;
  static String musicPause = 'music_pause'.svg;
  static String musicCycleList = 'music_cycle_list'.svg;
  static String musicCycleOne = 'music_cycle_one'.svg;
  static String iconGithub = 'icon_github'.svg;
  static String iconSteam = 'icon_steam'.svg;
  static String iconGMail = 'icon_gmail'.svg;
  static String iconPS = 'icon_ps'.svg;
  static String iconXBox = 'icon_xbox'.svg;
  static String iconFlutter = 'icon_flutter'.svg;
  static String random = 'random'.svg;
  static String bgXBox = 'bg_xbox'.svg;
  static String bgSteam = 'bg_steam'.svg;
  static String bgGMail = 'bg_gmail'.svg;
  static String bgGithub = 'bg_github'.svg;
  static String bgPlaystation = 'bg_playstation'.svg;
  static String articleBg = 'article_bg'.svg;
  static String home = 'home'.svg;
  static String home1 = 'home_1'.svg;
  static String home2 = 'home_2'.svg;
  static String home3 = 'home_3'.svg;
  static String home4 = 'home_4'.svg;
  static String home5 = 'home_5'.svg;
  static String home6 = 'home_6'.svg;
  static String tabHome = 'tab_home'.svg;
  static String tabArticle = 'tab_article'.svg;
  static String tabGame = 'tab_game'.svg;
  static String tabAbout = 'tab_about'.svg;
  static String tabLink = 'tab_link'.svg;
  static String tabPen = 'tab_pen'.svg;
  static String arrowUp = 'arrow_up'.svg;
  static String arrowDown = 'arrow_down'.svg;
  static String copy = 'copy'.svg;
  static String search = 'search'.svg;
  static String sort = 'sort'.svg;
  static String image = 'image'.svg;
  static String hourglass = 'hourglass'.svg;
  static String cloudFill = 'cloud-fill'.svg;
  static String location = 'location'.svg;
  static String timer = 'timer'.svg;
}

extension SvgExtensions on String {
  String get svg => fillString(this);

  String fillString(String value) {
    return Svg.START + value + Svg.END;
  }
}
