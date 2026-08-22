import SwiftUI

@main
struct AttuneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            WheelScreen()
                .navigationDestination(for: OuterFeeling.self) { feeling in
                    NeedsView(feeling: feeling)
                }
                .navigationDestination(for: RespondRoute.self) { route in
                    RespondView(route: route)
                }
        }
        .tint(Theme.ink)
    }
}

#Preview {
    ContentView()
}
