#import "MainViewController.h"
#import "TBXML.h"
#import "Sprite.h"
#import "Game.h"

@interface MainViewController ()
@property (strong, nonatomic) EAGLContext *context;

@property Game* game;
@property NSDate *time;

@property(nonatomic, strong) TBXML *tbxml;

@end

@implementation MainViewController

@synthesize context = _context;

@synthesize game = _game;
@synthesize time = _time;
@synthesize tbxml = _tbxml;

-(void) loadGame
{
    // eventually pull the filename from config
    // and move this into map->loadBlocks
    
    self.tbxml = [TBXML newTBXMLWithXMLFile:@"gameconfig.xml" error:nil];
    TBXMLElement * rootXMLElement = self.tbxml.rootXMLElement;
    TBXMLElement *codeElement = [TBXML childElementNamed:@"code" parentElement:rootXMLElement];
    NSString *code = [TBXML textForElement:codeElement];
    
    self.game = [[Game alloc] initWithCode:code andConfig:rootXMLElement forView:self.view];
    
    self.time = [NSDate date];
    
    // UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    // [self.view addGestureRecognizer:tapRecognizer];

}

-(void) drawGame
{
    long ms = (double) ([self.time timeIntervalSinceNow] * -1000);
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [self.game draw:ms];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.drawableMultisample = GLKViewDrawableMultisample4X;

    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    [self loadGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self drawGame];
}

- (void)update {
    long ms = (double) ([self.time timeIntervalSinceNow] * -1000);
    [self.game update:ms];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.game handleTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.game handleTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.game handleTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event];
}

- (void) touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.game handleTouchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event];
}


@end