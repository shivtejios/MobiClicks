//
//  Photo.h
//  MobiClicks
//
//  Created by Shiva Teja Celumula on 4/18/15.
//  Copyright (c) 2015 Mobiquity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSData * imageData;

@end
