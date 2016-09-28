//
//  DashboardViewController.m
//  trailblazers
//
//  Created by Nikhil Dange on 24/09/16.
//  Copyright © 2016 learning. All rights reserved.
//

#import "DashboardViewController.h"
#import "transactionViewController.h"
#import "AFNetworking.h"

@interface DashboardViewController () <UITableViewDelegate,UITableViewDataSource>

@end

NSMutableArray *sortedArr;
NSString *timeStamp;

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    timeStamp = @"1474751050";
    
    self.title = @"Dashboard";
    
    _dashboardSegmentControl.selectedSegmentIndex = 0;
    [self sortArrayMethod];
    
    
    [self callGoogle1];
    [self callGoogle2];
    [self callGoogle3];
    [self callGoogle4];
    [self callGoogle5];
    [self callGoogle6];
    [self callGoogle7];
    [self callGoogle8];
    [self callGoogle9];
    [self callGoogle10];
    [self callGoogle11];
//    [self callTwitter];
}

-(void)sortArrayMethod
{
    sortedArr = [[NSMutableArray alloc] init];
    for (id data in _customerArray) {
        if (_dashboardSegmentControl.selectedSegmentIndex != 0 && [[data objectForKey:@"accountType"] isEqualToString:@"CREDIT_CARD_ACCOUNT"])
            {
                [sortedArr addObject:data];//[_customerArray objectAtIndex:[[NSDictionary alloc] initWithDictionary:i]];
            }
        if (_dashboardSegmentControl.selectedSegmentIndex == 0 && ![[data objectForKey:@"accountType"] isEqualToString:@"CREDIT_CARD_ACCOUNT"])
            {
                [sortedArr addObject:data];//[_customerArray objectAtIndex:[[NSDictionary alloc] initWithDictionary:i]];
            }
        if (_dashboardSegmentControl.selectedSegmentIndex == 2) {
            [sortedArr removeAllObjects];
            break;
        }
    }
}

