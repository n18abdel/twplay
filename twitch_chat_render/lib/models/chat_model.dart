class ChatModel {
  final Streamer? streamer;
  final List<Comment>? comments;
  final Video? video;
  final dynamic emotes;

  ChatModel({
    this.streamer,
    this.comments,
    this.video,
    this.emotes,
  });

  ChatModel.fromJson(Map<String, dynamic> json)
      : streamer = (json['streamer'] as Map<String, dynamic>?) != null
            ? Streamer.fromJson(json['streamer'] as Map<String, dynamic>)
            : null,
        comments = (json['comments'] as List?)
            ?.map((dynamic e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
        video = (json['video'] as Map<String, dynamic>?) != null
            ? Video.fromJson(json['video'] as Map<String, dynamic>)
            : null,
        emotes = json['emotes'];

  Map<String, dynamic> toJson() => {
        'streamer': streamer?.toJson(),
        'comments': comments?.map((e) => e.toJson()).toList(),
        'video': video?.toJson(),
        'emotes': emotes
      };
}

class Streamer {
  final String? name;
  final int? id;

  Streamer({
    this.name,
    this.id,
  });

  Streamer.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String?,
        id = json['id'] as int?;

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}

class Comment {
  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final String? channelId;
  final String? contentType;
  final String? contentId;
  final double? contentOffsetSeconds;
  final Commenter? commenter;
  final String? source;
  final String? state;
  final Message? message;
  final bool? moreReplies;

  Comment({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.channelId,
    this.contentType,
    this.contentId,
    this.contentOffsetSeconds,
    this.commenter,
    this.source,
    this.state,
    this.message,
    this.moreReplies,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        channelId = json['channel_id'] as String?,
        contentType = json['content_type'] as String?,
        contentId = json['content_id'] as String?,
        contentOffsetSeconds = json['content_offset_seconds'] as double?,
        commenter = (json['commenter'] as Map<String, dynamic>?) != null
            ? Commenter.fromJson(json['commenter'] as Map<String, dynamic>)
            : null,
        source = json['source'] as String?,
        state = json['state'] as String?,
        message = (json['message'] as Map<String, dynamic>?) != null
            ? Message.fromJson(json['message'] as Map<String, dynamic>)
            : null,
        moreReplies = json['more_replies'] as bool?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'channel_id': channelId,
        'content_type': contentType,
        'content_id': contentId,
        'content_offset_seconds': contentOffsetSeconds,
        'commenter': commenter?.toJson(),
        'source': source,
        'state': state,
        'message': message?.toJson(),
        'more_replies': moreReplies
      };
}

class Commenter {
  final String? displayName;
  final String? id;
  final String? name;
  final String? type;
  final String? bio;
  final String? createdAt;
  final String? updatedAt;
  final String? logo;

  Commenter({
    this.displayName,
    this.id,
    this.name,
    this.type,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.logo,
  });

  Commenter.fromJson(Map<String, dynamic> json)
      : displayName = json['display_name'] as String?,
        id = json['_id'] as String?,
        name = json['name'] as String?,
        type = json['type'] as String?,
        bio = json['bio'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?,
        logo = json['logo'] as String?;

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        '_id': id,
        'name': name,
        'type': type,
        'bio': bio,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'logo': logo
      };
}

class Message {
  final String? body;
  final int? bitsSpent;
  final List<Fragments>? fragments;
  final bool? isAction;
  final dynamic userBadges;
  final String? userColor;
  final UserNoticeParams? userNoticeParams;
  final dynamic emoticons;

  Message({
    this.body,
    this.bitsSpent,
    this.fragments,
    this.isAction,
    this.userBadges,
    this.userColor,
    this.userNoticeParams,
    this.emoticons,
  });

  Message.fromJson(Map<String, dynamic> json)
      : body = json['body'] as String?,
        bitsSpent = json['bits_spent'] as int?,
        fragments = (json['fragments'] as List?)
            ?.map((dynamic e) => Fragments.fromJson(e as Map<String, dynamic>))
            .toList(),
        isAction = json['is_action'] as bool?,
        userBadges = json['user_badges'],
        userColor = json['user_color'] as String?,
        userNoticeParams =
            (json['user_notice_params'] as Map<String, dynamic>?) != null
                ? UserNoticeParams.fromJson(
                    json['user_notice_params'] as Map<String, dynamic>)
                : null,
        emoticons = json['emoticons'];

  Map<String, dynamic> toJson() => {
        'body': body,
        'bits_spent': bitsSpent,
        'fragments': fragments?.map((e) => e.toJson()).toList(),
        'is_action': isAction,
        'user_badges': userBadges,
        'user_color': userColor,
        'user_notice_params': userNoticeParams?.toJson(),
        'emoticons': emoticons
      };
}

class Fragments {
  final String? text;
  final dynamic emoticon;

  Fragments({
    this.text,
    this.emoticon,
  });

  Fragments.fromJson(Map<String, dynamic> json)
      : text = json['text'] as String?,
        emoticon = json['emoticon'];

  Map<String, dynamic> toJson() => {'text': text, 'emoticon': emoticon};
}

class UserNoticeParams {
  final dynamic msgId;

  UserNoticeParams({
    this.msgId,
  });

  UserNoticeParams.fromJson(Map<String, dynamic> json) : msgId = json['msg-id'];

  Map<String, dynamic> toJson() => {'msg-id': msgId};
}

class Video {
  final double? start;
  final double? end;

  Video({
    this.start,
    this.end,
  });

  Video.fromJson(Map<String, dynamic> json)
      : start = json['start'] as double?,
        end = json['end'] as double?;

  Map<String, dynamic> toJson() => {'start': start, 'end': end};
}
