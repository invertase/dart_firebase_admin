part of '../messaging.dart';

abstract class _BaseMessage {
  _BaseMessage._({
    this.data,
    this.notification,
    this.android,
    this.webpush,
    this.apns,
    this.fcmOptions,
  });

  final Map<String, String>? data;
  final Notification? notification;
  final AndroidConfig? android;
  final WebpushConfig? webpush;
  final ApnsConfig? apns;
  final FcmOptions? fcmOptions;
}

/// Payload for the [Messaging.send] operation. The payload contains all the fields
/// in the BaseMessage type, and exactly one of token, topic or condition.
///
/// See also:
/// - [Messaging.send], to send a message.
/// - [TopicMessage], to send a message to a topic.
/// - [ConditionMessage], to send a message to a condition.
/// - [TokenMessage], to send a message to a device.
sealed class Message extends _BaseMessage {
  Message._({
    super.data,
    super.notification,
    super.android,
    super.webpush,
    super.apns,
    super.fcmOptions,
  }) : super._();

  fmc1.Message _toProto();
}

/// A message targeting a specific registration token.
///
/// See [Send to individual devices](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-specific-devices)
class TokenMessage extends Message {
  TokenMessage({
    required this.token,
    super.data,
    super.notification,
    super.android,
    super.webpush,
    super.apns,
    super.fcmOptions,
  }) : super._();

  final String token;

  @override
  fmc1.Message _toProto() {
    return fmc1.Message(
      data: data,
      notification: notification?._toProto(),
      android: android?._toProto(),
      webpush: webpush?._toProto(),
      apns: apns?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
      token: token,
    );
  }
}

/// A message targeting a topic.
///
/// See [Send to a topic](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-topics)
class TopicMessage extends Message {
  TopicMessage({
    required this.topic,
    super.data,
    super.notification,
    super.android,
    super.webpush,
    super.apns,
    super.fcmOptions,
  }) : super._();

  final String topic;

  @override
  fmc1.Message _toProto() {
    return fmc1.Message(
      data: data,
      notification: notification?._toProto(),
      android: android?._toProto(),
      webpush: webpush?._toProto(),
      apns: apns?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
      topic: topic,
    );
  }
}

/// A message targeting a condition.
///
/// See [Send messages to topics](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-topics).
class ConditionMessage extends Message {
  ConditionMessage({
    required this.condition,
    super.data,
    super.notification,
    super.android,
    super.webpush,
    super.apns,
    super.fcmOptions,
  }) : super._();

  final String condition;

  @override
  fmc1.Message _toProto() {
    return fmc1.Message(
      data: data,
      notification: notification?._toProto(),
      android: android?._toProto(),
      webpush: webpush?._toProto(),
      apns: apns?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
      condition: condition,
    );
  }
}

/// Payload for the [Messaging.sendEachForMulticast] method. The payload contains all the fields
/// in the BaseMessage type, and a list of tokens.
class MulticastMessage extends _BaseMessage {
  MulticastMessage({
    super.data,
    super.notification,
    super.android,
    super.webpush,
    super.apns,
    super.fcmOptions,
    required this.tokens,
  }) : super._();

  final List<String> tokens;
}

/// A notification that can be included in [Message].
class Notification {
  /// A notification that can be included in [Message].
  Notification({
    this.title,
    this.body,
    this.imageUrl,
  });

  /// The title of the notification.
  final String? title;

  /// The notification body
  final String? body;

  /// URL of an image to be displayed in the notification.
  final String? imageUrl;

  fmc1.Notification _toProto() {
    return fmc1.Notification(
      title: title,
      body: body,
      image: imageUrl,
    );
  }
}

/// Represents platform-independent options for features provided by the FCM SDKs.
class FcmOptions {
  /// Represents platform-independent options for features provided by the FCM SDKs.
  FcmOptions({this.analyticsLabel});

  /// The label associated with the message's analytics data.
  final String? analyticsLabel;

  fmc1.FcmOptions _toProto() {
    return fmc1.FcmOptions(analyticsLabel: analyticsLabel);
  }
}

/// Represents the WebPush protocol options that can be included in a [Message].
class WebpushConfig {
  /// Represents the WebPush protocol options that can be included in a [Message].
  WebpushConfig({
    this.headers,
    this.data,
    this.notification,
    this.fcmOptions,
  });

  /// A collection of WebPush headers. Header values must be strings.
  ///
  /// See [WebPush specification](https://tools.ietf.org/html/rfc8030#section-5)
  /// for supported headers.
  final Map<String, String>? headers;

  /// A collection of data fields.
  final Map<String, String>? data;

  /// A WebPush notification payload to be included in the message.
  final WebpushNotification? notification;

  /// Options for features provided by the FCM SDK for Web.
  final WebpushFcmOptions? fcmOptions;

