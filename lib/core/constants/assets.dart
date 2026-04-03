class Assets {
  Assets._();

  static const String _images = 'assets/images';
  static const String _logos = '$_images/logos';
  static const String _onboarding = '$_images/onboarding';
  static const String _characters = '$_images/characters';
  static const String _egg = '$_images/egg';

  // Logos
  static const String logoApple = '$_logos/applelogo.svg';
  static const String logoGoogle = '$_logos/google.svg';
  static const String logoKakao = '$_logos/kakao.svg';
  static const String logoSoopkomong = '$_logos/soopkomong_logo.svg';
  static const String appLogoAndroid = '$_logos/app_logo_and.png';
  static const String appLogoIos = '$_logos/app_logo_ios.png';

  // Onboarding
  static const String onboarding1 = '$_onboarding/01.png';
  static const String onboarding2 = '$_onboarding/02.png';
  static const String onboarding3 = '$_onboarding/03.png';

  // Characters
  static const String character000Big = '$_characters/000_big.png';
  static const String charSilhouette = '$_images/character_silhouette.png';
  static const String loginCharacter = '$_images/login_character.png';

  static String characterPortrait(String id) => '$_characters/$id.png';
  static String characterBig(String id) => '$_characters/${id}_big.png';

  // --- Character Parts ---
  static const String _parts = '$_images/parts';
  static const String storageBaseUrl = 
      'https://firebasestorage.googleapis.com/v0/b/soopkomong.firebasestorage.app/o/';
  
  static String partPath(String filename) => '$_parts/$filename';

  static String partUrl(String filename, {bool isThumbnail = false}) {
    if (isThumbnail) {
      return '${storageBaseUrl}parts%2Fthumbnails%2F$filename?alt=media';
    }
    return '${storageBaseUrl}parts%2F$filename?alt=media';
  }

  // Eggs
  static const String eggEarth = '$_egg/egg_earth.png';
  static const String eggMystery = '$_egg/egg_mystery.png';
  static const String eggFly = '$_egg/egg_fly.png';
  static const String eggTuto = '$_egg/egg_tuto.png';
  static const String eggGrass = '$_egg/egg_grass.png';
  static const String eggWater = '$_egg/egg_water.png';

  // Icons / General Images
  static const String bell = '$_images/bell.svg';
  static const String book = '$_images/book.svg';
  static const String book3dPng = '$_images/book_3_d.png';
  static const String book3dSvg = '$_images/book_3_d.svg';
  static const String calendarCheck = '$_images/calendar_check.svg';
  static const String copy = '$_images/copy.svg';
  static const String fire = '$_images/fire.svg';
  static const String flying = '$_images/flying.svg';
  static const String footprintsPng = '$_images/footprints.png';
  static const String footprintsSvg = '$_images/footprints.svg';
  static const String globeFill = '$_images/globe_fill.svg';
  static const String globeLine = '$_images/globe_line.svg';
  static const String grass = '$_images/grass.svg';
  static const String ground = '$_images/ground.svg';
  static const String hamburger = '$_images/hamburger.svg';
  static const String homeFill = '$_images/home_fill.svg';
  static const String homeLine = '$_images/home_line.svg';
  static const String info = '$_images/info.svg';
  static const String leaf = '$_images/leaf.svg';
  static const String leaf3dPng = '$_images/leaf_3_d.png';
  static const String leaf3dSvg = '$_images/leaf_3_d.svg';
  static const String mapPinArea = '$_images/map_pin_area.svg';
  static const String placeholder = '$_images/placeholder.png';
  static const String my = '$_images/my.png';
  static const String notebookFill = '$_images/notebook_fill.svg';
  static const String notebookLine = '$_images/notebook_line.svg';
  static const String park = '$_images/park.png';
  static const String pin = '$_images/pin.svg';
  static const String psychic = '$_images/psychic.svg';
  static const String scissors = '$_images/scissors.svg';
  static const String settings = '$_images/settings.svg';
  static const String smiley = '$_images/smiley.svg';
  static const String sprout = '$_images/sprout.png';
  static const String tShirt = '$_images/t_shirt.svg';
  static const String trash = '$_images/trash.svg';
  static const String user = '$_images/user.svg';
  static const String usersFill = '$_images/users_fill.svg';
  static const String usersLine = '$_images/users_line.svg';
  static const String water = '$_images/water.svg';
}
