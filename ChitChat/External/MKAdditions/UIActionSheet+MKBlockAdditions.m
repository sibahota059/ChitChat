//
//  UIActionSheet+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//

#import "UIActionSheet+MKBlockAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static PhotoPickedBlock _photoPickedBlock;
static UIViewController *_presentVC;

@implementation UIActionSheet (MKBlockAdditions)

+(void) actionSheetWithTitle:(NSString*) title
                     message:(NSString*) message
                     buttons:(NSArray*) buttonTitles
                  showInView:(UIView*) view
                   onDismiss:(DismissBlock) dismissed                   
                    onCancel:(CancelBlock) cancelled
{    
    [UIActionSheet actionSheetWithTitle:title 
                                message:message 
                 destructiveButtonTitle:nil 
                                buttons:buttonTitles 
                             showInView:view 
                              onDismiss:dismissed 
                               onCancel:cancelled];
}

+ (void) actionSheetWithTitle:(NSString*) title                     
                      message:(NSString*) message          
       destructiveButtonTitle:(NSString*) destructiveButtonTitle
                      buttons:(NSArray*) buttonTitles
                   showInView:(UIView*) view
                    onDismiss:(DismissBlock) dismissed                   
                     onCancel:(CancelBlock) cancelled
{
    
    [UIActionSheet actionSheetWithTitle:title message:message destructiveButtonTitle:destructiveButtonTitle buttons:buttonTitles selectedIndex:-1 showInView:view onDismiss:dismissed onCancel:cancelled];
}


+ (void) actionSheetWithTitle:(NSString*) title
                      message:(NSString*) message
       destructiveButtonTitle:(NSString*) destructiveButtonTitle
                      buttons:(NSArray*) buttonTitles
                selectedIndex:(int) selectedIndex
                   showInView:(UIView*) view
                    onDismiss:(DismissBlock) dismissed
                     onCancel:(CancelBlock) cancelled
{
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_dismissBlock release];
    _dismissBlock  = [dismissed copy];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:(id)[self class]
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:destructiveButtonTitle 
                                                    otherButtonTitles:nil];
    actionSheet.tag = selectedIndex;
    
    for(NSString* thisButtonTitle in buttonTitles)
        [actionSheet addButtonWithTitle:thisButtonTitle];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    actionSheet.cancelButtonIndex = [buttonTitles count];
    
    if(destructiveButtonTitle)
        actionSheet.cancelButtonIndex ++;
    
    if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
    
    [actionSheet release];
    
}

+ (void) photoPickerWithTitle:(NSString*) title
                   showInView:(UIView*) view
                    presentVC:(UIViewController*) presentVC
                onPhotoPicked:(PhotoPickedBlock) photoPicked                   
                     onCancel:(CancelBlock) cancelled
{
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_photoPickedBlock release];
    _photoPickedBlock  = [photoPicked copy];
    
    [_presentVC release];
    _presentVC = [presentVC retain];
    
    int cancelButtonIndex = -1;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title 
                                                             delegate:(id)[self class]
													cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];

	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", @"")];
		cancelButtonIndex ++;
	}
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		[actionSheet addButtonWithTitle:NSLocalizedString(@"Photo library", @"")];
		cancelButtonIndex ++;
	}
    
	[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
	cancelButtonIndex ++;
	
    actionSheet.tag = kPhotoActionSheetTag;
	actionSheet.cancelButtonIndex = cancelButtonIndex;		 

	if([view isKindOfClass:[UIView class]])
        [actionSheet showInView:view];
    
    if([view isKindOfClass:[UITabBar class]])
        [actionSheet showFromTabBar:(UITabBar*) view];
    
    if([view isKindOfClass:[UIBarButtonItem class]])
        [actionSheet showFromBarButtonItem:(UIBarButtonItem*) view animated:YES];
    
    [actionSheet release];    
}


+ (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerEditedImage];
    if(!editedImage)
        editedImage = (UIImage*) [info valueForKey:UIImagePickerControllerOriginalImage];
    
    _photoPickedBlock(editedImage);
	[picker dismissViewControllerAnimated:YES completion:nil];
	[picker autorelease];
}


+ (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image selection and close the program
    [_presentVC dismissViewControllerAnimated:YES completion:nil];
	[picker autorelease];
    [_presentVC release];
    _cancelBlock();
}

+(void)actionSheet:(UIActionSheet*) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == [actionSheet cancelButtonIndex])
	{
		_cancelBlock();
	}
    else
    {
        if(actionSheet.tag == kPhotoActionSheetTag)
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                buttonIndex ++;
            }
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                buttonIndex ++;
            }
            
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)[self class];
            picker.allowsEditing = YES;
            
            if(buttonIndex == 1) 
            {                
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else if(buttonIndex == 2)
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;;
            }
            
            [_presentVC presentViewController:picker animated:YES completion:nil];
        }
        else
        {
            _dismissBlock((int)buttonIndex);
        }
    }
}

//+ (void)willPresentActionSheet:(UIActionSheet *)actionSheet
//{
//    NSInteger selectedIndex = actionSheet.tag;
//    NSArray *subViews = actionSheet.subviews;
//    NSMutableArray *buttons = [NSMutableArray array];
//    for (UIView *subView in subViews) {
//        if ([subView isKindOfClass:[UIButton class]])
//            [buttons addObject:subView];
//    }
//    for (int i = 0; i < buttons.count; i++) {
//        UIView *subview = [buttons objectAtIndex:i];
//        if ([subview isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)subview;
//            
//            if (selectedIndex >= 0 && selectedIndex < buttons.count && selectedIndex == i) {
//                //Show the tick mark
//                [button setImage:[UIImage imageNamed:@"check-option-set"] forState:UIControlStateNormal];
//                [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
//            }
//            else {
//                [button setImage:nil forState:UIControlStateNormal];
//            }
//             button.titleLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:21];
//            [button setTitleColor:[UIColor colorWithRed:62/255.0 green:35/255.0 blue:11/255. alpha:1.0] forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor colorWithRed:62/255.0 green:35/255.0 blue:11/255. alpha:1.0] forState:UIControlStateHighlighted];
//        }
//    }
//}
@end
