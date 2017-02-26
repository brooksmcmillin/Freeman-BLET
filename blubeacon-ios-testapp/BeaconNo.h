//
//  BeaconNo.h
//  blubeacon-ios-testapp
//
//  Created by Brooks McMillin on 2/26/17.
//  Copyright © 2017 Bluvision Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BeaconNo : NSObject
@property (nonatomic, readwrite) int bNo;
-(id)init;
+(BeaconNo*)instance;
@end
