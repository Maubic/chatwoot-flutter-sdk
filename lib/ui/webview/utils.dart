import 'dart:convert';

import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:chatwoot_client_sdk/ui/webview/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

bool isJsonString(String string) {
  try {
    jsonDecode(string) as Map<String, dynamic>;
    return true;
  } on FormatException catch (_) {
    return false;
  }
}

String createWootPostMessage(object) {
  final stringfyObject = "'$WOOT_PREFIX${jsonEncode(object)}'";
  final script = "window.postMessage($stringfyObject);";
  return script;
}

String getMessage(String data) => data.replaceAll(WOOT_PREFIX, '');

String generateScripts(
    {ChatwootUser? user, String? locale, dynamic customAttributes}) {
  String script = '''
    window.ReactNativeWebView = {};
    const postMessage = window.postMessage;
    window.postMessage = function(message, targetOrigin){
      postMessage(message, targetOrigin);
      window.flutter_inappwebview.callHandler('onMessage',message);
    };
    window.ReactNativeWebView["postMessage"] = window.postMessage;
    
  ''';

  if (user != null) {
    final userObject = {
      "event": POST_MESSAGE_EVENTS["SET_USER"],
      "identifier": user.identifier,
      "user": user.toJson()
    };
    script += createWootPostMessage(userObject);
  }

  if (locale?.isNotEmpty ?? false) {
    final localeObject = {
      "event": POST_MESSAGE_EVENTS["SET_LOCALE"],
      "locale": locale
    };
    script += createWootPostMessage(localeObject);
  }

  if (customAttributes != null) {
    final attributeObject = {
      "event": POST_MESSAGE_EVENTS["SET_CUSTOM_ATTRIBUTES"],
      "customAttributes": customAttributes
    };
    script += createWootPostMessage(attributeObject);
  }

  return script;
}

class StoreHelper {
  final _boxName = "WebviewStore";
  final key = "cwCookie";
  Box<String>? store;

  _initializeStore() async {
    if (store == null) {
      await Hive.initFlutter();
      await Hive.openBox<String>(_boxName);
      store = Hive.box<String>(_boxName);
    }
  }

  Future<String?> getCookie() async {
    await _initializeStore();
    return store!.get(key);
  }

  void setCookie(String value) async {
    await _initializeStore();
    store!.put(key, value);
  }
}