- (IBAction)didTapDashboardSegment:(id)sender
{
    [self sortArrayMethod];
    [_dashBoardTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedArr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSString *currentBalance = @"NA",*idSTR=@"",*accTypeSTR=@"",*name=@"",*cardDetailSTR=@"";
    
    if ([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"sortCode"])
    {
        idSTR = [NSString stringWithFormat:@"%@",[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"accountNo"]];
        
        NSString *sortSTR = @" ";
        if([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"sortCode"])
        {
            sortSTR = [NSString stringWithFormat:@"%@",[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"sortCode"]];
        }
        
        if ([idSTR containsString:@"(null)"]) {
            idSTR = @" ";
        }
        
        idSTR = [NSString stringWithFormat:@"%@ %@",sortSTR,idSTR];
    }
    if ([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"accountType"])
    {
    accTypeSTR = [NSString stringWithFormat:@"%@",[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"accountType"]];
    }
    if([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"nickName"])
    {
    name = [NSString stringWithFormat:@"%@",[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"nickName"]];
    }
    
    if([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"currentBalance"])
    {
        currentBalance = [NSString stringWithFormat:@"%@",[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"currentBalance"]];
    }
    else if ([[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"] objectForKey:@"currentBalance"])
    {
        currentBalance = [NSString stringWithFormat:@"%@",[[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"] objectForKey:@"currentBalance"]];
    }
    
    if ([currentBalance containsString:@" "]) {
        currentBalance = [NSString stringWithFormat:@"%@ ", currentBalance];
    }
    else{
        currentBalance = [NSString stringWithFormat:@"%@ \u20ac", currentBalance];
    }
    
    if ([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"])
    {
        NSDictionary *card = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"];
        
        cardDetailSTR = [@[@"DEBIT",[card objectForKey:@"cardNumber"],@"    ",@"\u20ac",[card objectForKey:@"currentBalance"]] componentsJoinedByString:@" "];
    }
    
    UILabel *sortid = [cell viewWithTag:101];
    [sortid setText:idSTR];
    
    UILabel *accType = [cell viewWithTag:102];
    [accType setText:accTypeSTR];
    
    UILabel *accName = [cell viewWithTag:201];
    [accName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [accName setText:name];
    
    UIButton *accBal = [cell viewWithTag:202];
    [accBal setTitle:currentBalance forState:UIControlStateNormal];
    
    UILabel *cardInfo = [cell viewWithTag:301];
    [cardInfo setText:cardDetailSTR];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *accId = @"";
    if([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"customerId"])
    {
        accId = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"customerId"];
    }
    else if ([[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"] objectForKey:@"currentBalance"])
    {
        accId = [[[sortedArr objectAtIndex:indexPath.row] objectForKey:@"card"] objectForKey:@"customerId"];
    }
    else if ([[sortedArr objectAtIndex:indexPath.row] objectForKey:@"yodlee"]) {
        NSString *accIdYodlee = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"sortCode"];
        [self callYodleeTransaction:accIdYodlee];
    }
    
    if ([accId length]>0) {
        [self callBarclay:accId];
    }
}

-(void)callBarclay:(NSString*)accId
{
    NSString *string = [NSString stringWithFormat:@"%@%@%@",@"https://api108567live.gateway.akana.com:443/accounts/",accId,@"/transactions"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:string
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             transactionViewController *tView = [self.storyboard instantiateViewControllerWithIdentifier:@"transactionid"];
             tView.transactionArray = responseObject;
             [self presentViewController:[[UINavigationController alloc] initWithRootViewController:tView] animated:YES completion:nil];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
         }];
}

-(void)callYodleeTransaction:(NSString*)accId
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://developer.api.yodlee.com"]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"cobsession"];
    
    [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    
    [manager GET:@"/ysl/restserver/v1/transactions"
      parameters:@{@"cobrandName": @"restserver",@"accountId":accId,@"container":@"bank",@"fromDate":@"1992-10-26",@"toDate":@"2016-09-25"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"JSON: %@", responseObject);
             
             NSMutableArray *transactionArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"transaction"]];
             
             transactionViewController *tView = [self.storyboard instantiateViewControllerWithIdentifier:@"transactionid"];
             tView.transactionArray = transactionArray;
             
             tView.pop = FALSE;
             if ([[NSString stringWithFormat:@"%@",accId] isEqual:[NSString stringWithFormat:@"%@",@"10284308" ]]) {
                 tView.pop = TRUE;
             }
             
             [self presentViewController:[[UINavigationController alloc] initWithRootViewController:tView] animated:YES completion:nil];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
         }];
}

-(void)callTwitter
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com"]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSString *value = @"Authorization: OAuth oauth_consumer_key=\"ZZfRd6nFkEaCtv49URFzTF32o\", oauth_nonce=\"998edcd33900906e0ed9d11f54e10e5b\", oauth_signature=\"otUWorSvl#2FxYCyyvDEfPCO6r9ds%3D\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"1474751050\", oauth_token=\"48931768-Dojv0xkXrjJQaeypdvHkWSbxhJ5m4rhoGA8d52o4L\", oauth_version=\"1.0\"";
    
    [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
    
    [manager GET:@"/1.1/statuses/user_timeline.json"
      parameters:@{
                   @"screen_name": @"@realDonaldTrump",
                   @"count":@"100",
                   @"oauth_consumer_key":@"ZZfRd6nFkEaCtv49URFzTF32o",
                   @"oauth_token":@"48931768-Dojv0xkXrjJQaeypdvHkWSbxhJ5m4rhoGA8d52o4L",
                   @"oauth_signature_method":@"HMAC-SHA1",
                   @"oauth_timestamp":timeStamp,
                   @"oauth_nonce":@"",
                   @"oauth_version":@"1.0",
                   @"oauth_signature":@"otUWorSvl%2FxYCyyvDEfPCO6r9ds%3D"
                   }
     
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Twitter JSON: %@", responseObject);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
         }];
}


-(void)callGoogle1
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"#barclays #DigitalEagles Hahaha. What a load of marketing BS. An insult. Just a load of CHEAP amateurs. In the kingdom of the blind ..."
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle2
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @" left #barclays asked for overdraft agent went over my finances in store out loud.& I was told I was lying. Bet she has a good email address"
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle3
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeEntities?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"British lender Barclays is keen on being a research and development engine for financial services industry and is making significant investments in this space, according to Barclays India Chief Operating Officer Ram Gopal. Globally, there has been some disruption in financial services in recent times... As a response the industry is investing in innovation, Gopal told PTI here without disclosing the quantum of investment in this. Barclays is serious about being a research and development engine for financial services, and is investing in this space, he added. Speaking about India as a hub for fintech innovation for the bank, he said Barclays has over 29,000 people employed directly or through its partners, and a third of the group's executive committee are Indians. There is a buzz in India, he said. In the past decade, it has been around cost arbitrage; to get things done cheaper in India. But now we are actually going up the value chain. Some of the high-end work happens right here, he pointed out. The bank is conducting a hackathon, or a collaboration for computer programming in banking space, simultaneously in Mumbai and Manchester, Britain over the weekend to develop solutions for the bank ahead of the revised payment services directive (PSD2) in Europe, he explained. The hackathon, facilitated through its fintech innovation platform, Rise, has over 1,000 participants and 20 enabling partners, including Google, IBM, Amazon Web Services, Microsoft, Twitter, Cisco, Nasscom's 10,000 Startups among others. Barclays launched the Rise programme here in June. This is its sixth site globally, following London, Manchester, New York, Cape Town and Tel Aviv hubs. The Rise Mumbai chapter was set up to provide a physical site for fintech companies, offering a co-working environment, event spaces and meeting rooms. The investment in Rise has been made for three strategic reasons; to connect, co-create, and commercialise to scale, Gopal explained. We want to be engaged and create a digital community across the globe, and co-create solutions that could potentially define the shape of the financial services industry, he added. For the first time, the bank has opened up its 'application programming interface', to enable fintech startups participating in the hackathon to come up with collaborative solutions over the two next days."
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeEntities JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle4
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeEntities?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Low interest rates and changes in the workings of global bond markets create a toxic combination that could produce scary trading conditions for investors, according to Barclays  (BCS)  CEO Jes Staley. Staley, speaking at a board meeting of the $129 billion pension fund Teacher Retirement System of Texas in Austin, offered one example of how distorted markets have already become: Many investors are now regularly betting on bonds to rise in price while stock investors hunt for yield in the form of dividends from regulated companies like utilities. Historically, most investors sought out bonds for their stability and yield, in the form of coupon payments, and bought stocks for price gains. It has completely flipped the calculation of values in the debt and equity markets, Staley said It's all fine and good right now, but at some point, this is going to unwind, and when it unwinds, what it means to Texas Teachers and Barclays, I think it's scary. You're going to have one hell of a navigation. Staley joins an increasing chorus of top financial executives, including the hedge fund managers Ray Dalio of Bridgewater and Paul Singer of Elliott Management, who have expressed concern about the potential for heightened volatility as central banks in the U.S., Japan and Europe grapple with historically low or even negative interest rates. There's little room for monetary policymakers to cut rates further to stimulate the economy in the event of a downturn, and higher rates could lead to steep losses for bond and stock investors alike. JPMorgan Chase (JPM) CEO Jamie Dimon said this month that the U.S. Federal Reserve needs to raise rates to avoid losing credibility. Eric Rosengren, president of the Federal Reserve Bank of Boston, said today that further delays could increase the risk of imbalances in financial markets. Gently backing the economy away from such imbalances has proven to be very difficult in the past, Rosengren said in a statement. Staley, who previously worked at JPMorgan as one of Dimon's top lieutenants, said he spoke to the Texas pension fund at the request of its chief investment officer, Thomas Britton Britt Harris IV, himself a former CEO of Dalio's Bridgewater. Staley also described the Italian and Spanish banking systems, and a significant part of the German banking system, as being underwater."
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeEntities JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle5
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Barclays and an Israel-based start-up company have carried out what they say is the world's first trade transaction using blockchain technology, cutting a process that normally takes between seven and 10 days to less than four hours."
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle6
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Just had the worst ever service from #barclays So disappointed. What a way to run a business!"
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}
-(void)callGoogle7
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Four UK banks — Natwest, Royal Bank of Scotland, Santander and Ulster Bank — made Android Pay available to their customers but one of the country’s largest financial institutions is still holding out."
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle8
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Yes, we mis-sold but, even if we hadn't, the clients would have bought anyway, WHAT?"
                                             },
                                     @"encodingType":@"UTF8"};
        
//        NSLog(@"param for analytics %@",params);
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle9
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"GPs Sue Barclays Bank For £4m Over Mis-Selling Interest Rate Swaps"
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle10
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Can I open a new account? Yes, use online banking. Failed. Oh, you need PIN Sentry. Failed. Oh, you need to verify ID in a branch"
                                             },
                                     @"encodingType":@"UTF8"};

        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

-(void)callGoogle11
{
    {
        NSURL *url = [NSURL URLWithString:@"https://language.googleapis.com/v1beta1/documents:analyzeSentiment?key=AIzaSyBxHMLXVDbge0h3BL7bv5To7xU6UWMlods"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set post method
        [request setHTTPMethod:@"POST"];
        // Set header to accept JSON request
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // Your params
        NSDictionary *params =     @{@"document": @{
                                             @"type": @"PLAIN_TEXT",
                                             @"content": @"Barclays CEO Predicts `Scary' Markets as Central Banks Test Limits"
                                             },
                                     @"encodingType":@"UTF8"};
//        NSLog(@"param for analytics %@",params);
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&err];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        // And finally, add it to HTTP body and job done.
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                         NSLog(@"param for analytics %@",params);
                                                 NSLog(@"documents:analyzeSentiment JSON: %@", responseObject);
                                                 
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 //                                                 NSLog(@"Error: %@", error);
                                             }];
        
        [operation start];
    }
}

@end
