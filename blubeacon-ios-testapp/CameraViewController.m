//
//  CameraViewController.m
//  blubeacon-ios-testapp
//
//  Created by Brooks McMillin on 2/26/17.
//  Copyright © 2017 Bluvision Inc. All rights reserved.
//

#import "CameraViewController.h"
#import "BeaconNo.h";

@interface CameraViewController ()

@end

@implementation CameraViewController

- (IBAction)takePhoto:(UIButton *)sender {
    
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"Chose Picture : %d", [BeaconNo instance].bNo);
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"Canceled Picture");
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)done:(UIButton *)sender {
    NSLog(@"Saving Text");
    
    NSString *urlstr = [NSString stringWithFormat:@"http://pivot.cyprian.world/api/pivot/PostUserImage"];
    NSURL *url = [NSURL URLWithString:urlstr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"----WebKitFormBoundary7MA4YWxkTrZu0gW";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    
    NSData *imageData;
    
    imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2f);
    
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
        [body appendData:[@"Content-Disposition: form-data; name=\"Files\"; filename=\"test.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // We now need to tell the receiver what content type we have
        // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
        [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
   /*
        [body appendData:[@"Content-Disposition: form-data; name=\"profilepic.png\"; filename=\"picture.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        // We now need to tell the receiver what content type we have
        // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    */
    
    // Now we append the actual image data
    [body appendData:[NSData dataWithData:imageData]];
    
    // and again the delimiting boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
   /* NSDictionary *dict;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
    [body appendData:jsonData];*/
    
    [request setHTTPBody:body];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
       NSLog(@"Response: %@", (NSString *)[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] );
    
    [self updateBoxContents:(NSString *)[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding]];
    
    
}

-(void)updateBoxContents:(NSString *) data
{
    int beaconID = [BeaconNo instance].bNo;
    
    NSLog(@"Saving Image Data");
    
    NSString *post = [NSString stringWithFormat:@"beaconID=%d&contents=%@", beaconID, data];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://freeman.brooksmcmillin.com/api/updatecontents.php"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    /*  NSData * data = [NSURLConnection sendSynchronousRequest:request
     returningResponse:&response
     error:&error];
     
     if (error == nil)
     {
     NSLog([NSString stringWithFormat:@"Response: %@", response]);
     }
     else
     {
     NSLog([NSString stringWithFormat:@"Error: %@", error]);
     }
     */
}

@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    [delegate sendDataToA:@"This is test data"];
    
}


@end