  fmc1.WebpushConfig _toProto() {
    return fmc1.WebpushConfig(
      headers: headers,
      data: data,
      notification: notification?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
    );
  }
}

/// Represents options for features provided by the FCM SDK for Web
/// (which are not part of the Webpush standard).
class WebpushFcmOptions {
  /// Represents options for features provided by the FCM SDK for Web
  /// (which are not part of the Webpush standard).
  WebpushFcmOptions({this.link});

  /// The link to open when the user clicks on the notification.
  /// For all URL values, HTTPS is required.
  final String? link;

  fmc1.WebpushFcmOptions _toProto() {
    return fmc1.WebpushFcmOptions(link: link);
  }
}

class WebpushNotificationAction {
  WebpushNotificationAction({
    required this.action,
    this.icon,
    required this.title,
  });

  /// An action available to the user when the notification is presented
  final String action;

  /// Optional icon for a notification action.
  final String? icon;

  /// Title of the notification action.
  final String title;

  Map<String, Object?> _toProto() {
    return {
      'action': action,
      'icon': icon,
      'title': title,
    }._cleanProto();
  }
}

extension on Map<String, Object?> {
  Map<String, Object?> _cleanProto() {
    for (final entry in entries) {
      switch (entry.value) {
        case true:
          this[entry.key] = 1;
        case false:
          this[entry.key] = 0;
      }
    }

    return this;
  }
}

enum WebpushNotificationDirection {
  auto,
  ltr,
  rtl,
}

/// Represents the WebPush-specific notification options that can be included in
/// [WebpushConfig]. This supports most of the standard
/// options as defined in the Web Notification
/// [specification](https://developer.mozilla.org/en-US/docs/Web/API/notification/Notification).
class WebpushNotification {
  WebpushNotification({
    this.title,
    this.customData,
    this.actions,
    this.badge,
    this.body,
    this.data,
    this.dir,
    this.icon,
    this.image,
    this.lang,
    this.renotify,
    this.requireInteraction,
    this.silent,
    this.tag,
    this.timestamp,
    this.vibrate,
  });

  /// Title text of the notification.
  final String? title;

  /// A list of notification actions representing the actions
  /// available to the user when the notification is presented.
  final List<WebpushNotificationAction>? actions;

  /// URL of the image used to represent the notification when there is
  /// not enough space to display the notification itself.
  final String? badge;

  /// Body text of the notification.
  final String? body;

  /// Arbitrary data that you want associated with the notification.
  /// This can be of any data type.
  final Object? data;

  /// The direction in which to display the notification. Must be one
  /// of `auto`, `ltr` or `rtl`.
  final WebpushNotificationDirection? dir;

  /// URL to the notification icon.
  final String? icon;

  /// URL of an image to be displayed in the notification.
  final String? image;

  /// The notification's language as a BCP 47 language tag.
  final String? lang;

  /// A boolean specifying whether the user should be notified after a
  /// new notification replaces an old one. Defaults to false.
  final bool? renotify;

  /// Indicates that a notification should remain active until the user
  /// clicks or dismisses it, rather than closing automatically.
  /// Defaults to false.
  final bool? requireInteraction;

  /// A boolean specifying whether the notification should be silent.
  /// Defaults to false.
  final bool? silent;

  /// An identifying tag for the notification.
  final String? tag;

  /// Timestamp of the notification. Refer to
  /// https://developer.mozilla.org/en-US/docs/Web/API/notification/timestamp
  /// for details.
  final int? timestamp;

  /// A vibration pattern for the device's vibration hardware to emit
  /// when the notification fires.
  final List<num>? vibrate;

  /// Arbitrary key/value payload.
  final Map<String, Object?>? customData;

  Map<String, Object?> _toProto() {
    return {
      'title': title,
      'actions': actions?.map((a) => a._toProto()).toList(),
      'badge': badge,
      'body': body,
      'data': data,
      'dir': dir?.toString().split('.').last,
      'icon': icon,
      'image': image,
      'lang': lang,
      'renotify': renotify,
      'requireInteraction': requireInteraction,
      'silent': silent,
      'tag': tag,
      'timestamp': timestamp,
      'vibrate': vibrate,
      if (customData case final customData?) ...customData,
    }._cleanProto();
  }
}

/// Represents the APNs-specific options that can be included in an
/// [Message]. Refer to
/// [Apple documentation](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html)
/// for various headers and payload fields supported by APNs.
class ApnsConfig {
  /// Represents the APNs-specific options that can be included in an
  /// [Message]. Refer to
  /// [Apple documentation](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html)
  /// for various headers and payload fields supported by APNs.
  ApnsConfig({
    this.headers,
    this.payload,
    this.fcmOptions,
  });

  /// A collection of APNs headers. Header values must be strings.
  final Map<String, String>? headers;

