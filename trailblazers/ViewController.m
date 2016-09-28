//
//  ViewController.m
//  trailblazers
//
//  Created by Nikhil Dange on 24/09/16.
//  Copyright © 2016 learning. All rights reserved.
//

#import "ViewController.h"
#import "DashboardViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

NSString *cobSession;
NSMutableArray *customerArrayViewControler;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self callTwitterF];
    customerArrayViewControler = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitClicked:(id)sender
{
    [self callBarlay];
    _submitButton.userInteractionEnabled = FALSE;
}

-(void)callBarlay
{
    NSString *string = @"http://api108448live.gateway.akana.com:80/customers";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:string
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSLog(@"JSON: %@", responseObject);
             
             customerArrayViewControler = [[NSMutableArray alloc] init];
             customerArrayViewControler = [[[responseObject objectAtIndex:0]objectForKey:@"accountList"] mutableCopy];
             
             [self callYodlee];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);
             _submitButton.userInteractionEnabled = TRUE;
         }];
}

-(void)callYodlee
{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"https://developer.api.yodlee.com/ysl/restserver/v1/cobrand/login"
           parameters:@{@"cobrandName": @"restserver",@"cobrandLogin":@"sbCobkunalj7",@"cobrandPassword":@"d86c5b1a-1e6f-425f-a0d2-8e9ad5da687a"}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  //              NSLog(@"JSON: %@", responseObject);
     
                  {
                  
                  cobSession = [[responseObject objectForKey:@"session"] objectForKey:@"cobSession"];
                  
                  AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://developer.api.yodlee.com"]];
                  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                  
                  cobSession = [NSString stringWithFormat:@"%@%@",@"cobSession=",cobSession];
                  
                  [manager.requestSerializer setValue:cobSession forHTTPHeaderField:@"Authorization"];
                  
                  [manager POST:@"/ysl/restserver/v1/user/login"
                     parameters:@{@"cobrandName": @"restserver",@"loginName":@"sbMemkunalj72",@"password":@"sbMemkunalj72#123"}
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            NSLog(@"JSON: %@", responseObject);
                            
                            {
                                NSString *userSe = [[[responseObject objectForKey:@"user"]objectForKey:@"session"] objectForKey:@"userSession"];
                                
                                AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://developer.api.yodlee.com"]];
                                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                                
                                NSString *value = [NSString stringWithFormat:@"%@,userSession=%@",cobSession,userSe];
                                
                                [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"cobsession"];
                                
                                [manager.requestSerializer setValue:value forHTTPHeaderField:@"Authorization"];
                                
                                [manager GET:@"/ysl/restserver/v1/accounts"
                                   parameters:@{@"cobrandName": @"restserver",@"status":@"ACTIVE",@"container":@"bank"}
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"JSON: %@ %@", responseObject,customerArrayViewControler);
                                          
                                          NSMutableArray *acc = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"account"]];
                                          
                                          for (id data in acc)
                                          {
                                              NSLog(@"%@",data);
                                              
                                              NSString *availBAL = [@[@"Avl : ",[[data objectForKey:@"availableBalance"] objectForKey:@"amount"],[[data objectForKey:@"availableBalance"] objectForKey:@"currency"] ] componentsJoinedByString:@" "];
                                              
                                              if ([availBAL containsString:@"USD"]) {
                                                  availBAL = [availBAL stringByReplacingOccurrencesOfString:@"USD" withString:@"\u0024"];
                                              }
                                              
                                              NSString *curBAL = [@[@"Cur : ",[[data objectForKey:@"currentBalance"] objectForKey:@"amount"],[[data objectForKey:@"currentBalance"] objectForKey:@"currency"] ] componentsJoinedByString:@" "];
                                              
                                              if ([curBAL containsString:@"USD"]) {
                                                  curBAL = [curBAL stringByReplacingOccurrencesOfString:@"USD" withString:@"\u0024"];
                                              }
                                              
                                              [customerArrayViewControler addObject:@{@"sortCode":[data objectForKey:@"id"],@"nickName":[data objectForKey:@"accountName"],@"accountType":availBAL,@"currentBalance":curBAL,@"yodlee":@"YES"}];
                                          }
                                          
                                          DashboardViewController *tView = [self.storyboard instantiateViewControllerWithIdentifier:@"dashboard"];
                                          tView.customerArray = customerArrayViewControler;
                                          [self presentViewController:[[UINavigationController alloc] initWithRootViewController:tView] animated:YES completion:nil];
                                          
                                          _submitButton.userInteractionEnabled = TRUE;
                                          
                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                          NSLog(@"Error: %@", error);
                                          _submitButton.userInteractionEnabled = TRUE;
                                      }];
                                
                            }

                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                            NSLog(@"Error: %@", error);
                            _submitButton.userInteractionEnabled = TRUE;
                        }];
                  
                  
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                  NSLog(@"Error: %@", error);
                  _submitButton.userInteractionEnabled = TRUE;
              }];
}

-(void)callTwitterF
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com"]];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager GET:@"/oauth/request_token"
      parameters:@{
                   @"oauth_consumer_key": @"yGaltAMRxrsEC3HJHeg6XMo0P",
                   @"oauth_token":@"48931768-Dojv0xkXrjJQaeypdvHkWSbxhJ5m4rhoGA8d52o4L",
                   @"oauth_signature_method":@"HMAC-SHA1",
                   @"oauth_timestamp":@"1474775864",
                   @"oauth_nonce":@"LUl7H1",
                   @"oauth_version":@"1.0",
                   @"oauth_signature":@"%2FRlgooozJnCY%2BT2VpsFsdfDi5lw%3D",
                   @"oauth_consumer_key":@"yGaltAMRxrsEC3HJHeg6XMo0P",
                   @"oauth_token":@"48931768-Dojv0xkXrjJQaeypdvHkWSbxhJ5m4rhoGA8d52o4L",
                   @"oauth_signature_method":@"HMAC-SHA1",
                   @"oauth_timestamp":@"1474775870",
                   @"oauth_nonce":@"4e7dc626aefe0f8ae83e16cff79fa0e5",
                   @"oauth_version":@"1.0",
                   @"oauth_signature":@"%2FTwONbiilrVJF4vQ%2ByAFlOVFaoM%3D"
                   }
     
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"Twitter JSON: %@", responseObject);
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             NSLog(@"Error: %@", error);

             NSString *filepath = [[NSBundle mainBundle] pathForResource:@"twitter1" ofType:@"txt"];
             NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
             
             NSLog(@"contents: %@", fileContents);
         }];
}

@end
