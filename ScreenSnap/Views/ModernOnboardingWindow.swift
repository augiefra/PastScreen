//
//  ModernOnboardingWindow.swift
//  ScreenSnap
//
//  Modern onboarding window manager with liquid glass effect
//

import Foundation
import AppKit
import SwiftUI

class ModernOnboardingManager {
    static let shared = ModernOnboardingManager()

    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    private var currentWindow: NSWindow?

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey) }
    }

    func showIfNeeded() {
        guard !hasSeenOnboarding else {
            print("ℹ️ [ONBOARDING] Already seen, skipping")
            return
        }
        show()
    }

    func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            print("✨ [ONBOARDING] Showing modern onboarding")

            // Close existing window if any
            self.currentWindow?.close()

            // Create the SwiftUI view
            let onboardingView = ModernOnboardingView {
                self.hasSeenOnboarding = true
                self.currentWindow?.close()
                print("✅ [ONBOARDING] Completed and dismissed")
            }

            // Create a hosting controller
            let hostingController = NSHostingController(rootView: onboardingView)

            // Create a transparent, borderless window
            let window = NSWindow(contentViewController: hostingController)
            window.styleMask = [.borderless, .fullSizeContentView]
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
            window.level = .floating
            window.isMovableByWindowBackground = true

            // Center the window
            window.center()

            // Make it key and order front
            window.makeKeyAndOrderFront(nil)

            // Activate the app to bring window to front
            NSApp.activate(ignoringOtherApps: true)

            // Store reference
            self.currentWindow = window
        }
    }
}

// Alias for compatibility with existing code
typealias SimpleOnboardingManager = ModernOnboardingManager
