import SwiftUI

@main
public struct AALDiamAdminApp: App {
    @StateObject private var authManager = BiometricAuthManager()
    @StateObject private var localDb = LocalVaultDatabase.shared

    public init() {
        // Customize appearance for dark luxury navigation
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 18/255, green: 21/255, blue: 29/255, alpha: 1)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    public var body: some Scene {
        WindowGroup {
            if !authManager.isUnlocked {
                FaceIDLockView(authManager: authManager)
            } else {
                MainTabView(localDb: localDb, authManager: authManager)
            }
        }
    }
}

struct FaceIDLockView: View {
    @ObservedObject var authManager: BiometricAuthManager

    var body: some View {
        ZStack {
            Color.obsidianBlack.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.goldPrimary, lineWidth: 2)
                        .frame(width: 88, height: 88)
                        .background(Color.surfaceDark)
                        .clipShape(Circle())

                    Image(systemName: "diamond.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.goldPrimary)
                }

                VStack(spacing: 6) {
                    Text("AALDIAM VAULT")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.goldPrimary)
                        .tracking(2)

                    Text("SUPERADMIN SECURITY GATE")
                        .font(.caption2)
                        .foregroundColor(.textMuted)
                        .tracking(1.5)
                }

                Spacer()

                Button(action: { authManager.authenticate() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "faceid")
                            .font(.title3)
                        Text("Unlock with Face ID")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.obsidianBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.goldPrimary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            authManager.authenticate()
        }
    }
}

struct MainTabView: View {
    @ObservedObject var localDb: LocalVaultDatabase
    @ObservedObject var authManager: BiometricAuthManager
    @State private var selectedTab: Int = 0

    private var pendingDraftsCount: Int {
        localDb.drafts.count { $0.syncStatus != "SYNCED" }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            VaultView(localDb: localDb, onAddNewClick: { selectedTab = 1 })
                .tabItem {
                    Label("Vault", systemImage: "diamond.fill")
                }
                .tag(0)

            AddDiamondView(localDb: localDb, onComplete: { selectedTab = 0 })
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .tag(1)

            SyncQueueView(localDb: localDb)
                .tabItem {
                    Label("Sync Queue", systemImage: "arrow.triangle.2.circlepath")
                }
                .badge(pendingDraftsCount > 0 ? pendingDraftsCount : 0)
                .tag(2)

            SettingsView(authManager: authManager)
                .tabItem {
                    Label("Settings", systemImage: "shield.fill")
                }
                .tag(3)
        }
        .accentColor(.goldPrimary)
    }
}
