import CoreMotion
import Flutter
import UIKit

public class SwiftActivityRecognitionFlutterPlugin: NSObject, FlutterPlugin {
  private let activityManager = CMMotionActivityManager()
  public static func register(with registrar: FlutterPluginRegistrar) {
    let handler = ActivityStreamHandler()
    let channel = FlutterEventChannel(
      name: "activity_recognition_flutter", binaryMessenger: registrar.messenger())
    channel.setStreamHandler(handler)

    let instance = SwiftActivityRecognitionFlutterPlugin()
    let methodChannel = FlutterMethodChannel(
      name: "activity_recognition_flutter_method", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getHistoricalActivities":
      guard let args = call.arguments as? [String: Any],
        let fromDate = args["fromDate"] as? Double,
        let toDate = args["toDate"] as? Double
      else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }

      let from = Date(timeIntervalSince1970: fromDate / 1000)
      let to = Date(timeIntervalSince1970: toDate / 1000)

      activityManager.queryActivityStarting(from: from, to: to, to: OperationQueue()) {
        activities, error in
        if let error = error {
          result(FlutterError(code: "QUERY_ERROR", message: error.localizedDescription, details: nil))
          return
        }

        let activityData = activities?.map { activity -> String in
          return activity.toStringFlutter()
        } ?? []

        result(activityData)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

public class ActivityStreamHandler: NSObject, FlutterStreamHandler {
  private let activityManager = CMMotionActivityManager()

  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink)
    -> FlutterError?
  {
    activityManager.startActivityUpdates(to: OperationQueue.init()) { (activity) in
      if let a = activity {
        /// Send event to flutter
        eventSink(a.toStringFlutter())
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    activityManager.stopActivityUpdates()
    return nil
  }
}

extension CMMotionActivity {
  func toStringFlutter() -> String {
    return "\(activityTypeString()),\(confidenceString()),\(self.startDate)"
  }

  func activityTypeString() -> String {
    var types = [String]()
    if self.stationary { types.append("STILL") }
    if self.walking { types.append("WALKING") }
    if self.running { types.append("RUNNING") }
    if self.automotive { types.append("IN_VEHICLE") }
    if self.cycling { types.append("ON_BICYCLE") }
    if self.unknown || types.isEmpty { types.append("UNKNOWN") }
    return types.joined(separator: "/")
  }

  func confidenceString() -> String {
    switch self.confidence {
    case .low:
      return "10"
    case .medium:
      return "50"
    case .high:
      return "100"
    default:
      return "-1"
    }
  }
}
