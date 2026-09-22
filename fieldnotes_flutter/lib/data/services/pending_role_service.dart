import 'package:fieldnotes_client/fieldnotes_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingRoleService {
  static const _key = 'fieldnote.pending-account-role';

  Future<void> save(AccountRole role) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, role.name);
  }

  Future<AccountRole?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_key);
    if (value == null) return null;
    return AccountRole.values.where((role) => role.name == value).firstOrNull;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
