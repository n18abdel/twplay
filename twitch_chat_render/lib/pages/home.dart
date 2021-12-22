import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map> comments = [
      {
        "_id": "c0b60d48-c873-4bcb-8b26-cf73cbdc6326",
        "created_at": "2021-12-16T16:51:26.735Z",
        "updated_at": "2021-12-16T16:51:26.735Z",
        "channel_id": "87184624",
        "content_type": "video",
        "content_id": "1235109843",
        "content_offset_seconds": 11.035,
        "commenter": {
          "display_name": "thomas_chad",
          "_id": "455237304",
          "name": "thomas_chad",
          "type": "user",
          "bio": " ",
          "created_at": "2019-08-17T10:57:10.84617Z",
          "updated_at": "2021-11-04T09:25:09.152142Z",
          "logo":
              "https://static-cdn.jtvnw.net/jtv_user_pictures/9692fcac-5413-42fd-b1dc-fc8358390ddc-profile_image-300x300.png"
        },
        "source": "chat",
        "state": "published",
        "message": {
          "body": "yo",
          "bits_spent": 0,
          "fragments": [
            {"text": "yo", "emoticon": null}
          ],
          "is_action": false,
          "user_badges": null,
          "user_color": "#DAA520",
          "user_notice_params": {"msg-id": null},
          "emoticons": null
        },
        "more_replies": false
      },
      {
        "_id": "af899193-5a39-46f3-88da-a923ced9e059",
        "created_at": "2021-12-16T16:52:41.531Z",
        "updated_at": "2021-12-16T16:52:41.531Z",
        "channel_id": "87184624",
        "content_type": "video",
        "content_id": "1235109843",
        "content_offset_seconds": 85.831,
        "commenter": {
          "display_name": "urbainfillmore",
          "_id": "193721274",
          "name": "urbainfillmore",
          "type": "user",
          "bio": null,
          "created_at": "2018-01-29T16:07:48.364948Z",
          "updated_at": "2021-12-18T17:35:20.353115Z",
          "logo":
              "https://static-cdn.jtvnw.net/user-default-pictures-uv/cdd517fe-def4-11e9-948e-784f43822e80-profile_image-300x300.png"
        },
        "source": "chat",
        "state": "published",
        "message": {
          "body": "OUEEE HeyGuys HeyGuys",
          "bits_spent": 0,
          "fragments": [
            {"text": "OUEEE ", "emoticon": null},
            {
              "text": "HeyGuys",
              "emoticon": {"emoticon_id": "30259", "emoticon_set_id": ""}
            },
            {"text": " ", "emoticon": null},
            {
              "text": "HeyGuys",
              "emoticon": {"emoticon_id": "30259", "emoticon_set_id": ""}
            }
          ],
          "is_action": false,
          "user_badges": null,
          "user_color": "#00FF7F",
          "user_notice_params": {"msg-id": null},
          "emoticons": [
            {"_id": "30259", "begin": 6, "end": 12},
            {"_id": "30259", "begin": 14, "end": 20}
          ]
        },
        "more_replies": false
      },
      {
        "_id": "b117e48e-e01c-4c1c-9890-e9062ad113f8",
        "created_at": "2021-12-16T16:52:50.432Z",
        "updated_at": "2021-12-16T16:52:50.432Z",
        "channel_id": "87184624",
        "content_type": "video",
        "content_id": "1235109843",
        "content_offset_seconds": 94.732,
        "commenter": {
          "display_name": "Mozikaru01",
          "_id": "120500711",
          "name": "mozikaru01",
          "type": "user",
          "bio": null,
          "created_at": "2016-03-31T16:50:06.332739Z",
          "updated_at": "2021-11-21T01:13:53.046581Z",
          "logo":
              "https://static-cdn.jtvnw.net/jtv_user_pictures/ac07f8f0-e8ec-4253-96bf-e5a5243f7ca8-profile_image-300x300.png"
        },
        "source": "chat",
        "state": "published",
        "message": {
          "body": "Yo",
          "bits_spent": 0,
          "fragments": [
            {"text": "Yo", "emoticon": null}
          ],
          "is_action": false,
          "user_badges": [
            {"_id": "premium", "version": "1"}
          ],
          "user_color": "#1E90FF",
          "user_notice_params": {"msg-id": null},
          "emoticons": null
        },
        "more_replies": false
      },
      {
        "_id": "f571f93a-1acc-4735-9125-b04e537395f5",
        "created_at": "2021-12-16T16:52:52.427Z",
        "updated_at": "2021-12-16T16:52:52.427Z",
        "channel_id": "87184624",
        "content_type": "video",
        "content_id": "1235109843",
        "content_offset_seconds": 96.727,
        "commenter": {
          "display_name": "Its_me_DoVa",
          "_id": "235291527",
          "name": "its_me_dova",
          "type": "user",
          "bio": null,
          "created_at": "2018-06-30T21:40:35.664567Z",
          "updated_at": "2021-12-17T20:10:57.266969Z",
          "logo":
              "https://static-cdn.jtvnw.net/jtv_user_pictures/91da7bab-73f5-4061-b84c-b3d6de9bdbf7-profile_image-300x300.png"
        },
        "source": "chat",
        "state": "published",
        "message": {
          "body": "UI",
          "bits_spent": 0,
          "fragments": [
            {"text": "UI", "emoticon": null}
          ],
          "is_action": false,
          "user_badges": [
            {"_id": "premium", "version": "1"}
          ],
          "user_color": "#FF7F50",
          "user_notice_params": {"msg-id": null},
          "emoticons": null
        },
        "more_replies": false
      },
      {
        "_id": "f2dd26b4-a1b7-485a-bbf8-80d58b7da403",
        "created_at": "2021-12-16T16:53:16.292Z",
        "updated_at": "2021-12-16T16:53:16.292Z",
        "channel_id": "87184624",
        "content_type": "video",
        "content_id": "1235109843",
        "content_offset_seconds": 120.592,
        "commenter": {
          "display_name": "kyubi638",
          "_id": "402675152",
          "name": "kyubi638",
          "type": "user",
          "bio": null,
          "created_at": "2018-12-17T20:02:32.656734Z",
          "updated_at": "2021-12-22T14:20:34.344727Z",
          "logo":
              "https://static-cdn.jtvnw.net/jtv_user_pictures/73ac30c2-947b-4506-ac26-f243f12472ee-profile_image-300x300.png"
        },
        "source": "chat",
        "state": "published",
        "message": {
          "body": "Yo les Bg de loop",
          "bits_spent": 0,
          "fragments": [
            {"text": "Yo les Bg de loop", "emoticon": null}
          ],
          "is_action": false,
          "user_badges": [
            {"_id": "subscriber", "version": "0"}
          ],
          "user_color": "#B22222",
          "user_notice_params": {"msg-id": null},
          "emoticons": null
        },
        "more_replies": false
      }
    ];

    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: <Widget>[
            Text(
                "${comments[index % comments.length]['commenter']['display_name']}: ",
                style: TextStyle(
                    color: HexColor(comments[index % comments.length]['message']
                        ['user_color']),
                    fontWeight: FontWeight.bold)),
            Text(comments[index % comments.length]['message']['body']),
          ]),
        );
      }),
    );
  }
}
