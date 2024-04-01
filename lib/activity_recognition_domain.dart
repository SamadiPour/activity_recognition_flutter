part of activity_recognition;

/// The different types of activities which can be detected.
/// These types is identical to the types detected on Android
/// and iOS types are mapped to these.
enum ActivityType {
  IN_VEHICLE,
  ON_BICYCLE,
  ON_FOOT,
  RUNNING,
  STILL,
  TILTING,
  UNKNOWN,
  WALKING,
  INVALID // Used for parsing errors
}

Map<String, ActivityType> _activityMap = {
  // Android
  'IN_VEHICLE': ActivityType.IN_VEHICLE,
  'ON_BICYCLE': ActivityType.ON_BICYCLE,
  'ON_FOOT': ActivityType.ON_FOOT,
  'RUNNING': ActivityType.RUNNING,
  'STILL': ActivityType.STILL,
  'TILTING': ActivityType.TILTING,
  'UNKNOWN': ActivityType.UNKNOWN,
  'WALKING': ActivityType.WALKING,

  // iOS
  'automotive': ActivityType.IN_VEHICLE,
  'cycling': ActivityType.ON_BICYCLE,
  'running': ActivityType.RUNNING,
  'stationary': ActivityType.STILL,
  'unknown': ActivityType.UNKNOWN,
  'walking': ActivityType.WALKING,
};

/// Represents an activity event detected on the phone.
class ActivityEvent {
  /// The type of activity.
  List<ActivityType> types;

  /// The confidence of the detection in percentage.
  int confidence;

  /// The timestamp when detected.
  DateTime timeStamp;

  ActivityEvent(this.types, this.confidence, this.timeStamp);

  factory ActivityEvent.unknown() => ActivityEvent(
        [ActivityType.UNKNOWN],
        100,
        DateTime.now(),
      );

  /// Create an [ActivityEvent] based on the string format `type,confidence`.
  factory ActivityEvent.fromString(String string) {
    List<String> tokens = string.split(',');
    if (tokens.length < 2) return ActivityEvent.unknown();

    /// Example -> UNKNOWN/WALKING or WALKING
    final types = <ActivityType>[];
    for (final type in tokens.first.split('/')) {
      if (_activityMap.containsKey(type)) {
        types.add(_activityMap[type]!);
      }
    }
    if (types.isEmpty) {
      types.add(ActivityType.UNKNOWN);
    }

    /// Example -> 100
    final conf = int.tryParse(tokens[1])!;

    /// Example -> 2024-03-31 16:59:46 +0000
    final dateString = tokens.length >= 3 ? tokens[2] : '';
    final date = DateTime.tryParse(dateString)?.toLocal() ?? DateTime.now();

    return ActivityEvent(types, conf, date);
  }

  @override
  String toString() =>
      'Activity - type: ${types.join(' - ')}, confidence: $confidence%, TimeStamp: $timeStamp';
}
