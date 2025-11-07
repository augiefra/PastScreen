//
//  FullScreenCaptureService.swift
//  ScreenSnap
//
//  Simple full screen capture service
//

import Foundation
import AppKit
import ScreenCaptureKit
import UserNotifications

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
        Task {
            let displays = await captureAllScreens()

            guard !displays.isEmpty else {
                await MainActor.run {
                    showNoScreenAlert()
                }
                return
            }

            if displays.count == 1 {
                // Un seul écran, capturer directement
                await captureScreen(index: 0)
            } else {
                // Plusieurs écrans, demander lequel
                await MainActor.run {
                    presentScreenSelector(displays: displays)
                }
            }
        }
    }

    private func presentScreenSelector(displays: [SCDisplay]) {
        let alert = NSAlert()
        alert.messageText = "Quel écran voulez-vous capturer ?"
        alert.informativeText = "\(displays.count) écrans disponibles"
        alert.alertStyle = .informational

        for (index, display) in displays.enumerated() {
            let screenName = "Écran \(index + 1)"
            let dimensions = "\(display.width) × \(display.height)"
            let buttonTitle = "\(screenName) (\(dimensions))"
            alert.addButton(withTitle: buttonTitle)
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

    private func captureScreen(index: Int) async {
        do {
            let content = try await SCShareableContent.current

            guard index < content.displays.count else {
                print("❌ [FULLSCREEN] Invalid screen index: \(index)")
                return
            }

            let display = content.displays[index]

            // Create content filter for full screen
            let filter = SCContentFilter(display: display, excludingWindows: [])
            let configuration = SCStreamConfiguration()

            configuration.width = display.width
            configuration.height = display.height
            configuration.scalesToFit = false
            configuration.showsCursor = true // Montrer le curseur pour écran complet

            let image = try await SCScreenshotManager.captureImage(
                contentFilter: filter,
                configuration: configuration
            )

            let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))

            await MainActor.run {
                processCapture(image: nsImage, screenName: "Écran \(index + 1)")
            }

            print("✅ [FULLSCREEN] Captured screen \(index + 1)")

        } catch {
            print("❌ [FULLSCREEN] Error capturing screen: \(error)")
            await MainActor.run {
                showCaptureErrorAlert(error: error)
            }
        }
    }

    private func processCapture(image: NSImage, screenName: String) {
        // Play sound if enabled
        if AppSettings.shared.playSoundOnCapture {
            NSSound(named: "Pop")?.play()
        }

        // Copy to clipboard if enabled
        if AppSettings.shared.copyToClipboard {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([image])
        }

        // Save to file if enabled
        if AppSettings.shared.saveToFile {
            saveToFile(image: image, screenName: screenName)
        }

        // Show Dynamic Island notification
        DynamicIslandManager.shared.show(message: "\(screenName) capturé", duration: 2.0)

        // Also show native notification
        showNotification(screenName: screenName)
    }

    private func saveToFile(image: NSImage, screenName: String) {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
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
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())

        let filename = "FullScreen-\(screenName)-\(timestamp).\(fileExtension)"

        AppSettings.shared.ensureFolderExists()
        let filePath = AppSettings.shared.saveFolderPath + filename

        try? data.write(to: URL(fileURLWithPath: filePath))

        // Post notification for "Reveal last screenshot" feature
        NotificationCenter.default.post(
            name: .screenshotCaptured,
            object: nil,
            userInfo: ["filePath": filePath]
        )
    }

    private func showNotification(screenName: String) {
        let content = UNMutableNotificationContent()
        content.title = "ScreenSnap"
        content.body = "\(screenName) capturé en plein écran"
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
        alert.informativeText = "Impossible de détecter les écrans. Vérifiez les permissions."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showCaptureErrorAlert(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Erreur de capture"
        alert.informativeText = "Impossible de capturer l'écran : \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
