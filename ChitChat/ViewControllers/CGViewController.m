//
//  CGViewController.m
//  ChitChat
//
//  Created by Neeraj Kumar on 11/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGViewController.h"
#import "CGChatManager.h"
#import "CGConstants.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CGUserManager.h"
#import "CGChitChatViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "CGChitChatCollectionViewCell.h"

@interface CGViewController ()<UITableViewDataSource, UITableViewDelegate, MCBrowserViewControllerDelegate>
@property (nonatomic, strong)UITableView *aTableView;
@property (nonatomic ,strong)NSMutableArray *connectedPeers; // array of PeerID display names
@property (nonatomic, strong)UIView *tableHeaderView;


@property (nonatomic)BOOL chatOpened; // IS chat controller visible;
@property (nonatomic)BOOL isAlertShown; // Is Alert shown already.
@property (nonatomic, strong) NSMutableArray *incomingMessages;
@end

@implementation CGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Chat Box";
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.aTableView];
    self.aTableView.tableHeaderView = [self tableHeaderView];
    self.connectedPeers = [NSMutableArray array];
    [self.aTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerStateChanged:) name:PeerStateChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:MessageReceivedNotification object:nil];
    
    // Start advertising.
    if ([CGUserManager currentPeer].peerName) {
        [[CGChatManager sharedInstance] startAdvertising];
    }
    
    self.chatOpened = NO;
    self.isAlertShown = NO;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
        view.backgroundColor = AppDarkBlueColor();
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
        [button setTitle:TapToBrowse forState:UIControlStateNormal];
        [button addTarget:self action:@selector(startBrowsing:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        _tableHeaderView = view;
        _tableHeaderView.alpha = 0.0;
    }
    return _tableHeaderView;
}

- (void)startBrowsing:(id)sender {
    [[[CGChatManager sharedInstance] browser] setDelegate:self];
    [self presentViewController:[[CGChatManager sharedInstance] browser] animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.chatOpened = NO; // Chat is not open.
    
    // Perform TableHeaderView animation.
    [UIView animateWithDuration:1.0 delay:0.6 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableHeaderView.frame = CGRectMake(self.tableHeaderView.frame.origin.x, self.tableHeaderView.frame.origin.y, CGRectGetWidth(self.tableHeaderView.frame), 50);
        self.tableHeaderView.alpha = 1.0;
        self.aTableView.tableHeaderView = self.tableHeaderView;
    } completion:^(BOOL finished) {
        [self.aTableView reloadData];
    }];
}

#pragma mark - Getters

- (UITableView *)aTableView {
    if (!_aTableView) {
        _aTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds),CGRectGetHeight(self.view.bounds))];
        _aTableView.delegate = self;
        _aTableView.dataSource = self;
        _aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _aTableView.showsVerticalScrollIndicator = NO;
        _aTableView.showsHorizontalScrollIndicator = NO;
    }
    return _aTableView;
}

#pragma mark - Datasource methods.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.connectedPeers.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = self.connectedPeers[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:30.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGChitChatViewController *chatController = [[CGChitChatViewController alloc] initWithNibName:nil bundle:nil];
    self.chatOpened = YES;
    [self.navigationController pushViewController:chatController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - MCBrowserViewControllerDelegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
     [[[CGChatManager sharedInstance] browser] dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [[[CGChatManager sharedInstance] browser] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification handlers.

- (void)peerStateChanged:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [self.connectedPeers addObject:peerDisplayName];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.aTableView reloadData];
            });
        }
        else if (state == MCSessionStateNotConnected) {
            if ([self.connectedPeers count] > 0) {
                int indexOfPeer = [self.connectedPeers indexOfObject:peerDisplayName];
                if (indexOfPeer != NSNotFound) {
                    [self.connectedPeers removeObjectAtIndex:indexOfPeer];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.aTableView reloadData];
                });
            }
        }
    }
}

- (void)messageReceived:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = notification.userInfo;
        if (self.chatOpened) {
            // Skip.
            CGChitChatViewController *controller = (CGChitChatViewController *)self.navigationController.visibleViewController;
            NSMutableDictionary *messageDict = [@{
                                          kMessageRuntimeSentBy: [NSNumber numberWithInt:kSentByOpponent],
                                          @"content": [[NSString alloc] initWithData:dict[@"data"] encoding:NSUTF8StringEncoding]
                                          } mutableCopy];
            [controller addNewMessage:messageDict];
        }
        else {
            // Add new message to array.
            if (!self.incomingMessages) {
                self.incomingMessages = [NSMutableArray array];
            }
            NSMutableDictionary *messageDict = [@{
                                                  kMessageRuntimeSentBy: [NSNumber numberWithInt:kSentByOpponent],
                                                  @"content": [[NSString alloc] initWithData:dict[@"data"] encoding:NSUTF8StringEncoding]
                                                  } mutableCopy];
            [self.incomingMessages addObject:messageDict];
            
            // IF Alert is not already shown then show the alert view that a new message has come.
            if (!self.isAlertShown) {
                MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
                UIAlertView *alertView =  [UIAlertView alertViewWithTitle:InviteToChat(peerID.displayName) message:nil cancelButtonTitle:@"NO" otherButtonTitles:@[@"YES"] onDismiss:^(int buttonIndex) {
                    self.isAlertShown = NO;
                    
                    [[[CGChatManager sharedInstance] browser] dismissViewControllerAnimated:YES completion:nil];
                    CGChitChatViewController *chatController = [[CGChitChatViewController alloc] initWithNibName:nil bundle:nil];
                    chatController.messagesArray = self.incomingMessages;
                    self.chatOpened = YES;
                    [self.navigationController pushViewController:chatController animated:YES];
                    
                } onCancel:^{
                    self.isAlertShown = NO;
                }];
                self.isAlertShown = YES;
                [alertView show];
            }
        }
    });
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
