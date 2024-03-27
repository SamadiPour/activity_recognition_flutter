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

  /// The confidence of the dection in percentage.
  int confidence;

  /// The timestamp when detected.
  late DateTime timeStamp;

  ActivityEvent(this.types, this.confidence) {
    this.timeStamp = DateTime.now();
  }

  factory ActivityEvent.unknown() => ActivityEvent([ActivityType.UNKNOWN], 100);

  /// Create an [ActivityEvent] based on the string format `type,confidence`.
  factory ActivityEvent.fromString(String string) {
    List<String> tokens = string.split(',');
    if (tokens.length < 2) return ActivityEvent.unknown();

    final types = <ActivityType>[];
    for (final type in tokens.first.split('/')) {
      if (_activityMap.containsKey(type)) {
        types.add(_activityMap[type]!);
      }
    }
    if (types.isEmpty) {
      types.add(ActivityType.UNKNOWN);
    }
    int conf = int.tryParse(tokens.last)!;

    return ActivityEvent(types, conf);
  }

  @override
  String toString() =>
      'Activity - type: ${types.join(' - ')}, confidence: $confidence%';
}
