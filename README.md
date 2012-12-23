# THLabel

THLabel is a subclass of UILabel, which additionally allows shadow blur, stroke text and fill gradient.

![THLabel screenshot](https://raw.github.com/MuscleRumble/THLabel/master/screenshot.png "THLabel screenshot")

## Requirements

* iOS 4.0 or higher
* ARC enabled

## Installation

You only need 2 files:

- `THLabel.h`
- `THLabel.m`

You can create THLabels programmatically, or create them in Interface Builder by dragging an ordinary UILabel into your view and setting its class to THLabel.

## Properties

``` objective-c
	@property (nonatomic, assign) CGFloat shadowBlur;
```

Additionally to UILabel's shadowColor and shadowOffset, you can also set a shadow blur to soften the shadow.

``` objective-c
	@property (nonatomic, assign) CGFloat strokeSize;
	@property (nonatomic, strong) UIColor *strokeColor;
	@property (nonatomic, assign) THLabelStrokePosition strokePosition;
```

You can set an outer, centered or inner stroke by setting the strokePosition property. Default value is THLabelStrokePositionOutside. Other options are THLabelStrokePositionCenter and THLabelStrokePositionInside.

``` objective-c
	@property (nonatomic, strong) UIColor *gradientStartColor;
	@property (nonatomic, strong) UIColor *gradientEndColor;
	@property (nonatomic, copy) NSArray *gradientColors;
```

The gradient can consist of multiple colors, which have to be saved as UIColor objects in the gradientColors array. For more convenience, gradientStartColor and gradientEndColor will fill up the array accordingly.

``` objective-c
	@property (nonatomic, assign) CGPoint gradientStartPoint;
	@property (nonatomic, assign) CGPoint gradientEndPoint;
```

The starting and ending points of the gradient are in the range 0 to 1, where (0, 0) is the top-left and (1, 1) the bottom-right of the text. The default value for gradientStartPoint is (0.5, 0.2) and for gradientEndPoint it is (0.5, 0.8).

``` objective-c
	@property (nonatomic, assign) UIEdgeInsets textInsets;
```

Effects like stroke and shadow can't be drawn outside of the bounds of the label view. For labels that are not center-aligned, you may need to set text insets to move a bit away from the edge.

## Notes

THLabel respects (unlike UILabel) the contentMode property, which is used for vertical alignment. The textAlignment still has the higher priority, when it comes to horizontal alignment.

THLabels are slower to draw than UILabels, because it is heavily using Core Graphics, so be aware of that.

## Credits

Original source and inspiration from:

- FXLabel by Nick Lockwood, https://github.com/nicklockwood/FXLabel
- KSLabel by Kai Schweiger, https://github.com/vigorouscoding/KSLabel

## License

Distributed under the permissive zlib license. See the LICENSE file for more info.

## Contact

Tobias Hagemann

- http://www.tobiha.de/
- tobias.hagemann@gmail.com
- http://www.twitter.com/MuscleRumble