  /// An APNs payload to be included in the message.
  final ApnsPayload? payload;

  /// Options for features provided by the FCM SDK for iOS.
  final ApnsFcmOptions? fcmOptions;

  fmc1.ApnsConfig _toProto() {
    return fmc1.ApnsConfig(
      headers: headers,
      payload: payload?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
    );
  }
}

/// Represents the payload of an APNs message. Mainly consists of the `aps`
/// dictionary.
class ApnsPayload {
  /// Represents the payload of an APNs message. Mainly consists of the `aps`
  /// dictionary.
  ApnsPayload({required this.aps, this.customData});

  /// The `aps` dictionary to be included in the message.
  final Aps aps;

  /// Arbitrary custom data.
  final Map<String, String>? customData;

  Map<String, Object?> _toProto() {
    return {
      'aps': aps._toProto(),
      if (customData case final customData?) ...customData,
    }._cleanProto();
  }
}

/// Represents the [aps dictionary](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
/// that is part of APNs messages.
class Aps {
  Aps({
    this.alert,
    this.badge,
    this.sound,
    this.contentAvailable,
    this.mutableContent,
    this.category,
    this.threadId,
  });

  /// Alert to be included in the message. This may be a string or an object of
  /// type `admin.messaging.ApsAlert`.
  final ApsAlert? alert;

  /// Badge to be displayed with the message. Set to 0 to remove the badge. When
  /// not specified, the badge will remain unchanged.
  final num? badge;

  /// Sound to be played with the message.
  final CriticalSound? sound;

  /// Specifies whether to configure a background update notification.
  final bool? contentAvailable;

  /// Specifies whether to set the `mutable-content` property on the message
  /// so the clients can modify the notification via app extensions.
  final bool? mutableContent;

  /// Type of the notification.
  final String? category;

  /// An app-specific identifier for grouping notifications.
  final String? threadId;

  Map<String, Object?> _toProto() {
    return {
      'alert': alert?._toProto(),
      'badge': badge,
      'sound': sound?._toProto(),
      'content-available': contentAvailable,
      'mutable-content': mutableContent,
      'category': category,
      'thread-id': threadId,
    }._cleanProto();
  }
}

class ApsAlert {
  ApsAlert({
    this.title,
    this.subtitle,
    this.body,
    this.locKey,
    this.locArgs,
    this.titleLocKey,
    this.titleLocArgs,
    this.subtitleLocKey,
    this.subtitleLocArgs,
    this.actionLocKey,
    this.launchImage,
  });

  final String? title;
  final String? subtitle;
  final String? body;
  final String? locKey;
  final List<String>? locArgs;
  final String? titleLocKey;
  final List<String>? titleLocArgs;
  final String? subtitleLocKey;
  final List<String>? subtitleLocArgs;
  final String? actionLocKey;
  final String? launchImage;

  Map<String, Object?> _toProto() {
    return {
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'loc-key': locKey,
      'loc-args': locArgs,
      'title-loc-key': titleLocKey,
      'title-loc-args': titleLocArgs,
      'subtitle-loc-key': subtitleLocKey,
      'subtitle-loc-args': subtitleLocArgs,
      'action-loc-key': actionLocKey,
      'launch-image': launchImage,
    }._cleanProto();
  }
}

/// Represents a critical sound configuration that can be included in the
/// `aps` dictionary of an APNs payload.
class CriticalSound {
  CriticalSound({this.critical, required this.name, this.volume});

  /// The critical alert flag. Set to `true` to enable the critical alert.
  final bool? critical;

  /// The name of a sound file in the app's main bundle or in the `Library/Sounds`
  /// folder of the app's container directory. Specify the string "default" to play
  /// the system sound.
  final String name;

  /// The volume for the critical alert's sound. Must be a value between 0.0
  /// (silent) and 1.0 (full volume).
  final double? volume;

  Map<String, Object?> _toProto() {
    return {
      'critical': critical,
      'name': name,
      'volume': volume,
    }._cleanProto();
  }
}

/// Represents options for features provided by the FCM SDK for iOS.
class ApnsFcmOptions {
  /// Represents options for features provided by the FCM SDK for iOS.
  ApnsFcmOptions({this.analyticsLabel, this.imageUrl});

  /// The label associated with the message's analytics data.
  final String? analyticsLabel;

  /// URL of an image to be displayed in the notification.
  final String? imageUrl;

  fmc1.ApnsFcmOptions _toProto() {
    return fmc1.ApnsFcmOptions(
      analyticsLabel: analyticsLabel,
      image: imageUrl,
    );
  }
}

enum AndroidConfigPriority {
  high,
  normal,
}

/// Represents the Android-specific options that can be included in an [Message].
class AndroidConfig {
  /// Represents the Android-specific options that can be included in an [Message].
  AndroidConfig({
    this.collapseKey,
    this.priority,
    this.ttl,
    this.restrictedPackageName,
    this.data,
    this.notification,
    this.fcmOptions,
  });

