//
//  BLUEddystoneIdentifier.h
//
//  Copyright (c) 2015 Bluvision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  BLUEddystoneIdentifier represents a UUID seperated into a 10 byte Namespace and a 6 byte instance, combined as a NSUUID.
 */
@interface BLUEddystoneIdentifier : NSObject <NSSecureCoding, NSCopying>

/**
 *  The namespace of this identifier (the first 10 bytes of the uniquie identifier)
 */
@property (nonatomic, readonly) NSData *namespaceIdentifier;

/**
 *  The instance of this identifier (the last 6 bytes of the unique identifier)
 */
@property (nonatomic, readonly) NSData *instanceIdentifier;

/**
 *  The Unique identifier
 */
@property (nonatomic, readonly) NSUUID *UUID;

/**
 *  Initializes an instance of Eddystone Identifier with the specified namespace and instance identifier objects.
 *
 *  @param namespaceIdentifer A namespace identifier, if length greater than 10 this will be truncated
 *  @param instanceIdentifier A instance identifier, if length greater than 6 this will be truncated.
 *
 *  @return Returns a newly initialize Eddystone identifier.
 */
- (instancetype)initWithNamespaceIdentifier:(NSData *)namespaceIdentifer instanceIdentifier:(NSData *)instanceIdentifier;

/**
 *  Initializes an instance of Eddystone Identifier with the speified UUID object
 *
 *  @param UUID A UUID to represent this identifier
 *
 *  @return Returns a newly initialized Eddystone identifier.
 */
- (instancetype)initWithUUID:(NSUUID *)UUID;

@end

NS_ASSUME_NONNULL_END
