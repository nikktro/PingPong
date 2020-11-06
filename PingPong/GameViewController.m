//
//  ViewController.m
//  PingPong
//
//  Created by Nikolay Trofimov on 04.11.2020.
//

#import "GameViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define HALF_SCREEN_WIDTH SCREEN_WIDTH/2
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT/2
#define MAX_SCORE 6

@interface GameViewController ()

@property (weak, nonatomic) UIImageView *paddleTop;
@property (weak, nonatomic) UIImageView *paddleBottom;
@property (weak, nonatomic) UIView *gridView;
@property (weak, nonatomic) UIView *ballView;
@property (weak, nonatomic) UITouch *topTouch;
@property (weak, nonatomic) UITouch *bottomTouch;
@property (weak, nonatomic) NSTimer * timer;
@property (nonatomic) float dx;
@property (nonatomic) float dy;
@property (nonatomic) float speed;
@property (strong, nonatomic) UILabel *scoreTop;
@property (strong, nonatomic) UILabel *scoreBottom;

@end


UIView* drawView(CGRect frame, UIColor* color) {
    UIView *grid = [[UIView alloc] initWithFrame:frame];
    grid.backgroundColor = [color colorWithAlphaComponent:0.5];
    return grid;
}

UIImageView* insertImage(NSString* named, CGRect frame) {
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:named]];
    image.frame = frame;
    image.contentMode = UIViewContentModeScaleAspectFit;
    return image;
}

UILabel* insertLabel(CGRect frame, UIColor* color, float size, NSString* text) {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = color;
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:UIFontWeightLight];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.multipleTouchEnabled = YES; // add multitouch
    
    [self config];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    [self newGame];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self resignFirstResponder];
}


- (void)config {
    
    // set background color
    self.view.backgroundColor = [UIColor colorWithRed:100.0/255.0 green:135.0/255.0 blue:191.0/255.0 alpha:1.0];
    
    // add grid
    UIView *grid = drawView(CGRectMake(0, HALF_SCREEN_HEIGHT - 2, SCREEN_WIDTH, 4),
                            [UIColor whiteColor]);
    [self.view addSubview:grid];
    self.gridView = grid;
    
    // add top paddle image
    UIImageView *top = insertImage(@"paddleTop",
                                   CGRectMake(30.0, 40.0, 90.0, 60.0));
    [self.view addSubview:top];
    self.paddleTop = top;
    
    // add bottom paddle image
    UIImageView *bottom = insertImage(@"paddleBottom",
                                      CGRectMake(30.0, SCREEN_HEIGHT - 90.0, 90.0, 60.0));
    [self.view addSubview:bottom];
    self.paddleBottom = bottom; // bug fix
    
    // add and hide ball
    UIView *ball = drawView(CGRectMake(self.view.center.x - 10.0, self.view.center.y - 10.0, 20.0, 20.0),
                            [UIColor whiteColor]);
    ball.layer.cornerRadius = 10.0;
    ball.hidden = YES;
    [self.view addSubview:ball];
    self.ballView = ball;

    // add top player score
    UILabel *scoreTop = insertLabel(CGRectMake(SCREEN_WIDTH - 70.0, HALF_SCREEN_HEIGHT - 70.0, 50.0, 50.0),
                                    [UIColor whiteColor], 40.0, @"0");
    [self.view addSubview:scoreTop];
    self.scoreTop = scoreTop;
    
    // add bottom player score
    UILabel *scoreBottom = insertLabel(CGRectMake(SCREEN_WIDTH - 70.0, HALF_SCREEN_HEIGHT + 20.0, 50.0, 50.0),
                                    [UIColor whiteColor], 40.0, @"0");
    [self.view addSubview:scoreBottom];
    self.scoreBottom = scoreBottom; // bug fix
    
}