  /// Collapse key for the message. Collapse key serves as an identifier for a
  /// group of messages that can be collapsed, so that only the last message gets
  /// sent when delivery can be resumed. A maximum of four different collapse keys
  /// may be active at any given time.
  final String? collapseKey;

  /// Priority of the message. Must be either `normal` or `high`.
  final AndroidConfigPriority? priority;

  /// How long (in seconds) the message should be kept in FCM storage if the
  /// device is offline.
  ///
  /// The maximum time to live supported is 4 weeks, and the default value is 4
  /// weeks if not set. Set it to 0 if want to send the message immediately. In
  /// JSON format, the Duration type is encoded as a string rather than an
  /// object, where the string ends in the suffix "s" (indicating seconds) and
  /// is preceded by the number of seconds, with nanoseconds expressed as
  /// fractional seconds. For example, 3 seconds with 0 nanoseconds should be
  /// encoded in JSON format as "3s", while 3 seconds and 1 nanosecond should be
  /// expressed in JSON format as "3.000000001s". The ttl will be rounded down
  /// to the nearest second.
  final String? ttl;

  /// Package name of the application where the registration tokens must match
  /// in order to receive the message.
  final String? restrictedPackageName;

  /// A collection of data fields to be included in the message. All values must
  /// be strings. When provided, overrides any data fields set on the top-level
  /// [Message].
  final Map<String, String>? data;

  /// Android notification to be included in the message.
  final AndroidNotification? notification;

  /// Options for features provided by the FCM SDK for Android.
  final AndroidFcmOptions? fcmOptions;

  fmc1.AndroidConfig _toProto() {
    return fmc1.AndroidConfig(
      collapseKey: collapseKey,
      priority: priority?.toString().split('.').last,
      ttl: ttl,
      restrictedPackageName: restrictedPackageName,
      data: data,
      notification: notification?._toProto(),
      fcmOptions: fcmOptions?._toProto(),
    );
  }
}

enum AndroidNotificationPriority {
  min('PRIORITY_MIN'),
  low('PRIORITY_LOW'),
  $default('PRIORITY_DEFAULT'),
  high('PRIORITY_HIGH'),
  max('PRIORITY_MAX');

  const AndroidNotificationPriority(this._code);

  final String _code;
}

enum AndroidNotificationVisibility {
  private,
  public,
  secret,
}

/// Represents the Android-specific notification options that can be included in
/// [AndroidConfig].
class AndroidNotification {
  /// Represents the Android-specific notification options that can be included in
  /// [AndroidConfig].
  AndroidNotification({
    this.title,
    this.body,
    this.icon,
    this.color,
    this.sound,
    this.tag,
    this.imageUrl,
    this.clickAction,
    this.bodyLocKey,
    this.bodyLocArgs,
    this.titleLocKey,
    this.titleLocArgs,
    this.channelId,
    this.ticker,
    this.sticky,
    this.eventTimestamp,
    this.localOnly,
    this.priority,
    this.vibrateTimingsMillis,
    this.defaultVibrateTimings,
    this.defaultSound,
    this.lightSettings,
    this.defaultLightSettings,
    this.visibility,
    this.notificationCount,
  });

  /// Title of the Android notification. When provided, overrides the title set via
  /// `admin.messaging.Notification`.
  final String? title;

  /// Body of the Android notification. When provided, overrides the body set via
  /// `admin.messaging.Notification`.
  final String? body;

  /// Icon resource for the Android notification.
  final String? icon;

  /// Notification icon color in `#rrggbb` format.
  final String? color;

  /// File name of the sound to be played when the device receives the
  /// notification.
  final String? sound;

  /// Notification tag. This is an identifier used to replace existing
  /// notifications in the notification drawer. If not specified, each request
  /// creates a new notification.
  final String? tag;

  /// URL of an image to be displayed in the notification.
  final String? imageUrl;

  /// Action associated with a user click on the notification. If specified, an
  /// activity with a matching Intent Filter is launched when a user clicks on the
  /// notification.
  final String? clickAction;

  /// Key of the body string in the app's string resource to use to localize the
  /// body text.
  ///
  final String? bodyLocKey;

  /// An array of resource keys that will be used in place of the format
  /// specifiers in `bodyLocKey`.
  final List<String>? bodyLocArgs;

  /// Key of the title string in the app's string resource to use to localize the
  /// title text.
  final String? titleLocKey;

  /// An array of resource keys that will be used in place of the format
  /// specifiers in `titleLocKey`.
  final List<String>? titleLocArgs;

  /// The Android notification channel ID (new in Android O). The app must create
  /// a channel with this channel ID before any notification with this channel ID
  /// can be received. If you don't send this channel ID in the request, or if the
  /// channel ID provided has not yet been created by the app, FCM uses the channel
  /// ID specified in the app manifest.
  final String? channelId;

