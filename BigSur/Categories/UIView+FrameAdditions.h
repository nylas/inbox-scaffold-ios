
@interface UIView (FrameAdditions)

- (void)setFrameY:(float)y;
- (void)setFrameX:(float)x;
- (void)shiftFrame:(CGPoint)offset;
- (void)shiftFrameUsingTransform:(CGPoint)offset;
- (void)setFrameOrigin:(CGPoint)origin;
- (void)setFrameSize:(CGSize)size;
- (void)setFrameCenter:(CGPoint)p;
- (void)setFrameWidth:(float)w;
- (void)setFrameHeight:(float)h;
- (void)setFrameSizeAndRemainCentered:(CGSize)desired;
- (void)multiplyFrameBy:(float)t;
- (CGPoint)topRight;
- (CGPoint)bottomRight;
- (CGPoint)bottomLeft;

@end
