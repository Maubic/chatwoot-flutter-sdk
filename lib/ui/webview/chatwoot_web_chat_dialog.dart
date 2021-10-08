import 'package:chatwoot_client_sdk/data/local/entity/chatwoot_user.dart';
import 'package:chatwoot_client_sdk/ui/webview/utils.dart';
import 'package:chatwoot_client_sdk/ui/webview/widget_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///Chatwoot chat modal widget
/// {@category FlutterClientSdk}
class ChatwootWebChatDialog extends StatefulWidget {
  static show(BuildContext context,
      {required String baseUrl,
      required String websiteToken,
      ChatwootUser? user,
      String? locale = "fr",
      String? customAttributes}) {
    showDialog(
        context: context,
        builder: (context) {
          return ChatwootWebChatDialog(
            baseUrl: baseUrl,
            websiteToken: websiteToken,
            user: user,
            locale: locale,
            customAttributes: customAttributes,
          );
        });
  }

  ///Installation url for chatwoot
  final String baseUrl;

  ///Identifier for target chatwoot inbox.
  ///
  /// For more details see https://www.chatwoot.com/docs/product/channels/api/client-apis
  final String websiteToken;

  /// Custom user details to be attached to chatwoot contact
  final ChatwootUser? user;

  /// Custom user details to be attached to chatwoot contact
  final String? locale;

  /// Custom user details to be attached to chatwoot contact
  final dynamic customAttributes;

  const ChatwootWebChatDialog({
    Key? key,
    required this.baseUrl,
    required this.websiteToken,
    this.user,
    this.locale,
    this.customAttributes,
  }) : super(key: key);

  @override
  _ChatwootWebChatDialogState createState() => _ChatwootWebChatDialogState();
}

class _ChatwootWebChatDialogState extends State<ChatwootWebChatDialog> {
  StoreHelper helper = StoreHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: FutureBuilder<String?>(
              future: helper.getCookie(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.error != null) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return WebviewWidget(
                      baseUrl: widget.baseUrl,
                      websiteToken: widget.websiteToken,
                      cwCookie: snapshot.data,
                      user: widget.user,
                      locale: widget.locale,
                      customAttributes: widget.customAttributes,
                      storeHelper: helper,
                    );
                  }
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
