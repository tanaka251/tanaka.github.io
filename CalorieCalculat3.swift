//CalorieCalculatApp
import SwiftUI
import SwiftData

@main
struct CalomiruApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [UserProfile.self]) // 設定だけ保存
    }
}