// MARK: - Touch handling

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if (self.bottomTouch == nil && point.y > HALF_SCREEN_HEIGHT) {
            self.bottomTouch = touch;
            self.paddleBottom.center = point;
        } else if (self.topTouch == nil && point.y < HALF_SCREEN_HEIGHT) {
            self.topTouch = touch;
            self.paddleTop.center = point;
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if (touch == self.topTouch) {
            if (point.y > HALF_SCREEN_HEIGHT) {
                self.paddleTop.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
            } else {
                self.paddleTop.center = point;
            }
        } else if (touch == self.bottomTouch) {
            if (point.y < HALF_SCREEN_HEIGHT) {
                self.paddleBottom.center = CGPointMake(point.x, HALF_SCREEN_HEIGHT);
            } else {
                self.paddleBottom.center = point;
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch == self.topTouch) {
            self.topTouch = nil;
        } else if (touch == self.bottomTouch) {
            self.bottomTouch = nil;
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


// MARK: - Private area


- (void)displayMessage:(NSString *)message {
    [self stop];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ping Pong" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self checkScore];
    }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkScore {
    if ([self gameOver] != 0) {
        [self newGame];
    } else {
        [self reset];
        [self start];
    }
}

- (void)newGame {
    [self reset];
    
    self.scoreTop.text = @"0";
    self.scoreBottom.text = @"0";
    
    [self displayMessage:@"Are you ready?"];
}

- (int)gameOver {
    if ([self.scoreTop.text intValue] >= MAX_SCORE) {
        return 1;
    }
    if ([self.scoreBottom.text intValue] >= MAX_SCORE) {
        return 2;
    }
    return 0;
}

- (void)start {
    self.ballView.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    self.ballView.hidden = NO;
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0) target:self selector:@selector(animate) userInfo:nil repeats:YES];
    }
}

- (void)reset {
    if ((arc4random() % 2) == 0 ) {
        _dx = -1;
    } else {
        _dx = 1;
    }
    
    if (_dy != 0) {
        _dy = -_dy;
    } else if ((arc4random() % 2) == 0) {
        _dy = -1;
    } else {
        _dy = 1;
    }
    
    self.ballView.center = CGPointMake(HALF_SCREEN_WIDTH, HALF_SCREEN_HEIGHT);
    self.speed = 2;
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
    self.ballView.hidden = YES;
}

- (void)animate {
    self.ballView.center = CGPointMake(self.ballView.center.x + self.dx * self.speed,
                                       self.ballView.center.y + self.dy * self.speed);
    [self checkCollision:CGRectMake(0.0, 0.0, 20.0, SCREEN_HEIGHT) X:fabs(self.dx) Y:0];
    [self checkCollision:CGRectMake(SCREEN_WIDTH, 0.0, 20.0, SCREEN_HEIGHT) X:-fabs(self.dx) Y:0];
    
    if ([self checkCollision:self.paddleTop.frame X:(self.ballView.center.x - self.paddleTop.center.x) / 32.0 Y:1]) {
        [self increaseSpeed];
    }
    
    if ([self checkCollision:self.paddleBottom.frame X:(self.ballView.center.x - self.paddleBottom.center.x) / 32.0 Y:-1]) {
        [self increaseSpeed];
    }
    
    [self goal];
    
}

- (BOOL)checkCollision:(CGRect)rect X:(float)x Y:(float)y {
    if (CGRectIntersectsRect(self.ballView.frame, rect)) {
        if (x != 0) self.dx = x;
        if (y != 0) self.dy = y;
        return YES;
    }
    return NO;
}

- (BOOL)goal {
    if (self.ballView.center.y <= 0.0 || self.ballView.center.y >= SCREEN_HEIGHT) {
        
        if (self.ballView.center.y <= 0.0) {
            self.scoreBottom.text = [NSString stringWithFormat:@"%d", [self.scoreBottom.text intValue] + 1];
        } else {
            self.scoreTop.text = [NSString stringWithFormat:@"%d", [self.scoreTop.text intValue] + 1];
        }
                
        int gameOver = [self gameOver];
        (gameOver != 0) ? [self displayMessage:[NSString stringWithFormat:@"Player %i wins", gameOver]] : [self reset];

        return YES;
    }
    return NO;
}

- (void)increaseSpeed {
    self.speed += 0.5;
    if (self.speed >= 10.0) {
        self.speed = 10.0;
    }
}

@end
