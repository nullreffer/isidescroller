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

@property CGPoint position;
@property CGSize size;
@property float alpha;
@property (assign) TexturedQuad originalQuad;
@property (assign) TexturedQuad quad;

- (id)initWithImage:(UIImage *)image ;

- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip;

- (void)renderWithSize:(CGSize)size atX:(int)x andY:(int)y;

- (void)renderWithSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset;

- (void)renderWithSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert;

- (void)renderWithSize:(CGSize)size andRotation:(float)rotation atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert;

- (CGRect) enclosingRect;

@end
