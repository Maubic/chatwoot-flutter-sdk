import 'dart:convert';

import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/ui/webview/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

///Chatwoot chat modal widget
/// {@category FlutterClientSdk}
class WebviewWidget extends StatefulWidget {
  ///Installation url for chatwoot
  final String baseUrl;

  ///Identifier for target chatwoot inbox.
  ///
  /// For more details see https://www.chatwoot.com/docs/product/channels/api/client-apis
  final String websiteToken;

  /// Custom user details to be attached to chatwoot contact
  final ChatwootUser? user;

  /// Custom user details to be attached to chatwoot contact
  final String? cwCookie;

  /// Custom user details to be attached to chatwoot contact
  final String? locale;

  /// Custom user details to be attached to chatwoot contact
  final dynamic customAttributes;

  /// Custom user details to be attached to chatwoot contact
  final StoreHelper storeHelper;

  const WebviewWidget({
    Key? key,
    required this.baseUrl,
    required this.websiteToken,
    this.cwCookie = "",
    this.user,
    this.locale = "fr",
    this.customAttributes,
    required this.storeHelper,
  }) : super(key: key);

  @override
  _WebviewWidgetState createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget> {
  late String widgetUrl;
  late String injectedJavascript;

  @override
  void initState() {
    super.initState();

    widgetUrl =
        "${widget.baseUrl}/widget?website_token=${widget.websiteToken}&locale=en";

    print("webview widget url: $widgetUrl");
    injectedJavascript = generateScripts(
        user: widget.user,
        locale: widget.locale,
        customAttributes: widget.customAttributes);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.parse(widgetUrl),
          ),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(),
          ),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
                handlerName: "onMessage",
                callback: (args) {
                  final data = args[0];
                  print("chatwoot web widget event message: $data");
                  final message = getMessage(data);
                  if (isJsonString(message)) {
                    final parsedMessage = jsonDecode(message);
                    final eventType = parsedMessage["event"];
                    final type = parsedMessage["type"];
                    if (eventType == 'loaded') {
                      final authToken =
                          parsedMessage["config"]["authToken"] as String;
                      widget.storeHelper.setCookie(authToken);
                    }
                    if (type == 'close-widget') {
                      Navigator.pop(context);
                    }
                  }
                });
          },
          onLoadStop: (controller, uri) {
            controller.evaluateJavascript(source: injectedJavascript);
          },
          onConsoleMessage: (controller, msg) {
            print("webview console msg: $msg");
          },
        ),
        // Padding(
        //   padding: const EdgeInsets.only(right: 8.0, top: 16),
        //   child: InkWell(
        //     onTap: () => Navigator.pop(context),
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: Icon(
        //         Icons.close,
        //         color: Colors.grey,
        //       ),
        //     ),
        //   ),
        // )
      ],
    );
  }
}
