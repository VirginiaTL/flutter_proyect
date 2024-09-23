import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  @observable
  String? token;

  @action
  void setToken(String newToken) {
    token = newToken;
  }

  @computed
  bool get isAuthenticated => token != null;
}
