//
//  ViewController.h
//  AddToCartAnimationDemo
//
//  Created by Rakesh Pethani on 5/18/15.
//  Copyright (c) 2015 Rakesh Pethani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIImageView *imgItem;
    IBOutlet UIImageView *imgCart;
    
    NSArray * fruitNames;
    NSArray * fruitImages;
    IBOutlet UITableView *FruitTable;
}

@end

