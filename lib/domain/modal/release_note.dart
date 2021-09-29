import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/atoms/buttons.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:flutter/material.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReleaseNote extends StatelessWidget {
  const ReleaseNote({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 35, right: 35),
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: PilllColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            constraints: BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.only(top: 40, left: 40, right: 40),
                        child: Text(
                          "服用履歴で\nいつ服用したかが分かる",
                          style: FontType.subTitle.merge(TextColorStyle.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '''
服用時刻やまとめて服用した日が分かるようになりました。
その他にも新機能が続々登場！
                        ''',
                        style: FontType.assisting.merge(TextColorStyle.main),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 230,
                  child: SecondaryButton(
                      onPressed: () async {
                        analytics.logEvent(name: "pressed_show_release_note");
                        Navigator.of(context).pop();
                        await openReleaseNote();
                      },
                      text: "詳細を見る"),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

showReleaseNotePreDialog(BuildContext context) async {
  final key = ReleaseNoteKey.version3_3_0;
  final storage = await SharedPreferences.getInstance();
  if (storage.getBool(key) ?? false) {
    return;
  }
  storage.setBool(key, true);

  showDialog(
      context: context,
      builder: (context) {
        return ReleaseNote();
      });
}

openReleaseNote() async {
  final ChromeSafariBrowser browser = new ChromeSafariBrowser();
  await browser.open(
      url: Uri.parse(
          "https://pilll.wraptas.site/465d5d9c8fc44077a0da481114b45367"),
      options: ChromeSafariBrowserClassOptions(
          android:
              AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
          ios: IOSSafariOptions(
              barCollapsingEnabled: true,
              presentationStyle: IOSUIModalPresentationStyle.PAGE_SHEET)));
}
