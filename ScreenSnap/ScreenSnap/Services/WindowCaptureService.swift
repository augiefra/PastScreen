//
//  WindowCaptureService.swift
//  ScreenSnap
//
//  Window capture service using ScreenCaptureKit for macOS 14+
//

import Foundation
import AppKit
import ScreenCaptureKit
import SwiftUI
import UserNotifications

@available(macOS 12.3, *)
class WindowCaptureService: NSObject {
    private var availableWindows: [SCWindow] = []
    var selectorWindow: NSWindow?

    override init() {
        super.init()
    }

    func showWindowSelector() {
        Task {
            await loadAvailableWindows()

            DispatchQueue.main.async {
                self.presentWindowSelector()
            }
        }
    }

    private func loadAvailableWindows() async {
        do {
            // Vérifier les permissions d'abord
            guard await checkScreenRecordingPermission() else {
                print("Screen recording permission not granted")
                availableWindows = []
                return
            }
            
            let content = try await SCShareableContent.current

            // Filter out system and hidden windows
            availableWindows = content.windows.filter { window in
                guard let title = window.title,
                      let app = window.owningApplication else {
                    return false
                }

                // Filter criteria
                return !title.isEmpty &&
                       window.frame.width > 100 &&
                       window.frame.height > 100 &&
                       window.isOnScreen &&
                       app.applicationName != "Window Server"
            }

            print("Found \(availableWindows.count) capturable windows")
        } catch {
            print("Error loading windows: \(error.localizedDescription)")
            availableWindows = []
        }
    }
    
    private func checkScreenRecordingPermission() async -> Bool {
        // Pour macOS 14+, on peut vérifier les permissions de ScreenCaptureKit
        do {
            _ = try await SCShareableContent.current
            return true
        } catch {
            print("Permission check failed: \(error)")
            return false
        }
    }

    private func presentWindowSelector() {
        // Vérifier qu'on a des fenêtres à afficher
        guard !availableWindows.isEmpty else {
            print("No windows available to display")
            showNoWindowsAlert()
            return
        }
        
        // Create window selector UI
        let selectorView = WindowSelectorView(
            windows: availableWindows
        ) { [weak self] selectedWindow in
            self?.selectorWindow?.close()
            self?.selectorWindow = nil
            self?.captureWindow(selectedWindow)
        }

        let hostingController = NSHostingController(rootView: selectorView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Sélectionner une fenêtre"
        window.contentViewController = hostingController
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        self.selectorWindow = window

        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func showNoWindowsAlert() {
        let alert = NSAlert()
        alert.messageText = "Aucune fenêtre disponible"
        alert.informativeText = "Aucune fenêtre capturable n'a été trouvée. Assurez-vous que les applications sont ouvertes et visibles."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func captureWindow(_ window: SCWindow) {
        Task {
            do {
                let filter = SCContentFilter(desktopIndependentWindow: window)
                let configuration = SCStreamConfiguration()

                configuration.width = Int(window.frame.width)
                configuration.height = Int(window.frame.height)
                configuration.scalesToFit = false
                configuration.showsCursor = false

                let image = try await SCScreenshotManager.captureImage(
                    contentFilter: filter,
                    configuration: configuration
                )

                let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))

                await MainActor.run {
                    self.processCapture(image: nsImage, window: window)
                }
            } catch {
                print("Error capturing window: \(error.localizedDescription)")
                await MainActor.run {
                    self.showCaptureErrorAlert(error: error)
                }
            }
        }
    }
    
    private func showCaptureErrorAlert(error: Error) {
        let alert = NSAlert()
        alert.messageText = "Erreur de capture"
        alert.informativeText = "Impossible de capturer la fenêtre : \(error.localizedDescription)"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func processCapture(image: NSImage, window: SCWindow) {
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
            saveToFile(image: image, windowTitle: window.title ?? "Window")
        }

        // Show notification
        showNotification(windowTitle: window.title ?? "Fenêtre")
    }

    private func saveToFile(image: NSImage, windowTitle: String) {
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

        // Sanitize window title for filename
        let sanitizedTitle = windowTitle
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .prefix(30)

        let filename = "Window-\(sanitizedTitle)-\(timestamp).\(fileExtension)"

        AppSettings.shared.ensureFolderExists()
        let filePath = AppSettings.shared.saveFolderPath + filename

        try? data.write(to: URL(fileURLWithPath: filePath))
    }

    private func showNotification(windowTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "ScreenSnap"
        content.body = "Fenêtre '\(windowTitle)' capturée"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    deinit {
        // No observers to remove
    }
}

// MARK: - Window Selector View

@available(macOS 12.3, *)
struct WindowSelectorView: View {
    let windows: [SCWindow]
    let onSelect: (SCWindow) -> Void

    @State private var searchText = ""
    @State private var hoveredWindow: UInt32?

    var filteredWindows: [SCWindow] {
        if searchText.isEmpty {
            return windows
        }
        return windows.filter { window in
            let title = window.title?.lowercased() ?? ""
            let appName = window.owningApplication?.applicationName.lowercased() ?? ""
            let query = searchText.lowercased()
            return title.contains(query) || appName.contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Rechercher une fenêtre ou application...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Windows grid
            if filteredWindows.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "macwindow.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)

                    Text("Aucune fenêtre trouvée")
                        .font(.headline)

                    Text("Assurez-vous que les applications sont visibles")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredWindows, id: \.windowID) { window in
                            WindowThumbnailView(
                                window: window,
                                isHovered: hoveredWindow == window.windowID
                            )
                            .onTapGesture {
                                onSelect(window)
                            }
                            .onHover { hovering in
                                hoveredWindow = hovering ? window.windowID : nil
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

// MARK: - Window Thumbnail View

@available(macOS 12.3, *)
struct WindowThumbnailView: View {
    let window: SCWindow
    let isHovered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Window preview placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    Image(systemName: "macwindow")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                )
                .aspectRatio(16/10, contentMode: .fit)

            VStack(alignment: .leading, spacing: 4) {
                // Window title
                Text(window.title ?? "Sans titre")
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                // App name
                if let appName = window.owningApplication?.applicationName {
                    HStack(spacing: 4) {
                        Image(systemName: "app.fill")
                            .font(.caption2)
                        Text(appName)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                // Dimensions
                Text("\(Int(window.frame.width)) × \(Int(window.frame.height))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovered ? Color(nsColor: .controlAccentColor).opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHovered ? Color(nsColor: .controlAccentColor) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.quickSpring, value: isHovered)
    }
}
