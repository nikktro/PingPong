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
    
    [self config];
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
    self.paddleTop = bottom;
    
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
    self.scoreTop = scoreBottom;
    
}

@end
