import SmartTubeIOSCore
import SwiftUI

// MARK: - ShortsPresentation
//
// Shared Identifiable wrapper used by BrowseView and ChannelView to present
// ShortsPlayerView via .fullScreenCover(item:).

struct ShortsPresentation: Identifiable {
    let id = UUID()
    let videos: [Video]
    let startIndex: Int
}

// MARK: - ChannelDestination
//
// Identifiable wrapper used to drive navigationDestination(item:) for channel navigation
// triggered by the .openChannel NotificationCenter event.

struct ChannelDestination: Identifiable, Hashable {
    let channelId: String
    var id: String { channelId }
}

// MARK: - Shared layout constants

/// tvOS: fixed 4 columns (flexible) — predictable across all TV sizes.
#if os(tvOS)
let videoGridColumns = [
    GridItem(.flexible(), spacing: 40),
    GridItem(.flexible(), spacing: 40),
    GridItem(.flexible(), spacing: 40),
    GridItem(.flexible(), spacing: 40),
]
let videoGridRowSpacing: CGFloat = 40
#else
let videoGridRowSpacing: CGFloat = 12

/// Narrowest a grid card may get before wide containers add another column.
let videoGridMinimumCardWidth: CGFloat = 300

/// The user's portrait/landscape column setting is the minimum; wide containers
/// (iPad, iPhone Duo inner display, large Split View panes) add columns so cards
/// keep a sensible size instead of stretching.
func videoGridColumnCount(_ settings: AppSettings, landscape: Bool, width: CGFloat) -> Int {
    let preferred = landscape ? settings.gridColumnsLandscape : settings.gridColumnsPortrait
    guard width > 0 else { return preferred }
    let fitting = Int((width + videoGridRowSpacing) / (videoGridMinimumCardWidth + videoGridRowSpacing))
    return max(preferred, fitting)
}

/// Fixed (not adaptive) columns avoid the rotation hit-test mismatch of issue #82.
func videoGridColumns(count: Int) -> [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: videoGridRowSpacing), count: count)
}

/// `LazyVGrid` of video cards whose column count follows the container width
/// (see `videoGridColumnCount`). Columns stay fixed `.flexible` items and the
/// grid's identity resets on every column-count change — a column change
/// without an identity reset is the wrong-video-tapped bug (#82).
struct VideoGrid<Content: View>: View {
    @Environment(SettingsStore.self) private var store
    @Environment(\.isLandscapeLayout) private var isLandscapeLayout
    @State private var width: CGFloat = 0
    /// Extra identity component; change it to force a grid rebuild.
    let resetToken: UUID?
    let content: () -> Content

    init(resetToken: UUID? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.resetToken = resetToken
        self.content = content
    }

    var body: some View {
        let count = videoGridColumnCount(store.settings, landscape: isLandscapeLayout, width: width)
        LazyVGrid(columns: videoGridColumns(count: count), spacing: videoGridRowSpacing, content: content)
            .id("\(resetToken?.uuidString ?? "")-\(count)")
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}
#endif

// MARK: - Layout orientation

private struct IsLandscapeLayoutKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` when the root window is wider than tall; set by `RootView`.
    var isLandscapeLayout: Bool {
        get { self[IsLandscapeLayoutKey.self] }
        set { self[IsLandscapeLayoutKey.self] = newValue }
    }
}

// MARK: - Accent color

extension AppSettings.AccentColorChoice {
    /// `nil` falls back to the `AccentColor` asset.
    public var color: Color? {
        switch self {
        case .system: return nil
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .mint: return .mint
        case .teal: return .teal
        case .blue: return .blue
        case .indigo: return .indigo
        case .purple: return .purple
        case .pink: return .pink
        }
    }

    var displayName: String {
        switch self {
        case .system: return String(localized: "Default", bundle: .module)
        case .red: return String(localized: "Red", bundle: .module)
        case .orange: return String(localized: "Orange", bundle: .module)
        case .yellow: return String(localized: "Yellow", bundle: .module)
        case .green: return String(localized: "Green", bundle: .module)
        case .mint: return String(localized: "Mint", bundle: .module)
        case .teal: return String(localized: "Teal", bundle: .module)
        case .blue: return String(localized: "Blue", bundle: .module)
        case .indigo: return String(localized: "Indigo", bundle: .module)
        case .purple: return String(localized: "Purple", bundle: .module)
        case .pink: return String(localized: "Pink", bundle: .module)
        }
    }

    /// Pre-tinted, because Picker menus re-tint template images with the current accent.
    var swatch: Image {
        #if canImport(UIKit)
        let tint = color.map { UIColor($0) } ?? UIColor(named: "AccentColor") ?? .systemBlue
        let base = UIImage(systemName: AppSymbol.colorSwatch) ?? UIImage()
        return Image(uiImage: base.withTintColor(tint, renderingMode: .alwaysOriginal))
        #else
        let tint = color.map { NSColor($0) } ?? NSColor(named: "AccentColor") ?? .systemBlue
        let base = NSImage(systemSymbolName: AppSymbol.colorSwatch, accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [tint]))
        return Image(nsImage: base ?? NSImage())
        #endif
    }
}

// MARK: - DownloadAlertItem

/// Shared alert payload used by views that trigger video downloads.
struct DownloadAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - AppSymbol
//
// Single source of truth for SF Symbol names used across the app.
// Use these constants instead of raw strings in Image(systemName:) and Label(..., systemImage:).

enum AppSymbol {
    // MARK: - Navigation tabs
    static let home = "house.fill"
    static let search = "magnifyingglass"
    static let library = "square.stack.fill"
    static let settings = "gearshape.fill"

    // MARK: - Navigation / chevrons
    static let chevronLeft = "chevron.left"
    static let chevronUp = "chevron.up"
    static let chevronDown = "chevron.down"

    // MARK: - Playback controls
    static let previousTrack = "backward.end.fill"
    static let nextTrack = "forward.end.fill"
    static let previousChapter = "backward.end.alt.fill"
    static let nextChapter = "forward.end.alt.fill"
    static let thumbsUp = "hand.thumbsup"
    static let thumbsDown = "hand.thumbsdown"

    // MARK: - Actions
    static let checkmark = "checkmark"
    static let xmark = "xmark"
    static let xmarkCircle = "xmark.circle.fill"
    static let share = "square.and.arrow.up"
    static let copyDoc = "doc.on.doc"
    static let download = "arrow.down.to.line"
    static let watchLater = "clock.badge"
    static let audioOnly = "waveform.circle"

    // MARK: - Status / info
    static let warning = "exclamationmark.triangle.fill"
    static let clock = "clock"
    static let questionCircle = "questionmark.circle"
    static let qrcode = "qrcode"
    static let colorSwatch = "circle.fill"

    // MARK: - People / account
    static let personCircle = "person.crop.circle"
    static let personRectangle = "person.crop.rectangle"
    static let personCircleQuestion = "person.crop.circle.badge.questionmark"
    static let personCircleWarning = "person.crop.circle.badge.exclamationmark"

    // MARK: - Content
    static let stackLayers = "square.stack"
    static let tvMediabox = "tv.and.mediabox"
    static let tvPlay = "play.tv"
}
