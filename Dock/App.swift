import SwiftUI

@main struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            RootView(apps: [
                "Finder",
                "Launchpad",
                "Safari",
                "Mail",
                "Contacts",
                "Calendar",
                "Notes",
                "Maps",
                "Messages",
                "FaceTime",
                "Photo Booth",
                "Preview",
                "iTunes",
                "App Store",
                "System Preferences",
            ])
            .frame(minWidth: 1280, minHeight: 720)
            .navigationTitle("Dock")
        }
    }
}
