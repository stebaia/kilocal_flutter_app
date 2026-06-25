//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by Stefano Baiardi on 25/06/26.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Only the Live Activity is used. The default home-screen widget
        // (TimerWidget) and Control Center widget (TimerWidgetControl, iOS 18+)
        // from the Xcode template are intentionally left out.
        TimerWidgetLiveActivity()
    }
}
