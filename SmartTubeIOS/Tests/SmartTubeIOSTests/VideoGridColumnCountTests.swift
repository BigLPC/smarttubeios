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
        var s = AppSettings()
        s.gridColumnsPortrait = portrait
        s.gridColumnsLandscape = landscape
        return s
    }

    @Test("Unmeasured width falls back to the setting")
    func zeroWidthUsesSetting() {
        let s = settings(portrait: 2, landscape: 3)
        #expect(videoGridColumnCount(s, landscape: false, width: 0) == 2)
        #expect(videoGridColumnCount(s, landscape: true, width: 0) == 3)
    }

    @Test("Phone-sized widths keep the user's setting")
    func phoneWidthsKeepSetting() {
        let s = settings(portrait: 2, landscape: 3)
        #expect(videoGridColumnCount(s, landscape: false, width: 370) == 2)
        #expect(videoGridColumnCount(s, landscape: true, width: 900) == 3)
    }

    @Test("Wide containers add columns")
    func wideWidthsAddColumns() {
        let s = settings(portrait: 2, landscape: 3)
        let minWidth = videoGridMinimumCardWidth
        let width = minWidth * 5 + videoGridRowSpacing * 4
        #expect(videoGridColumnCount(s, landscape: false, width: width) == 5)
    }

    @Test("Never fewer columns than the setting")
    func neverBelowSetting() {
        let s = settings(portrait: 4, landscape: 5)
        #expect(videoGridColumnCount(s, landscape: false, width: 400) == 4)
    }
}
#endif
