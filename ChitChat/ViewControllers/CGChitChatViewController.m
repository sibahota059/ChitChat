//
//  CGChitChatViewController.m
//  ChitChat
//
//  Created by Neeraj Kumar on 12/07/14.
//  Copyright (c) 2014 CocoaGarage. All rights reserved.
//

#import "CGChitChatViewController.h"
#import "CGChitChatCollectionViewCell.h"
#import "CGConstants.h"
#import "CGChatManager.h"

static NSString * kMessageCellReuseIdentifier = @"MessageCell";
static int chatInputStartingHeight = 40;

@interface CGChitChatViewController ()
@property (strong, nonatomic) CGChitChatInputView * chatInput;
@property (strong, nonatomic) UICollectionView * chatCollectionView;
@end

@implementation CGChitChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setupChatInput];
        [self setupCollectionView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Chit Chat";
    
    // Add subviews.
    [self.view addSubview:self.chatCollectionView];
    [self scrollToBottom];
    [self.view addSubview:self.chatInput];
    
    // Register Keyboard Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)setupChatInput {
    self.chatInput = [[CGChitChatInputView alloc]init];
    self.chatInput.stopAutoClose = NO;
    self.chatInput.placeholderLabel.text = @"  Send A Message";
    self.chatInput.delegate = self;
    self.chatInput.backgroundColor = [UIColor colorWithWhite:1 alpha:0.825f];
}

- (void)setupCollectionView {
    // Set Up Flow Layout
    UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc]init];
    flow.sectionInset = UIEdgeInsetsMake(80, 0, 10, 0);
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumLineSpacing = 6;

    CGRect collectionViewFrame = CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - height(self.chatInput));
    self.chatCollectionView = [[UICollectionView alloc]initWithFrame:collectionViewFrame collectionViewLayout:flow];
    self.chatCollectionView.backgroundColor = [UIColor whiteColor];
    self.chatCollectionView.delegate = self;
    self.chatCollectionView.dataSource = self;
    self.chatCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.chatCollectionView registerClass:[CGChitChatCollectionViewCell class]
            forCellWithReuseIdentifier:kMessageCellReuseIdentifier];
}

#pragma mark CLEAN UP

- (void) removeFromParentViewController {
    
    [_chatInput removeFromSuperview];
    _chatInput = nil;
    
    [_messagesArray removeAllObjects];
    _messagesArray = nil;
    
    [self.chatCollectionView removeFromSuperview];
    self.chatCollectionView.dataSource = nil;
    self.chatCollectionView = nil;
    
    self.chatCollectionView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super removeFromParentViewController];
}



#pragma-mark Collection View delegate.

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary * message = _messagesArray[indexPath.row];
    static int offset = 20;
    
    if (!message[kMessageSize]) {
        NSString * content = [message objectForKey:@"content"];
        
        NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:15.0f];
        attributes[NSStrokeColorAttributeName] = [UIColor darkTextColor];
        
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:content
                                                                       attributes:attributes];
        
        // Here's the maximum width we'll allow our outline to be // 260 so it's offset
        int maxTextLabelWidth = maxBubbleWidth - outlineSpace;
        
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(maxTextLabelWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
        message[kMessageSize] = [NSValue valueWithCGSize:rect.size];
        return CGSizeMake(width(_chatCollectionView), rect.size.height + offset);
    }
    else {
        return CGSizeMake(_chatCollectionView.bounds.size.width, [message[kMessageSize] CGSizeValue].height + offset);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.messagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get Cell
    CGChitChatCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMessageCellReuseIdentifier
                                                                  forIndexPath:indexPath];
    
    // Set Who Sent Message
    NSMutableDictionary * message = _messagesArray[indexPath.row];
    
    // Set the cell
    if (_opponentBubbleColor) cell.opponentColor = _opponentBubbleColor;
    if (_userBubbleColor) cell.userColor = _userBubbleColor;
    cell.message = message;
    return cell;
    
}

#pragma mark SETTERS | GETTERS

- (void) setMessagesArray:(NSMutableArray *)messagesArray {
    _messagesArray = messagesArray;
    // Fix if we receive Null
    if (![_messagesArray.class isSubclassOfClass:[NSArray class]]) {
        _messagesArray = [NSMutableArray new];
    }
    [self.chatCollectionView reloadData];
}

- (void) setTintColor:(UIColor *)tintColor {
    _chatInput.sendBtnActiveColor = tintColor;
    _tintColor = tintColor;
}


#pragma mark CHAT INPUT DELEGATE

- (void)chatInputNewMessageSent:(NSString *)messageString {
    
    NSMutableDictionary * newMessageOb = [NSMutableDictionary new];
    newMessageOb[@"content"] = messageString;
    newMessageOb[kMessageRuntimeSentBy] = [NSNumber numberWithInt:kSentByUser];
    
    // Send the message to the peer.
    [[CGChatManager sharedInstance] sendMessage:messageString];
    [self addNewMessage:newMessageOb];
}

#pragma mark ADD NEW MESSAGE

- (void)addNewMessage:(NSDictionary *)message {
    if (_messagesArray == nil) {
      _messagesArray = [NSMutableArray new];
    }
    // preload message into array;
    [_messagesArray addObject:message];
    
    [self.chatCollectionView performBatchUpdates:^{
        [self.chatCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_messagesArray.count -1 inSection:0]]];
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

#pragma mark KEYBOARD NOTIFICATIONS

- (void) keyboardWillShow:(NSNotification *)note {
    
    if (!_chatInput.shouldIgnoreKeyboardNotifications) {
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        NSValue* keyboardFrameBegin = [keyboardAnimationDetail valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        int keyboardHeight = keyboardFrameBeginRect.size.height;
        
        _chatCollectionView.scrollEnabled = NO;
        _chatCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            self.chatCollectionView.frame = CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - chatInputStartingHeight - keyboardHeight);
        } completion:^(BOOL finished) {
            if (finished) {
                self.chatCollectionView.scrollEnabled = YES;
                self.chatCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
                [self scrollToBottom];
            }
        }];
    }
}

- (void) keyboardWillHide:(NSNotification *)note {
    
    if (!_chatInput.shouldIgnoreKeyboardNotifications) {
        NSDictionary *keyboardAnimationDetail = [note userInfo];
        UIViewAnimationCurve animationCurve = [keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        CGFloat duration = [keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        self.chatCollectionView.scrollEnabled = NO;
        self.chatCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:^{
            self.chatCollectionView.frame = CGRectMake(0, 0, ScreenWidth(), ScreenHeight() - height(_chatInput));
            
        } completion:^(BOOL finished) {
            if (finished) {
                self.chatCollectionView.scrollEnabled = YES;
                self.chatCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
                [self scrollToBottom];
            }
        }];
    }
}

#pragma mark -

- (void)scrollToBottom {
    if (self.messagesArray.count > 0) {
        static NSInteger section = 0;
        NSInteger item = [self collectionView:self.chatCollectionView numberOfItemsInSection:section] - 1;
        if (item < 0)  {
          item = 0;
        }
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        [self.chatCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
