//
//  ViewController.m
//  AddToCartAnimationDemo
//
//  Created by Rakesh Pethani on 5/18/15.
//  Copyright (c) 2015 Rakesh Pethani. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface ViewController ()

@end

@implementation ViewController
{
    CGRect mainCartFrame;
    CGPoint mainCartCenter;
    NSMutableArray *itemImageCache;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainCartFrame = imgCart.frame;
    mainCartCenter = imgCart.center;
    itemImageCache = [NSMutableArray new];
    
    fruitNames = @[@"Apple",@"Orange",@"Banana",@"Strawberry",@"Mango"];
    fruitImages = @[@"apple.png",@"orange.png",@"banana.png",@"strawberry.png",@"mango.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview datasource and delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fruitNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    UIImageView * fruitImage = (UIImageView *)[cell viewWithTag:100];
    fruitImage.image = [UIImage imageNamed:[fruitImages objectAtIndex:indexPath.row]];
    
    UILabel * fruitName = (UILabel *)[cell viewWithTag:200];
    fruitName.text = [fruitNames objectAtIndex:indexPath.row];
    
    UIButton * addToCart = (UIButton *)[cell viewWithTag:300];
    [addToCart addTarget:self action:@selector(addItemToCartClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Helper functions

- (IBAction)addItemToCartClick:(UIButton*)sender
{
    CGPoint center = sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:FruitTable];
    NSIndexPath *indexPath = [FruitTable indexPathForRowAtPoint:rootViewPoint];
    
    [self animateItemToCart:indexPath];
}

- (void)animateItemToCart:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [FruitTable cellForRowAtIndexPath:indexPath];
    
    UIImageView * cellImage = (UIImageView *)[cell viewWithTag:100];
    CGRect frameRelativeToParent = [cellImage convertRect:cellImage.frame
                                                   toView:self.view];
    
    CGRect imageFrame = frameRelativeToParent;
    
    UIImageView *imgItem2 = [[UIImageView alloc] initWithFrame:imageFrame];
    imgItem2.image = [UIImage imageNamed:[fruitImages objectAtIndex:indexPath.row]];
    [self.view addSubview:imgItem2];
    [self.view bringSubviewToFront:imgItem2];
    [itemImageCache addObject:imgItem2];
    
    //Your image frame.origin from where the animation need to get start
    CGPoint viewOrigin = frameRelativeToParent.origin;
    viewOrigin.y = viewOrigin.y + imageFrame.size.height / 2.0f;
    viewOrigin.x = viewOrigin.x + imageFrame.size.width / 2.0f;
    
    imgItem2.frame = imageFrame;
    imgItem2.layer.position = viewOrigin;
    
    // Set up scaling
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(20.0f, 20.0f)]];
    resizeAnimation.fillMode = kCAFillModeForwards;
    resizeAnimation.removedOnCompletion = NO;
    
    
    // Set up rotation
    CABasicAnimation *rotateAnimmation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimmation.additive = YES;
    rotateAnimmation.removedOnCompletion = YES;
    rotateAnimmation.fillMode = kCAFillModeForwards;
    rotateAnimmation.fromValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(0)];
    rotateAnimmation.toValue = [NSNumber numberWithFloat:DEGREES_TO_RADIANS(360)];
    
    // Set up path movement
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3 :0.4 :1.0 :0.6];
    
    //Setting Endpoint of the animation
    CGPoint endPoint = mainCartCenter;
    endPoint.x -= 10;
    
    //to end animation in last tab use
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddLineToPoint(curvedPath, NULL, viewOrigin.x + 100, viewOrigin.y - 100);
    CGPathAddCurveToPoint(curvedPath, NULL, viewOrigin.x + 350, viewOrigin.y - 250, endPoint.x, viewOrigin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, rotateAnimmation, resizeAnimation, nil]];
    group.duration = 1.0f;
    group.delegate = self;
    [group setValue:imgItem2 forKey:@"imageViewBeingAnimated"];
    
    [imgItem2.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect cartFrame = mainCartFrame;
            cartFrame.size.height -= 10;
            cartFrame.origin.y += 20;
            imgCart.frame = cartFrame;
            
        } completion:^(BOOL finished) {
            
            imgCart.frame  = mainCartFrame;
        }];
        
        __block UIImageView * itemImage2 = [itemImageCache firstObject];
        
        if (itemImage2)
        {
            [itemImageCache removeObject:itemImage2];
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                itemImage2.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                [itemImage2 removeFromSuperview];
                itemImage2 = nil;
            }];
        }
    }
}

@end
