#import "Sprite.h"

@interface Sprite()

@property (strong) GLKBaseEffect * effect;
@property (strong) GLKTextureInfo * textureInfo;

@end

@implementation Sprite
@synthesize enclosingRect = _enclosingRect;
@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize originalQuad = _originalQuad;
@synthesize textureInfo = _textureInfo;

- (id)initWithImage:(UIImage *)image {
    
    CGImageRef spriteImage = [image CGImage];
    
    CGRect fullRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    return [self initWithRect:spriteImage croppedTo:fullRect andManualFlip:NO];
}

- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip {
    CGImageRef spriteImage = [image CGImage];
    
    CGRect fullRect = CGRectMake(0.0f, 0.0f, image.size.width, (manualFlip ? -1 : 1) * image.size.height);
    
    return [self initWithRect:spriteImage croppedTo:fullRect andManualFlip:manualFlip];
}

- (id)initWithRect:(CGImageRef)img croppedTo:(CGRect)char_rect andManualFlip:(bool)manualFlip {
    return [self initWithRect:img croppedTo:char_rect andOriginalSz:CGSizeMake(char_rect.size.width, char_rect.size.height) andManualFlip:manualFlip];
}

- (id)initWithRect:(CGImageRef)img croppedTo:(CGRect)char_rect andOriginalSz:(CGSize)sz andManualFlip:(bool)manualFlip {
    if ((self = [super init])) {

        self.effect = [[GLKBaseEffect alloc] init];
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
        
    
        // 2
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:!manualFlip],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
    
        // 3
        NSError * error;
        // NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
        // 4
        self.textureInfo = [GLKTextureLoader textureWithCGImage:img options:options error:&error];
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }

        self.enclosingRect = manualFlip ? CGRectMake(char_rect.origin.x, char_rect.origin.y, char_rect.size.width, -char_rect.size.height) : char_rect;
        
        float sh = sz.height; // 512 // hard-coded for font files;
        float sw = sz.width; // 512 // hard-coded for font files;
        
        // TODO: Set up Textured Quad
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(char_rect.size.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, char_rect.size.height);
        newQuad.tr.geometryVertex = CGPointMake(char_rect.size.width, char_rect.size.height);
    
        float ix = char_rect.origin.x;
        float ox = ix + char_rect.size.width;
        float iy = sh - (char_rect.origin.y + char_rect.size.height);
        float oy = iy + char_rect.size.height;
    
        newQuad.bl.textureVertex = CGPointMake(ix/sw, iy/sh);
        newQuad.br.textureVertex = CGPointMake(ox/sw, iy/sh);
        newQuad.tl.textureVertex = CGPointMake(ix/sw, oy/sh);
        newQuad.tr.textureVertex = CGPointMake(ox/sw, oy/sh);
        
        self.quad = newQuad;
        self.originalQuad = newQuad;
    }
    
    return self;
}

- (void) draw {
    [self render];
}

- (void)render {
    
    // 1
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    
    // 2
    [self.effect prepareToDraw];
    
    // 3
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    // 4
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    // 5
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}

- (void)renderWithSize:(float)size atX:(int)x andY:(int)y {
    [self renderWithSize:size atX:x andXOffset:0 andY:y andYOffset:0];
}

- (void)renderWithSize:(float)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset {
    [self renderWithSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:NO flippedVertically:NO];
}

- (void)renderWithSize:(float)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert {
    
    self.enclosingRect = CGRectMake(x, y, self.enclosingRect.size.width, self.enclosingRect.size.height);
    x = x + xoffset;
    y = y + yoffset;
    
    // 1.5
    TexturedQuad newQuad = self.originalQuad;
    float qw = newQuad.br.geometryVertex.x - newQuad.bl.geometryVertex.x;
    float qh = newQuad.tl.geometryVertex.y - newQuad.bl.geometryVertex.y;
    
    qw *= size;
    qh *= size;
    
    newQuad.bl.geometryVertex = CGPointMake(x, y);
    newQuad.br.geometryVertex = CGPointMake(x + qw, y);
    newQuad.tl.geometryVertex = CGPointMake(x, y + qh);
    newQuad.tr.geometryVertex = CGPointMake(x + qw, y + qh);
    
    // if horz, flip bl and br, and tl and tr
    if (horz){
        newQuad.bl.geometryVertex = CGPointMake(x + qw, y);
        newQuad.br.geometryVertex = CGPointMake(x, y);
        newQuad.tl.geometryVertex = CGPointMake(x + qw, y + qh);
        newQuad.tr.geometryVertex = CGPointMake(x, y + qh);
    }
    
    // if vert, flip tl and bl, and tr and br
    if (vert){
        newQuad.bl.geometryVertex = CGPointMake(x + qw, y + qh);
        newQuad.br.geometryVertex = CGPointMake(x, y + qh);
        newQuad.tl.geometryVertex = CGPointMake(x + qw, y);
        newQuad.tr.geometryVertex = CGPointMake(x, y);
    }
    
    self.quad = newQuad;
    
    [self render];
}


@end