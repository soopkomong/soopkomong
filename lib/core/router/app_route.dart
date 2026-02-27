enum AppRoute {
  home(name: 'home', path: '/home'),
  collection(name: 'collection', path: '/collection'),
  explore(name: 'explore', path: '/explore'),
  friends(name: 'friends', path: '/friends'),
  details(name: 'details', path: 'details'),
  mypage(name: 'mypage', path: '/mypage'),
  signIn(name: 'signIn', path: '/signIn');

  const AppRoute({required this.name, required this.path});
  final String name;
  final String path;
}