  /// Sets the "ticker" text, which is sent to accessibility services. Prior to
  /// API level 21 (Lollipop), sets the text that is displayed in the status bar
  /// when the notification first arrives.
  final String? ticker;

  /// When set to `false` or unset, the notification is automatically dismissed when
  /// the user clicks it in the panel. When set to `true`, the notification persists
  /// even when the user clicks it.
  final bool? sticky;

  /// For notifications that inform users about events with an absolute time reference, sets
  /// the time that the event in the notification occurred. Notifications
  /// in the panel are sorted by this time.
  final DateTime? eventTimestamp;

  /// Sets whether or not this notification is relevant only to the current device.
  /// Some notifications can be bridged to other devices for remote display, such as
  /// a Wear OS watch. This hint can be set to recommend this notification not be bridged.
  /// See [Wear OS guides](https://developer.android.com/training/wearables/notifications/bridger#existing-method-of-preventing-bridging).
  final bool? localOnly;

  /// Sets the relative priority for this notification. Low-priority notifications
  /// may be hidden from the user in certain situations. Note this priority differs
  /// from `AndroidMessagePriority`. This priority is processed by the client after
  /// the message has been delivered. Whereas `AndroidMessagePriority` is an FCM concept
  /// that controls when the message is delivered.
  final AndroidNotificationPriority? priority;

  /// Sets the vibration pattern to use. Pass in an array of milliseconds to
  /// turn the vibrator on or off. The first value indicates the duration to wait before
  /// turning the vibrator on. The next value indicates the duration to keep the
  /// vibrator on. Subsequent values alternate between duration to turn the vibrator
  /// off and to turn the vibrator on. If `vibrate_timings` is set and `default_vibrate_timings`
  /// is set to `true`, the default value is used instead of the user-specified `vibrate_timings`.
  final List<String>? vibrateTimingsMillis;

  /// If set to `true`, use the Android framework's default vibrate pattern for the
  /// notification. Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).
  /// If `default_vibrate_timings` is set to `true` and `vibrate_timings` is also set,
  /// the default value is used instead of the user-specified `vibrate_timings`.
  final bool? defaultVibrateTimings;

  /// If set to `true`, use the Android framework's default sound for the notification.
  /// Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).
  final bool? defaultSound;

  /// Settings to control the notification's LED blinking rate and color if LED is
  /// available on the device. The total blinking time is controlled by the OS.
  final LightSettings? lightSettings;

  /// If set to `true`, use the Android framework's default LED light settings
  /// for the notification. Default values are specified in [`config.xml`](https://android.googlesource.com/platform/frameworks/base/+/master/core/res/res/values/config.xml).
  /// If `default_light_settings` is set to `true` and `light_settings` is also set,
  /// the user-specified `light_settings` is used instead of the default value.
  final bool? defaultLightSettings;

  /// Sets the visibility of the notification. Must be either `private`, `public`,
  /// or `secret`. If unspecified, defaults to `private`.
  final AndroidNotificationVisibility? visibility;

  /// Sets the number of items this notification represents. May be displayed as a
  /// badge count for Launchers that support badging. See [NotificationBadge](https://developer.android.com/training/notify-user/badges).
  /// For example, this might be useful if you're using just one notification to
  /// represent multiple new messages but you want the count here to represent
  /// the number of total new messages. If zero or unspecified, systems
  /// that support badging use the default, which is to increment a number
  /// displayed on the long-press menu each time a new notification arrives.
  final int? notificationCount;

  fmc1.AndroidNotification _toProto() {
    return fmc1.AndroidNotification(
      title: title,
      body: body,
      icon: icon,
      color: color,
      sound: sound,
      tag: tag,
      image: imageUrl,
      clickAction: clickAction,
      bodyLocKey: bodyLocKey,
      bodyLocArgs: bodyLocArgs,
      titleLocKey: titleLocKey,
      titleLocArgs: titleLocArgs,
      channelId: channelId,
      ticker: ticker,
      sticky: sticky,
      eventTime: eventTimestamp?.toUtc().toIso8601String(),
      localOnly: localOnly,
      notificationPriority: priority?._code,
      vibrateTimings: vibrateTimingsMillis,
      defaultVibrateTimings: defaultVibrateTimings,
      defaultSound: defaultSound,
      lightSettings: lightSettings?._toProto(),
      defaultLightSettings: defaultLightSettings,
      visibility: visibility?.toString().split('.').last,
      notificationCount: notificationCount,
    );
  }
}

/// Represents settings to control notification LED that can be included in [AndroidNotification].
class LightSettings {
  /// Represents settings to control notification LED that can be included in [AndroidNotification].
  LightSettings({
    required this.color,
    required this.lightOnDurationMillis,
    required this.lightOffDurationMillis,
  });

