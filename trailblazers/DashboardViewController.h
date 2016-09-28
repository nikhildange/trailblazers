//
//  DashboardViewController.h
//  trailblazers
//
//  Created by Nikhil Dange on 24/09/16.
//  Copyright © 2016 learning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *dashboardSegmentControl;
@property (weak, nonatomic) IBOutlet UITableView *dashBoardTableView;
@property (strong, nonatomic) NSMutableArray *customerArray;

@end
