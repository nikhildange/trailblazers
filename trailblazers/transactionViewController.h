//
//  transactionViewController.h
//  trailblazers
//
//  Created by Nikhil Dange on 24/09/16.
//  Copyright © 2016 learning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface transactionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *transactionTableView;
@property (strong,nonatomic) NSArray *transactionArray;
@property BOOL pop;

@end
