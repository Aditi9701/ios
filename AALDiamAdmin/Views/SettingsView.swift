import SwiftUI

public struct SettingsView: View {
    @ObservedObject var authManager: BiometricAuthManager
    @State private var biometricSuccessMessage: String? = nil

    public var body: some View {
        ZStack {
            Color.obsidianBlack.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Header
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.title3)
                            .foregroundColor(.goldPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PORTAL SECURITY & SYSTEM")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.goldPrimary)
                            Text("AALDiam Superadmin iOS Native Client")
                                .font(.caption2)
                                .foregroundColor(.textMuted)
                        }
                    }
                    .padding(.top, 8)

                    // 1. Security Credentials Card
                    cardContainer(title: "SECURITY CREDENTIALS") {
                        VStack(spacing: 12) {
                            settingsRow(icon: "key.fill", title: "Superadmin Master Key", subtitle: "\(DiamondConstants.masterSuperadminKey.prefix(16))... (Protected)", status: "Active", statusColor: .statusAvailable)
                            Divider().background(Color.borderDark)
                            settingsRow(icon: "faceid", title: "Face ID / Biometrics", subtitle: "Apple LocalAuthentication hardware gate", status: "Protected", statusColor: .statusAvailable)

                            Button(action: testFaceID) {
                                HStack {
                                    Image(systemName: "faceid")
                                    Text("Re-test Face ID Unlock")
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.goldPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.surfaceDark)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.goldPrimary, lineWidth: 1))
                            }

                            if let msg = biometricSuccessMessage {
                                Text(msg)
                                    .font(.caption2)
                                    .foregroundColor(.statusAvailable)
                            }
                        }
                    }

                    // 2. Hardware & Display
                    cardContainer(title: "HARDWARE & DISPLAY") {
                        VStack(spacing: 12) {
                            settingsRow(icon: "iphone", title: "Apple Device", subtitle: "\(UIDevice.current.model) • iOS \(UIDevice.current.systemVersion)", status: "Optimized", statusColor: .statusAvailable)
                            Divider().background(Color.borderDark)
                            settingsRow(icon: "sensor.tag.radiowaves.forward.fill", title: "Dynamic Island / Notch", subtitle: "SafeAreaInsets cover layout active", status: "Active", statusColor: .statusAvailable)
                            Divider().background(Color.borderDark)
                            settingsRow(icon: "internaldrive.fill", title: "Offline Vault Storage", subtitle: "Local persistent JSON & drafts mirror", status: "Ready", statusColor: .statusAvailable)
                        }
                    }

                    // 3. Software Version
                    cardContainer(title: "SOFTWARE & UPDATES") {
                        VStack(spacing: 12) {
                            settingsRow(icon: "app.badge.checkmark.fill", title: "AALDiam Admin iOS", subtitle: "v2.1.0 • Pure Native SwiftUI Binary", status: "v2.1.0", statusColor: .goldPrimary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 60)
            }
        }
    }

    private func testFaceID() {
        authManager.authenticate { success in
            if success {
                biometricSuccessMessage = "Face ID verified successfully!"
            }
        }
    }

    private func cardContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.goldPrimary)
            VStack {
                content()
            }
            .padding(14)
            .background(Color.cardDark)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borderDark, lineWidth: 1))
        }
    }

    private func settingsRow(icon: String, title: String, subtitle: String, status: String, statusColor: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.goldPrimary)
                .frame(width: 32, height: 32)
                .background(Color.surfaceDark)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textWhite)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.textDim)
            }
            Spacer()
            Text(status)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(statusColor.opacity(0.15))
                .foregroundColor(statusColor)
                .cornerRadius(4)
        }
    }
}
