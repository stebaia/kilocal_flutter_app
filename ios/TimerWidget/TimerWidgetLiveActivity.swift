//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Live Activity for the workout timer, driven by the `live_activities`
//  Flutter plugin. The plugin writes the data passed from Dart into a shared
//  App Group `UserDefaults`, keyed by `"<activityId>_<field>"`. We read the
//  `label` and `endDate` (epoch millis) fields written by SystemTimerService.
//

import ActivityKit
import SwiftUI
import WidgetKit

// Must match the attributes the live_activities plugin creates.
struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
    public typealias LiveDeliveryData = ContentState

    public struct ContentState: Codable, Hashable {}

    var id = UUID()
}

// Shared store; the suite name must match the App Group configured on both the
// Runner and this extension (and `_iosAppGroupId` in system_timer_service.dart).
let sharedDefault = UserDefaults(suiteName: "group.com.kilocal.liveactivities")!

struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            // Lock screen / banner.
            let label = sharedDefault.string(
                forKey: context.attributes.prefixedKey("label")
            ) ?? "KiloCal"
            let endDate = Date(
                timeIntervalSince1970: sharedDefault.double(
                    forKey: context.attributes.prefixedKey("endDate")
                ) / 1000
            )

            HStack {
                Image(systemName: "timer")
                Text(label)
                    .font(.headline)
                Spacer()
                Text(timerInterval: Date()...endDate, countsDown: true)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 80)
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.78, green: 0.08, blue: 0.23))
            .foregroundColor(.white)

        } dynamicIsland: { context in
            let endDate = Date(
                timeIntervalSince1970: sharedDefault.double(
                    forKey: context.attributes.prefixedKey("endDate")
                ) / 1000
            )
            let label = sharedDefault.string(
                forKey: context.attributes.prefixedKey("label")
            ) ?? "KiloCal"

            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(label, systemImage: "timer")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...endDate, countsDown: true)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 80)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(timerInterval: Date()...endDate, countsDown: true)
                    .monospacedDigit()
                    .frame(maxWidth: 44)
            } minimal: {
                Image(systemName: "timer")
            }
            .keylineTint(Color(red: 0.78, green: 0.08, blue: 0.23))
        }
    }
}

extension LiveActivitiesAppAttributes {
    // The plugin prefixes every stored key with the activity id.
    func prefixedKey(_ key: String) -> String {
        return "\(id)_\(key)"
    }
}