  /// Required. Sets color of the LED in `#rrggbb` or `#rrggbbaa` format.
  final ({double? red, double? blue, double? green, double? alpha}) color;

  /// Required. Along with `light_off_duration`, defines the blink rate of LED flashes.
  final String lightOnDurationMillis;

  /// Required. Along with `light_on_duration`, defines the blink rate of LED flashes.
  final String lightOffDurationMillis;

  fmc1.LightSettings _toProto() {
    return fmc1.LightSettings(
      color: fmc1.Color(
        red: color.red,
        green: color.green,
        blue: color.blue,
        alpha: color.alpha,
      ),
      lightOnDuration: lightOnDurationMillis,
      lightOffDuration: lightOffDurationMillis,
    );
  }
}

/// Represents options for features provided by the FCM SDK for Android.
class AndroidFcmOptions {
  /// Represents options for features provided by the FCM SDK for Android.
  AndroidFcmOptions({this.analyticsLabel});

  /// The label associated with the message's analytics data.
  final String? analyticsLabel;

  fmc1.AndroidFcmOptions _toProto() {
    return fmc1.AndroidFcmOptions(analyticsLabel: analyticsLabel);
  }
}

/// Interface representing an FCM legacy API notification message payload.
/// Notification messages let developers send up to 4KB of predefined
/// key-value pairs. Accepted keys are outlined below.
///
/// See {@link https://firebase.google.com/docs/cloud-messaging/send-message | Build send requests}
/// for code samples and detailed documentation.
class NotificationMessagePayload {
  NotificationMessagePayload({
    this.tag,
    this.body,
    this.icon,
    this.badge,
    this.color,
    this.sound,
    this.title,
    this.bodyLocKey,
    this.bodyLocArgs,
    this.clickAction,
    this.titleLocKey,
    this.titleLocArgs,
  });

  /// Identifier used to replace existing notifications in the notification drawer.
  ///
  /// If not specified, each request creates a new notification.
  ///
  /// If specified and a notification with the same tag is already being shown,
  /// the new notification replaces the existing one in the notification drawer.
  ///
  /// **Platforms:** Android
  final String? tag;

  /// The notification's body text.
  ///
  /// **Platforms:** iOS, Android, Web
  final String? body;

  /// The notification's icon.
  ///
  /// **Android:** Sets the notification icon to `myicon` for drawable resource
  /// `myicon`. If you don't send this key in the request, FCM displays the
  /// launcher icon specified in your app manifest.
  ///
  /// **Web:** The URL to use for the notification's icon.
  ///
  /// **Platforms:** Android, Web
  final String? icon;

  /// The value of the badge on the home screen app icon.
  ///
  /// If not specified, the badge is not changed.
  ///
  /// If set to `0`, the badge is removed.
  ///
  /// **Platforms:** iOS
  final String? badge;

  /// The notification icon's color, expressed in `#rrggbb` format.
  ///
  /// **Platforms:** Android
  final String? color;

  /// The sound to be played when the device receives a notification. Supports
  /// "default" for the default notification sound of the device or the filename of a
  /// sound resource bundled in the app.
  /// Sound files must reside in `/res/raw/`.
  ///
  /// **Platforms:** Android
  final String? sound;

  /// The notification's title.
  ///
  /// **Platforms:** iOS, Android, Web
  final String? title;

  /// The key to the body string in the app's string resources to use to localize
  /// the body text to the user's current localization.
  ///
  /// **iOS:** Corresponds to `loc-key` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.
  ///
  /// **Android:** See
  /// [String Resources](http://developer.android.com/guide/topics/resources/string-resource.html)
  /// for more information.
  ///
  /// **Platforms:** iOS, Android
  final String? bodyLocKey;

  /// Variable string values to be used in place of the format specifiers in
  /// `body_loc_key` to use to localize the body text to the user's current
  /// localization.
  ///
  /// The value should be a stringified JSON array.
  ///
  /// **iOS:** Corresponds to `loc-args` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.
  ///
  /// **Android:** See
  /// [Formatting and Styling](http://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling)
  /// for more information.
  ///
  /// **Platforms:** iOS, Android
  final String? bodyLocArgs;

  /// Action associated with a user click on the notification. If specified, an
  /// activity with a matching Intent Filter is launched when a user clicks on the
  /// notification.
  ///
  ///   * **Platforms:** Android
  final String? clickAction;

  /// The key to the title string in the app's string resources to use to localize
  /// the title text to the user's current localization.
  ///
  /// **iOS:** Corresponds to `title-loc-key` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.
  ///
  /// **Android:** See
  /// [String Resources](http://developer.android.com/guide/topics/resources/string-resource.html)
  /// for more information.
  ///
  /// **Platforms:** iOS, Android
  final String? titleLocKey;

