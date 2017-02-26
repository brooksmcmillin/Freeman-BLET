//
//  CameraViewController.h
//  blubeacon-ios-testapp
//
//  Created by Brooks McMillin on 2/26/17.
//  Copyright © 2017 Bluvision Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property(nonatomic,assign)id delegate;


- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;
- (IBAction)done: (UIButton *)sender;
-(void)sendDataToA:(NSString *)string; //I am thinking my data is NSArray, you can use another object for store your information.


@end
