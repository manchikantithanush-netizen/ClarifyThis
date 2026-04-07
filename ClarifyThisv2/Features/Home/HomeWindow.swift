import SwiftUI

// MARK: - HomeWindow (AppKit Wrapper)
class HomeWindow: NSWindow {
    init() {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let width: CGFloat = 950
        let height: CGFloat = 650
        let x = screenFrame.midX - (width / 2)
        let y = screenFrame.midY - (height / 2)
        let windowRect = CGRect(x: x, y: y, width: width, height: height)
        
        super.init(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        self.title = "ClarifyThis"
        self.isMovableByWindowBackground = true
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isReleasedWhenClosed = false
        
        let root = HomeRootView(window: self)
        let hosting = NSHostingView(rootView: root)
        hosting.autoresizingMask = [.width, .height]
        self.contentView = hosting
    }
}

// MARK: - Enums
enum SidebarTab: String, CaseIterable, Identifiable {
    case stats, history, settings
    var id: String { rawValue }
    var label: String {
        switch self {
        case .stats: return "Stats"
        case .history: return "History"
        case .settings: return "Settings"
        }
    }
    var icon: String {
        switch self {
        case .stats: return "chart.bar.fill"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Root View
struct HomeRootView: View {
    @ObservedObject var stats = StatsManager.shared
    @ObservedObject var firebase = FirebaseManager.shared
    
    @State private var selectedTab: SidebarTab = .stats
    @State private var showProfileMenu: Bool = false
    @State private var hoveredTab: SidebarTab? = nil
    @State private var hoveredProfile: Bool = false
    
    weak var window: NSWindow?
    
    var body: some View {
        HStack(spacing: 0) {
            // SIDEBAR
            Sidebar(
                selectedTab: $selectedTab,
                hoveredTab: $hoveredTab,
                hoveredProfile: $hoveredProfile,
                showProfileMenu: $showProfileMenu
            )
            .frame(width: 220)
            .background(Color.black.opacity(0.3))
            .zIndex(1)
            
            // CONTENT AREA
            ZStack {
                switch selectedTab {
                case .stats:
                    StatsContentView(stats: stats)
                case .history:
                    // Now imported from HistoryView.swift
                    HistoryContentView()
                case .settings:
                    SettingsContentView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
            .zIndex(0)
        }
        .frame(minWidth: 800, minHeight: 500)
        .edgesIgnoringSafeArea(.top)
        .overlay(
            Group {
                if showProfileMenu {
                    ProfileMenuPopover(isPresented: $showProfileMenu, window: window)
                        .padding(.leading, 10)
                        .padding(.bottom, 70)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(100)
                }
            },
            alignment: .bottomLeading
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showProfileMenu)
    }
}

// MARK: - Sidebar

struct Sidebar: View {
    @Binding var selectedTab: SidebarTab
    @Binding var hoveredTab: SidebarTab?
    @Binding var hoveredProfile: Bool
    @Binding var showProfileMenu: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text("ClarifyThis")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 30)
            
            ForEach(SidebarTab.allCases) { tab in
                SidebarTabButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: selectedTab == tab,
                    isHovered: hoveredTab == tab
                ) {
                    selectedTab = tab
                }
                .onHover { h in hoveredTab = h ? tab : nil }
            }
            
            Spacer()
            
            // Profile Button
            Button(action: {
                showProfileMenu.toggle()
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 32, height: 32)
                        Text(FirebaseManager.shared.userInitials)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("My Profile")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                        Text(FirebaseManager.shared.userEmail ?? "")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.white.opacity(hoveredProfile || showProfileMenu ? 0.1 : 0))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
            .onHover { h in hoveredProfile = h }
        }
    }
}

// MARK: - Profile Popover

struct ProfileMenuPopover: View {
    @Binding var isPresented: Bool
    weak var window: NSWindow?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let email = FirebaseManager.shared.userEmail {
                HStack {
                    Text(email)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                Divider().background(Color.gray.opacity(0.2))
            }
            Button(action: signOut) {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14))
                    Text("Sign Out").font(.system(size: 14))
                    Spacer()
                }
                .foregroundColor(.red.opacity(0.9))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { inside in
                if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() }
            }
        }
        .frame(width: 220)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
        .onTapGesture { }
    }

    private func signOut() {
        isPresented = false
        let alert = NSAlert()
        alert.messageText = "Sign Out"
        alert.informativeText = "Are you sure?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Sign Out"); alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            try? FirebaseManager.shared.signOut()
            window?.close()
            LoginWindow().makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

// MARK: - Components

struct SidebarTabButton: View {
    let icon, label: String
    let isSelected, isHovered: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).frame(width: 24)
                Text(label).fontWeight(isSelected ? .semibold : .regular)
                Spacer()
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(RoundedRectangle(cornerRadius: 10).fill(isSelected ? Color.white.opacity(0.1) : Color.clear))
        }
        .buttonStyle(.plain).padding(.horizontal, 10)
    }
}

struct StatsContentView: View {
    @ObservedObject var stats: StatsManager
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Dashboard").font(.largeTitle).bold().foregroundColor(.white).padding(.top, 40)
                HStack(spacing: 20) {
                    StatCard(icon: "sparkles", value: "\(stats.totalClarifications)", label: "Clarifications")
                    StatCard(icon: "text.quote", value: formatNumber(stats.totalWords), label: "Words Read")
                    StatCard(icon: "clock.fill", value: "\(stats.estimatedTimeSavedMinutes)m", label: "Time Saved")
                }
                Divider().background(Color.white.opacity(0.2))
                Text("Breakdown").font(.title2).bold().foregroundColor(.white)
                HStack(spacing: 20) {
                    MiniStatCard(icon: "camera.viewfinder", value: "\(stats.screenshotClarifications)", label: "Screenshots")
                    MiniStatCard(icon: "mic.fill", value: "\(stats.voiceClarifications)", label: "Voice Notes")
                }
                Spacer()
                Text("Member since \(formatDate(stats.firstUsedDate))").font(.caption).foregroundColor(.gray).padding(.top, 40)
            }
            .padding(40)
        }
    }
}

struct StatCard: View {
    let icon, value, label: String
    @State private var isHovered = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title).foregroundColor(.cyan)
            Text(value).font(.system(size: 32, weight: .bold)).foregroundColor(.white)
            Text(label).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(20)
        .background(Color.white.opacity(isHovered ? 0.1 : 0.05)).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1))
        .scaleEffect(isHovered ? 1.02 : 1.0).animation(.spring(response: 0.3), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

struct MiniStatCard: View {
    let icon, value, label: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.purple).font(.title2).frame(width: 40)
            VStack(alignment: .leading) {
                Text(value).font(.title3).bold().foregroundColor(.white)
                Text(label).font(.caption).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding().background(Color.white.opacity(0.05)).cornerRadius(12)
    }
}

struct SettingsContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings").font(.largeTitle).bold().foregroundColor(.white)
            Text("Preferences coming soon...").foregroundColor(.gray)
            Button("Reset Stats (Debug)") { StatsManager.shared.resetStats() }.buttonStyle(.bordered)
        }
    }
}

// MARK: - Helpers

// This helper view is kept here so both files can access it (Swift files in the same target see each other)
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    func updateNSView(_ view: NSVisualEffectView, context: Context) {
        view.material = material
        view.blendingMode = blendingMode
    }
}

private func formatNumber(_ num: Int) -> String {
    if num >= 1000 { return String(format: "%.1fK", Double(num) / 1000.0) }
    return "\(num)"
}

private func formatDate(_ date: Date?) -> String {
    guard let date = date else { return "Today" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter.string(from: date)
}
