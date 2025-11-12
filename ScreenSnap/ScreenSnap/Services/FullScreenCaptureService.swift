//
//  FullScreenCaptureService.swift
//  ScreenSnap
//
//  Simple full screen capture service with display names
//

import Foundation
import AppKit
import ScreenCaptureKit
import UserNotifications
import CoreGraphics
import IOKit

@available(macOS 12.3, *)
class FullScreenCaptureService: NSObject {

    func captureMainScreen() {
        Task {
            await captureScreen(index: 0)
        }
    }

    func captureAllScreens() async -> [SCDisplay] {
        do {
            let content = try await SCShareableContent.current
            return content.displays
        } catch {
            print("❌ [FULLSCREEN] Error loading displays: \(error)")
            return []
        }
    }

    func showScreenSelector() {
        print("🎬 [FULLSCREEN] showScreenSelector() called")

        // SIMPLIFIED: Always capture main screen directly (no modal dialog)
        Task {
            print("📋 [FULLSCREEN] Capturing main screen directly...")
            await captureScreen(index: 0)
        }
    }

    private func presentScreenSelector(displays: [SCDisplay]) {
        let alert = NSAlert()
        alert.messageText = "Quel écran voulez-vous capturer ?"
        alert.informativeText = "\(displays.count) écrans disponibles"
        alert.alertStyle = .informational

        // Get NSScreens to match with SCDisplays
        let nsScreens = NSScreen.screens

        for (index, display) in displays.enumerated() {
            let displayName = getDisplayName(for: display, at: index, nsScreens: nsScreens)
            alert.addButton(withTitle: displayName)
        }

        alert.addButton(withTitle: "Annuler")

        let response = alert.runModal()

        // Les boutons sont indexés à partir de NSApplication.ModalResponse.alertFirstButtonReturn
        let buttonIndex = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue

        if buttonIndex >= 0 && buttonIndex < displays.count {
            Task {
                await captureScreen(index: buttonIndex)
            }
        }
    }

    private func getDisplayName(for display: SCDisplay, at index: Int, nsScreens: [NSScreen]) -> String {
        // Try to match SCDisplay with NSScreen by displayID
        let displayID = display.displayID

        // Check if this is the built-in display (main screen)
        if let nsScreen = nsScreens.first(where: { screen in
            // Get the display ID from NSScreen
            guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
                return false
            }
            return screenNumber == displayID
        }) {
            // Check if it's the main screen (built-in)
            if nsScreen == NSScreen.main {
                return "Écran intégré (\(display.width) × \(display.height))"
            }
        }

        // Try to get external display name using IOKit
        if let externalName = getExternalDisplayName(displayID: displayID) {
            return "\(externalName) (\(display.width) × \(display.height))"
        }

