//
//  transactionViewController.m
//  trailblazers
//
//  Created by Nikhil Dange on 24/09/16.
//  Copyright © 2016 learning. All rights reserved.
//

#import "transactionViewController.h"
#import "AFNetworking.h"

@interface transactionViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation transactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Transactions";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_transactionArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *accountBalanceAfterTransactionSTR=@"NA",*descriptionSTR=@"",*moneyInSTR=@"",*moneyOutSTR=@"";

    
    if ([[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"description"] && ![[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"amount"])
    {
        descriptionSTR = [NSString stringWithFormat:@"%@",[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"description"]];
    }
    else if ([[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"category"])
    {
        descriptionSTR = [NSString stringWithFormat:@"%@",[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"category"]];
    }
    
    if ([[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"moneyIn"])
    {
        moneyInSTR = [NSString stringWithFormat:@"%@",[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"moneyIn"]];
    }
    
    if ([[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"moneyOut"])
    {
        moneyOutSTR = [NSString stringWithFormat:@"%@",[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"moneyOut"]];
    }
    
    if ([[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"accountBalanceAfterTransaction"])
    {
        NSDictionary *acc = [[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"accountBalanceAfterTransaction"];
        NSString *str = [NSString stringWithFormat:@"%@",[acc objectForKey:@"amount"] ];
 
        if ([str containsString:@"USD"]) {
                accountBalanceAfterTransactionSTR = [accountBalanceAfterTransactionSTR stringByReplacingOccurrencesOfString:@"USD" withString:@"\u0024"];
            }
        
        accountBalanceAfterTransactionSTR = [@[@" ",[acc objectForKey:@"amount"],@"\u20ac",[acc objectForKey:@"position"]] componentsJoinedByString:@" "];
    }
    
    UILabel *accountBalanceAfterTransaction = [cell viewWithTag:101];
    [accountBalanceAfterTransaction setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [accountBalanceAfterTransaction setText:descriptionSTR];
    
    UILabel *moneyInOut = [cell viewWithTag:102];
    
    NSString *moneySTR = moneyInSTR;
    
    if ([moneyInSTR isEqualToString:@"0.00"]) {
        moneySTR = moneyOutSTR;
    }
    
    if ([[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"runningBalance"]) {
        moneySTR = [NSString stringWithFormat:@"%@ %@",[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"runningBalance"] objectForKey:@"currency"],[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"runningBalance"] objectForKey:@"amount"]];
        
        if ([moneySTR containsString:@"USD"]) {
            moneySTR = [moneySTR stringByReplacingOccurrencesOfString:@"USD" withString:@"\u0024"];
        }
    }
    
    [moneyInOut setText:moneySTR];
    
    if ([[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"amount"]) {
        accountBalanceAfterTransactionSTR = [NSString stringWithFormat:@"%@ %@",[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"currency"],[[[_transactionArray objectAtIndex:indexPath.row] objectForKey:@"amount"] objectForKey:@"amount"]];
        
        if ([accountBalanceAfterTransactionSTR containsString:@"USD"]) {
            accountBalanceAfterTransactionSTR = [accountBalanceAfterTransactionSTR stringByReplacingOccurrencesOfString:@"USD" withString:@"\u0024"];
        }
    }
    
    UILabel *amountLBL = [cell viewWithTag:103];
    [amountLBL setText:accountBalanceAfterTransactionSTR];
    
    return cell;
}

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"open"])
    {
    if (_pop == true && indexPath.row == 3)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip of the Day"
                                                            message:@"You can use your Barclaycard Platinum Credit Card for any future payments to Texaco petrol station as Barclays will provide 10% Cashback on such transactions."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            _pop = false;
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"open"];
        }
    }
}

@end
