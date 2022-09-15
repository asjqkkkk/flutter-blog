class PathConfig {
  factory PathConfig() {
    return _singleton;
  }

  PathConfig._internal();

  static final PathConfig _singleton = PathConfig._internal();

  static const gameScreenPath = 'game_screens';
  static const oneLinePath = 'one_line';
  static const assets = 'assets';
  static const jsons = 'jsons';
  static const thumbnails = 'thumbnails';
  static const gameThumb = 'gameThumb';
  static const gameBackground = 'gameBackground';
  static const music = 'music';
  static const friend = 'friend';
  static const article = 'article';
  static const articleTag = 'article_tag';
  static const articleArchive = 'article_archive';
  static const articleAll = 'article_all';
  static const articleCollection = 'article_collection';
}
