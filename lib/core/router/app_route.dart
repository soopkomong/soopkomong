enum AppRoute {
  home(name: 'home', path: '/home'),
  collection(name: 'collection', path: '/collection'),
  explore(name: 'explore', path: '/explore'),
  friends(name: 'friends', path: '/friends'),
  details(name: 'details', path: 'details'),
  mypage(name: 'mypage', path: '/mypage'),
  characterCustomize(name: 'characterCustomize', path: '/characterCustomize'),
  village(name: 'village', path: '/village'),
  friendProfile(name: 'friendProfile', path: '/friends/profile'),
  notifications(name: 'notifications', path: '/notifications'),
  profileEdit(name: 'profileEdit', path: '/profileEdit'),
  signIn(name: 'signIn', path: '/signIn'),
  onboarding(name: 'onboarding', path: '/onboarding'),
  settings(name: 'settings', path: '/settings');

  const AppRoute({required this.name, required this.path});
  final String name;
  final String path;
}