  /// Variable string values to be used in place of the format specifiers in
  /// `title_loc_key` to use to localize the title text to the user's current
  /// localization.
  ///
  /// The value should be a stringified JSON array.
  ///
  /// **iOS:** Corresponds to `title-loc-args` in the APNs payload. See
  /// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
  /// and
  /// [Localizing the Content of Your Remote Notifications](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
  /// for more information.
  ///
  /// **Android:** See
  /// [Formatting and Styling](http://developer.android.com/guide/topics/resources/string-resource.html#FormattingAndStyling)
  /// for more information.
  ///
  /// **Platforms:** iOS, Android
  final String? titleLocArgs;
}

// Keys which are not allowed in the messaging data payload object.
const _blacklistedDataPayloadKeys = {'from'};

/// Interface representing a Firebase Cloud Messaging message payload. One or
/// both of the `data` and `notification` keys are required.
///
/// See [Build send requests](https://firebase.google.com/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.
class MessagingPayload {
  MessagingPayload({this.data, this.notification}) {
    if (data == null && notification == null) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidPayload,
        'Messaging payload must contain at least one of the "data" or "notification" properties.',
      );
    }

    if (data != null) {
      for (final key in data!.keys) {
        if (_blacklistedDataPayloadKeys.contains(key) ||
            key.startsWith('google.')) {
          throw FirebaseMessagingAdminException(
            MessagingClientErrorCode.invalidPayload,
            'Messaging payload contains the blacklisted "data.$key" property.',
          );
        }
      }
    }
  }

  /// The data message payload.
  ///
  /// Data
  /// messages let developers send up to 4KB of custom key-value pairs. The
  /// keys and values must both be strings. Keys can be any custom string,
  /// except for the following reserved strings:
  ///
  /// <ul>
  ///   <li><code>from</code></li>
  ///   <li>Anything starting with <code>google.</code></li>
  /// </ul>
  ///
  /// See [Build send requests](https://firebase.google.com/docs/cloud-messaging/send-message)
  /// for code samples and detailed documentation.
  final Map<String, String>? data;

  /// The notification message payload.
  final NotificationMessagePayload? notification;
}

class MessagingDevicesResponse {
  @internal
  MessagingDevicesResponse({
    required this.canonicalRegistrationTokenCount,
    required this.failureCount,
    required this.multicastId,
    required this.results,
    required this.successCount,
  });

  final int canonicalRegistrationTokenCount;
  final int failureCount;
  final int multicastId;
  final List<MessagingDeviceResult> results;
  final int successCount;
}

class MessagingDeviceResult {
  @internal
  MessagingDeviceResult({
    required this.error,
    required this.messageId,
    required this.canonicalRegistrationToken,
  });

  /// The error that occurred when processing the message for the recipient.
  final FirebaseAdminException? error;

  /// A unique ID for the successfully processed message.
  final String? messageId;

  /// The canonical registration token for the client app that the message was
  /// processed and sent to. You should use this value as the registration token
  /// for future requests. Otherwise, future messages might be rejected.
  final String? canonicalRegistrationToken;
}

