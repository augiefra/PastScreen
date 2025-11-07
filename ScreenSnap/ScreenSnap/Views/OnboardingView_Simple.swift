//
//  OnboardingView_Simple.swift
//  ScreenSnap
//
//  Simple NSAlert-based onboarding (stable, no SwiftUI crashes)
//

import Foundation
import AppKit

// MARK: - Simple OnboardingManager

class SimpleOnboardingManager {
    static let shared = SimpleOnboardingManager()

    private let hasSeenOnboardingKey = "hasSeenOnboarding"

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
        DispatchQueue.main.async {
            print("✨ [ONBOARDING] Showing welcome screen")

            let alert = NSAlert()
            alert.messageText = "🎉 Bienvenue dans ScreenSnap!"
            alert.informativeText = """

            ⌘  Raccourci principal
                Appuyez sur ⌥⌘S pour capturer une zone

            📋 Copie automatique
                Le chemin du fichier est copié au clipboard

            📁 Stockage temporaire
                Les captures sont dans /tmp (parfait pour Zed)

            ⚙️  Accès aux options
                Cliquez sur l'icône menu bar pour les réglages

            """

            alert.alertStyle = .informational
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = "Ne plus afficher"

            alert.addButton(withTitle: "Compris!")

            // Show the alert
            let response = alert.runModal()

            // Check if user clicked "Don't show again"
            if alert.suppressionButton?.state == .on {
                self.hasSeenOnboarding = true
                print("✅ [ONBOARDING] User chose 'Don't show again'")
            }

            print("✅ [ONBOARDING] Dismissed")
        }
    }
}
