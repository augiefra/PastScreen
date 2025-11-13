//
//  ModernOnboardingView.swift
//  ScreenSnap
//
//  Modern liquid glass onboarding with multiple pages
//

import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Modern Onboarding View

struct ModernOnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    var onComplete: () -> Void

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "bolt.fill",
            title: "Ultra Rapide",
            description: "Capturez et collez en quelques secondes.\n⌘⇧5 → Capturer → ⌘V dans votre IDE",
            accentColor: .yellow
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Nettoyage Auto",
            description: "Toutes vos captures sont automatiquement effacées au redémarrage.\nFini les dossiers qui débordent!",
            accentColor: .purple
        ),
        OnboardingPage(
            icon: "clipboard.fill",
            title: "Clipboard Direct",
            description: "Copie automatique dans le presse-papiers.\nParfait pour Cursor, VSCode, Zed.",
            accentColor: .blue
        ),
        OnboardingPage(
            icon: "gearshape.fill",
            title: "Personnalisable",
            description: "Raccourcis, formats, dossiers...\nTout est configurable depuis la barre de menu.",
            accentColor: .green
        )
    ]

    var body: some View {
        ZStack {
            // Liquid glass background
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("ScreenSnap")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Captures d'écran pour développeurs")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .padding(.bottom, 30)

                // Content
                ZStack {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .opacity(currentPage == index ? 1 : 0)
                            .offset(x: currentPage == index ? 0 : (currentPage > index ? -50 : 50))
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .frame(height: 400)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? pages[currentPage].accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.vertical, 20)

                // Buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }) {
                            Text("Précédent")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(width: 120, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.15))
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Suivant" : "Commencer")
                                .font(.system(size: 15, weight: .semibold))

                            if currentPage == pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(width: 140, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            pages[currentPage].accentColor,
                                            pages[currentPage].accentColor.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: pages[currentPage].accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .frame(width: 600, height: 650)
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                page.accentColor.opacity(0.3),
                                page.accentColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)

                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(page.accentColor)
            }
            .scaleEffect(isAnimated ? 1.0 : 0.8)
            .opacity(isAnimated ? 1.0 : 0.0)

            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimated ? 1.0 : 0.0)
                    .offset(y: isAnimated ? 0 : 20)

                // Description
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .opacity(isAnimated ? 1.0 : 0.0)
                    .offset(y: isAnimated ? 0 : 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isAnimated = true
            }
        }
        .onDisappear {
            isAnimated = false
        }
    }
}

// MARK: - Visual Effect Blur

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Preview

#Preview {
    ModernOnboardingView(onComplete: {
        print("Onboarding completed")
    })
}