/// Interface representing the options that can be provided when sending a
/// message via the FCM legacy APIs.
///
/// See [Build send requests](https://firebase.google.com/docs/cloud-messaging/send-message)
/// for code samples and detailed documentation.
class MessagingOptions {
  /// Interface representing the options that can be provided when sending a
  /// message via the FCM legacy APIs.
  ///
  /// See [Build send requests](https://firebase.google.com/docs/cloud-messaging/send-message)
  /// for code samples and detailed documentation.
  MessagingOptions({
    this.dryRun,
    this.priority,
    this.timeToLive,
    this.collapseKey,
    this.mutableContent,
    this.contentAvailable,
    this.restrictedPackageName,
  }) {
    final collapseKey = this.collapseKey;
    if (collapseKey != null && collapseKey.isEmpty) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidOptions,
        'Messaging options contains an invalid value for the "$collapseKey" property. Value must '
        'be a boolean.',
      );
    }

    final priority = this.priority;
    if (priority != null && priority.isEmpty) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidOptions,
        'Messaging options contains an invalid value for the "priority" property. Value must '
        'be a non-empty string.',
      );
    }

    final restrictedPackageName = this.restrictedPackageName;
    if (restrictedPackageName != null && restrictedPackageName.isEmpty) {
      throw FirebaseMessagingAdminException(
        MessagingClientErrorCode.invalidOptions,
        'Messaging options contains an invalid value for the "restrictedPackageName" property. '
        'Value must be a non-empty string.',
      );
    }
  }

  /// Whether or not the message should actually be sent. When set to `true`,
  /// allows developers to test a request without actually sending a message. When
  /// set to `false`, the message will be sent.
  ///
  /// **Default value:** `false`
  final bool? dryRun;

  /// The priority of the message. Valid values are `"normal"` and `"high".` On
  /// iOS, these correspond to APNs priorities `5` and `10`.
  ///
  /// By default, notification messages are sent with high priority, and data
  /// messages are sent with normal priority. Normal priority optimizes the client
  /// app's battery consumption and should be used unless immediate delivery is
  /// required. For messages with normal priority, the app may receive the message
  /// with unspecified delay.
  ///
  /// When a message is sent with high priority, it is sent immediately, and the
  /// app can wake a sleeping device and open a network connection to your server.
  ///
  /// For more information, see
  /// [Setting the priority of a message](https://firebase.google.com/docs/cloud-messaging/concept-options#setting-the-priority-of-a-message).
  ///
  /// **Default value:** `"high"` for notification messages, `"normal"` for data
  /// messages
  final String? priority;

  /// How long (in seconds) the message should be kept in FCM storage if the device
  /// is offline. The maximum time to live supported is four weeks, and the default
  /// value is also four weeks. For more information, see
  /// [Setting the lifespan of a message](https://firebase.google.com/docs/cloud-messaging/concept-options#ttl).
  ///
  /// **Default value:** `2419200` (representing four weeks, in seconds)
  final int? timeToLive;

  /// String identifying a group of messages (for example, "Updates Available")
  /// that can be collapsed, so that only the last message gets sent when delivery
  /// can be resumed. This is used to avoid sending too many of the same messages
  /// when the device comes back online or becomes active.
  ///
  /// There is no guarantee of the order in which messages get sent.
  ///
  /// A maximum of four different collapse keys is allowed at any given time. This
  /// means FCM server can simultaneously store four different
  /// send-to-sync messages per client app. If you exceed this number, there is no
  /// guarantee which four collapse keys the FCM server will keep.
  ///
  /// **Default value:** None
  final String? collapseKey;

  /// On iOS, use this field to represent `mutable-content` in the APNs payload.
  /// When a notification is sent and this is set to `true`, the content of the
  /// notification can be modified before it is displayed, using a
  /// [Notification Service app extension](https://developer.apple.com/reference/usernotifications/unnotificationserviceextension).
  ///
  /// On Android and Web, this parameter will be ignored.
  ///
  /// **Default value:** `false`
  final bool? mutableContent;

  /// On iOS, use this field to represent `content-available` in the APNs payload.
  /// When a notification or data message is sent and this is set to `true`, an
  /// inactive client app is awoken. On Android, data messages wake the app by
  /// default. On Chrome, this flag is currently not supported.
  ///
  /// **Default value:** `false`
  final bool? contentAvailable;

  /// The package name of the application which the registration tokens must match
  /// in order to receive the message.
  ///
  /// **Default value:** None
  final String? restrictedPackageName;
}

/// Interface representing the server response from the legacy {@link Messaging.sendToTopic} method.
///
/// See
/// [Send to a topic](https://firebase.google.com/docs/cloud-messaging/admin/send-messages#send_to_a_topic)
/// for code samples and detailed documentation.
class MessagingTopicResponse {
  /// Interface representing the server response from the legacy {@link Messaging.sendToTopic} method.
  ///
  /// See
  /// [Send to a topic](https://firebase.google.com/docs/cloud-messaging/admin/send-messages#send_to_a_topic)
  /// for code samples and detailed documentation.
  MessagingTopicResponse({required this.messageId});

  /// The message ID for a successfully received request which FCM will attempt to
  /// deliver to all subscribed devices.
  final num messageId;
}

/// Interface representing the server response from the
/// [Messaging.sendEach] and [Messaging.sendEachForMulticast] methods.
class BatchResponse {
  /// Interface representing the server response from the
  /// [Messaging.sendEach] and [Messaging.sendEachForMulticast] methods.
  BatchResponse._({
    required this.responses,
    required this.successCount,
    required this.failureCount,
  });

  /// An array of responses, each corresponding to a message.
  final List<SendResponse> responses;

  /// The number of messages that were successfully handed off for sending.
  final int successCount;

  /// The number of messages that resulted in errors when sending.
  final int failureCount;
}

/// Interface representing the status of an individual message that was sent as
/// part of a batch request.
class SendResponse {
  /// Interface representing the status of an individual message that was sent as
  /// part of a batch request.
  SendResponse._({
    required this.success,
    this.messageId,
    this.error,
  });

  /// A boolean indicating if the message was successfully handed off to FCM or
  /// not. When true, the `messageId` attribute is guaranteed to be set. When
  /// false, the `error` attribute is guaranteed to be set.
  final bool success;

  /// A unique message ID string, if the message was handed off to FCM for
  /// delivery.
  final String? messageId;

  /// An error, if the message was not handed off to FCM successfully.
  final FirebaseAdminException? error;
}
