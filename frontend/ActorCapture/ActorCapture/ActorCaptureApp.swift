import SwiftUI
import UIKit

@main
struct ActorCaptureApp: App {
    @ObservedObject var store = Backend.shared
    
    var body: some Scene {
        WindowGroup {
            MenuBottom()
        }
    }
}
