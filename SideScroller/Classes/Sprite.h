#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Sprite : NSObject

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@property CGRect enclosingRect;

- (id)initWithImage:(UIImage *)image ;
- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip;
- (id)initWithRect:(CGImageRef)img croppedTo:(CGRect)char_rect andManualFlip:(bool)manualFlip;
- (id)initWithRect:(CGImageRef)img croppedTo:(CGRect)char_rect andOriginalSz:(CGSize)sz andManualFlip:(bool)manualFlip;
- (void)renderWithSize:(float)size atX:(int)x andY:(int)y;
- (void)renderWithSize:(float)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset;
- (void)renderWithSize:(float)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert;

@property (assign) TexturedQuad originalQuad;
@property (assign) TexturedQuad quad;

@end
