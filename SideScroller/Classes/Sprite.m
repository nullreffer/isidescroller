#import "Sprite.h"

@interface Sprite()

@property (strong) GLKBaseEffect * effect;
@property (strong) GLKTextureInfo * textureInfo;

@property bool manualFlip;

@end

@implementation Sprite
@synthesize position = _position;
@synthesize size = _size;
@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize originalQuad = _originalQuad;
@synthesize textureInfo = _textureInfo;
@synthesize manualFlip = _manualFlip;

- (id)initWithImage:(UIImage *)image {
    
    return [self initWithImage:image andManualFlip:NO];
}

- (id)initWithImage:(UIImage *)image andManualFlip:(bool)manualFlip {
    CGImageRef img = [image CGImage];
    
    if ((self = [super init])) {

        self.effect = [[GLKBaseEffect alloc] init];
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
        
        // 2
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:!manualFlip],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        self.manualFlip = manualFlip;
        
        // 3
        NSError * error;
        // NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
        // 4
        self.textureInfo = [GLKTextureLoader textureWithCGImage:img options:options error:&error];
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        float sh = image.size.height; // 512 // hard-coded for font files;
        float sw = image.size.width; // 512 // hard-coded for font files;
        
        // TODO: Set up Textured Quad
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(image.size.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, image.size.height);
        newQuad.tr.geometryVertex = CGPointMake(image.size.width, image.size.height);
    
        float ix = 0;
        float ox = ix + image.size.width;
        float iy = 0;
        float oy = iy + image.size.height;
    
        newQuad.bl.textureVertex = CGPointMake(ix/sw, iy/sh);
        newQuad.br.textureVertex = CGPointMake(ox/sw, iy/sh);
        newQuad.tl.textureVertex = CGPointMake(ix/sw, oy/sh);
        newQuad.tr.textureVertex = CGPointMake(ox/sw, oy/sh);
        
        // initial size is the full size
        self.size = image.size;
        
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

- (CGRect) enclosingRect{
    return CGRectMake(self.position.x, self.position.y, self.size.width, self.size.width);
}

- (void)renderWithSize:(CGSize)size atX:(int)x andY:(int)y {
    [self renderWithSize:size atX:x andXOffset:0 andY:y andYOffset:0];
}

- (void)renderWithSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset {
    [self renderWithSize:size atX:x andXOffset:xoffset andY:y andYOffset:yoffset flippedHorizontally:NO flippedVertically:NO];
}

- (void)renderWithSize:(CGSize)size atX:(int)x andXOffset:(int)xoffset andY:(int)y andYOffset:(int)yoffset flippedHorizontally:(bool)horz flippedVertically:(bool)vert {
    
    self.position = CGPointMake(x, y);
    self.size = size;
    
    x = x + xoffset;
    y = y + yoffset;
    
    // 1.5
    TexturedQuad newQuad = self.originalQuad;
    
    // restore texture before modifying geometry
    if (self.manualFlip) {
        newQuad.tl.textureVertex = self.quad.bl.textureVertex;
        newQuad.tr.textureVertex = self.quad.br.textureVertex;
        newQuad.bl.textureVertex = self.quad.tl.textureVertex;
        newQuad.br.textureVertex = self.quad.tr.textureVertex;
    } else {
        newQuad.bl.textureVertex = self.quad.bl.textureVertex;
        newQuad.br.textureVertex = self.quad.br.textureVertex;
        newQuad.tl.textureVertex = self.quad.tl.textureVertex;
        newQuad.tr.textureVertex = self.quad.tr.textureVertex;
    }
    
    float qw = newQuad.br.geometryVertex.x - newQuad.bl.geometryVertex.x;
    float qh = newQuad.tl.geometryVertex.y - newQuad.bl.geometryVertex.y;
    
    qw = size.width;
    qh = size.height;
    
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