        // Fallback
        return "Écran \(index + 1) (\(display.width) × \(display.height))"
    }

    private func getExternalDisplayName(displayID: CGDirectDisplayID) -> String? {
        // Get IOService port for the display
        var servicePort: io_service_t = 0

        var iterator: io_iterator_t = 0
        let matching = IOServiceMatching("IODisplayConnect")

        guard IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }

        defer { IOObjectRelease(iterator) }

        while true {
            servicePort = IOIteratorNext(iterator)
            if servicePort == 0 { break }

            defer { IOObjectRelease(servicePort) }

            // Get display info dictionary
            guard let info = IODisplayCreateInfoDictionary(servicePort, IOOptionBits(kIODisplayOnlyPreferredName)).takeRetainedValue() as? [String: Any] else {
                continue
            }

            // Get display product names dictionary
            if let productNames = info[kDisplayProductName] as? [String: String],
               let displayName = productNames["en_US"] ?? productNames.values.first {
                return displayName
            }
        }

        return nil
    }

    private func captureScreen(index: Int) async {
        print("🎯 [FULLSCREEN] Starting capture for screen \(index + 1)")

        do {
            print("📡 [FULLSCREEN] Fetching SCShareableContent.current...")
            let content = try await SCShareableContent.current
            print("✅ [FULLSCREEN] Got content, displays count: \(content.displays.count)")

            guard index < content.displays.count else {
                print("❌ [FULLSCREEN] Invalid screen index: \(index)")
                await MainActor.run {
                    showCaptureErrorAlert(message: "Index d'écran invalide")
                }
                return
            }

            let display = content.displays[index]
            print("📐 [FULLSCREEN] Display: \(display.width)x\(display.height), ID: \(display.displayID)")

            // Create content filter for full screen
            let filter = SCContentFilter(display: display, excludingWindows: [])
            let configuration = SCStreamConfiguration()

            configuration.width = display.width
            configuration.height = display.height
            configuration.scalesToFit = false
            configuration.showsCursor = true

            print("📸 [FULLSCREEN] Calling SCScreenshotManager.captureImage...")

            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )

            print("✅ [FULLSCREEN] Image captured: \(image.width)x\(image.height)")
            print("🔍 [FULLSCREEN] CGImage details - width:\(image.width) height:\(image.height) bitsPerComponent:\(image.bitsPerComponent) bitsPerPixel:\(image.bitsPerPixel)")

            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
            print("🔍 [FULLSCREEN] NSImage created - size:\(nsImage.size) isValid:\(nsImage.isValid)")

            // Verify image has representations
            print("🔍 [FULLSCREEN] NSImage representations count: \(nsImage.representations.count)")

            // Get display name for notification
            let nsScreens = NSScreen.screens
            let displayName = getDisplayName(for: display, at: index, nsScreens: nsScreens)

            print("📍 [FULLSCREEN] About to call processCapture on MainActor...")

            await MainActor.run {
                processCapture(image: nsImage, screenName: displayName)
            }

            print("✅ [FULLSCREEN] Capture completed for \(displayName)")

        } catch {
            print("❌ [FULLSCREEN] Error capturing screen: \(error.localizedDescription)")
            print("❌ [FULLSCREEN] Error details: \(error)")

            await MainActor.run {
                showCaptureErrorAlert(message: error.localizedDescription)
            }
        }
    }

    private func processCapture(image: NSImage, screenName: String) {
        print("💾 [FULLSCREEN] Processing capture for \(screenName)")
        print("💾 [FULLSCREEN] Image size: \(image.size.width)x\(image.size.height)")

        // Copy to clipboard if enabled
        if AppSettings.shared.copyToClipboard {
            print("📋 [FULLSCREEN] Copying to clipboard...")
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            let success = pasteboard.writeObjects([image])
            print("📋 [FULLSCREEN] Clipboard copy: \(success ? "✅" : "❌")")
        }

        // Save to file if enabled
        if AppSettings.shared.saveToFile {
            saveToFile(image: image, screenName: screenName)
        }

        // Play sound
        if AppSettings.shared.playSoundOnCapture {
            NSSound(named: "Glass")?.play()
        }

        // Show notifications
        DynamicIslandManager.shared.show(message: "Capturé", duration: 2.0)
        showNotification(screenName: screenName)

        print("✅ [FULLSCREEN] Processing complete")
    }

    private func saveToFile(image: NSImage, screenName: String) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            print("❌ [FULLSCREEN] Failed to convert image for saving")
            return
        }

        let fileType: NSBitmapImageRep.FileType
        let fileExtension: String

        switch AppSettings.shared.imageFormat {
        case "jpeg":
            fileType = .jpeg
            fileExtension = "jpg"
        default:
            fileType = .png
            fileExtension = "png"
        }

        guard let data = bitmapImage.representation(using: fileType, properties: [:]) else {
            print("❌ [FULLSCREEN] Failed to create image data")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())

        // Clean screen name for filename
        let cleanName = screenName
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "×", with: "x")

        let filename = "FullScreen-\(cleanName)-\(timestamp).\(fileExtension)"

        AppSettings.shared.ensureFolderExists()
        let filePath = AppSettings.shared.saveFolderPath + filename

        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            print("💾 [FULLSCREEN] Saved to: \(filePath)")

            // Post notification for "Reveal last screenshot" feature
            NotificationCenter.default.post(
                name: .screenshotCaptured,
                object: nil,
                userInfo: ["filePath": filePath]
            )
        } catch {
            print("❌ [FULLSCREEN] Failed to save file: \(error)")
        }
    }

    private func showNotification(screenName: String) {
        let content = UNMutableNotificationContent()
        content.title = "ScreenSnap"
        content.body = "\(screenName) capturé"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func showNoScreenAlert() {
        let alert = NSAlert()
        alert.messageText = "Aucun écran disponible"
        alert.informativeText = "Impossible de détecter les écrans. Vérifiez les permissions d'enregistrement d'écran."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showCaptureErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Erreur de capture"
        alert.informativeText = "Impossible de capturer l'écran :\n\n\(message)\n\nVérifiez les permissions d'enregistrement d'écran dans Réglages Système."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
