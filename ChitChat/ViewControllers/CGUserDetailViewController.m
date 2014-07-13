//
//  CGUserDetailViewController.m
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGUserDetailViewController.h"
#import "CGUserManager.h"
#import "CGChatManager.h"

@interface CGUserDetailViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation CGUserDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - 

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup Views.
    [self.okButton addTarget:self action:@selector(okButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.displayNameTextField.delegate = self;
    self.displayNameTextField.textAlignment = NSTextAlignmentCenter;
    self.displayNameTextField.alpha = 0.0;
    self.okButton.alpha = 0.0;
    self.okButton.enabled = NO;
    [self.okButton setTitleColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0] forState:UIControlStateDisabled];
    
    // Set Initial frames.
    [self setInitialFrames];
    
    // Register for notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChangeText:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performStartAnimation];
}


#pragma mark - Frame Setting

- (void)setInitialFrames {
    CGRect frame = self.displayNameTextField.frame;
    frame.size.height = 50;
    frame.size.width = 220;
    frame.origin = CGPointMake(50, CGRectGetMidY(self.view.frame) + 100);
    self.displayNameTextField.frame = frame;
    
    // Set the button frame.
    CGRect btnFrame = self.okButton.frame;
    self.okButton.frame = CGRectMake(0, 0, btnFrame.size.width, btnFrame.size.height);
    self.okButton.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.displayNameTextField.frame) + 50);
}

- (void)setFinalFrames {
    CGRect frame = self.displayNameTextField.frame;
    frame.size.height = 50;
    frame.size.width = 220;
    frame.origin = CGPointMake(50, CGRectGetMidY(self.view.frame) - 60);
    self.displayNameTextField.frame = frame;
    
    // Set the button frame.
    CGRect btnFrame = self.okButton.frame;
    self.okButton.frame = CGRectMake(0, 0, btnFrame.size.width, btnFrame.size.height);
    self.okButton.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.displayNameTextField.frame) + 50);
}


#pragma mark Animation

- (void)performStartAnimation {
    [UIView animateWithDuration:1.0 delay:0.8 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFinalFrames];
        self.displayNameTextField.alpha = 1.0;
        self.okButton.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        [self.displayNameTextField becomeFirstResponder];
    }];
}

#pragma mark - Button Handlers.

- (void)okButtonClicked:(UIButton *)target {
    CGPeer *peer = [[CGPeer alloc] init];
    peer.peerName = self.displayNameTextField.text;
    
    // Save Peer.
    [CGUserManager savePeer:peer];
    
    // Peer saved. start advertising.
    [[CGChatManager sharedInstance] startAdvertising];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification handlers

- (void)onChangeText:(NSNotification *)notification {
    if (self.displayNameTextField.text.length > 0) {
        self.okButton.enabled = YES;
    }
    else {
        self.okButton.enabled = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
