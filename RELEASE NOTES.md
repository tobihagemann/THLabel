Version 1.4.8

- Fixed memory related crash.

Version 1.4.7

- Set maximum width to preferredMaxLayoutWidth for intrinsicContentSize.
- Fixed warning.

Version 1.4.6

- Removed support for IB_DESIGNABLE and IBInspectable, until it doesn't cause problems with CocoaPods. Please us `ibdesignable` branch, if you're interested in this feature and not using CocoaPods.
- Fixed bug regarding gradients introduced in last version.

Version 1.4.5

- Added support for IB_DESIGNABLE and IBInspectable, only available with Xcode 6.
- Added lineSpacing property.

Version 1.4.4

- Fixed memory leak.

Version 1.4.3

- Forcing clipsToBounds to YES, because of potential drawing issues.

Version 1.4.2

- Fixed unexpected truncation on iOS device.

Version 1.4.1

- Fixed crash, when text is nil.

Version 1.4

- Added logic for sizeThatFits and intrinsicContentSize.
- Added letterSpacing and automaticallyAdjustTextInsets properties.

Version 1.3.1

- Fixed memory leak.
- Updated example and screenshot.

Version 1.3

- Added fadeTruncatingMode property.
- Fixed overlapping non-opaque strokes.

Version 1.2

- Added innerShadowBlur, innerShadowOffset and innerShadowColor properties.

Version 1.1.7

- Fixed drawing, when frame is too small.

Version 1.1.6

- Fixed memory related crash.

Version 1.1.5

- Fixed text alignment for multi-line texts.

Version 1.1.4

- iOS 5 compatibilty restored. iOS 4 should also be compatible, but it's untested!

Version 1.1.3

- Fixed potential memory leaks.

Version 1.1.2

- Fixed memory related crash.

Version 1.1.1

- Fixed crash, which was caused by a premature release of a CFStringRef.
- Fixed crash, when text is nil.

Version 1.1

- Complete overhaul using Core Text. This means `CoreText.framework` is now required. Don't forget to add it to your project, if you're updating.
- This also fixes all problems with iOS 7 and should still be compatible with iOS 4 (untested yet, iOS 5 works).

Version 1.0.7

- Fixes regarding iOS 7 beta 5. Only tested on Simulator though.

Version 1.0.6

- Minor refactorings, because iOS Base SDK 6.0 or higher is required.

Version 1.0.5

- Fixed usage of compiler macros and backward compatibility.

Version 1.0.4

- iOS 7 compatibility: Breaks former look & feel of strokes though as described in README.

Version 1.0.3

- Fixed bug with text insets not applying correctly on stroke.

Version 1.0.2

- Fixed character spacing for centered stroke.

Version 1.0.1

- Added strokePosition property.

Version 1.0

- Initial release.
