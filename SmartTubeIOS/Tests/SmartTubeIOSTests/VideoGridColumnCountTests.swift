#if !os(tvOS)
import CoreGraphics
import Testing

@testable import SmartTubeIOS
@testable import SmartTubeIOSCore

/// The user's portrait/landscape column setting is a minimum; wide containers
/// (iPad, iPhone Duo inner display) add columns instead of stretching cards.
@Suite("Video grid column count")
struct VideoGridColumnCountTests {

    private func settings(portrait: Int, landscape: Int) -> AppSettings {
        var appSettings = AppSettings()
        appSettings.gridColumnsPortrait = portrait
        appSettings.gridColumnsLandscape = landscape
        return appSettings
    }

    @Test("Unmeasured width falls back to the setting")
    func zeroWidthUsesSetting() {
        let config = settings(portrait: 2, landscape: 3)
        #expect(videoGridColumnCount(config, landscape: false, width: 0) == 2)
        #expect(videoGridColumnCount(config, landscape: true, width: 0) == 3)
    }

    @Test("Phone-sized widths keep the user's setting")
    func phoneWidthsKeepSetting() {
        let config = settings(portrait: 2, landscape: 3)
        #expect(videoGridColumnCount(config, landscape: false, width: 370) == 2)
        #expect(videoGridColumnCount(config, landscape: true, width: 900) == 3)
    }

    @Test("Wide containers add columns")
    func wideWidthsAddColumns() {
        let config = settings(portrait: 2, landscape: 3)
        let minWidth = videoGridMinimumCardWidth
        let width = minWidth * 5 + videoGridRowSpacing * 4
        #expect(videoGridColumnCount(config, landscape: false, width: width) == 5)
    }

    @Test("Never fewer columns than the setting")
    func neverBelowSetting() {
        let config = settings(portrait: 4, landscape: 5)
        #expect(videoGridColumnCount(config, landscape: false, width: 400) == 4)
    }
}
#endif
