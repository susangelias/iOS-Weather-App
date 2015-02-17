//
//  WxCondition.h
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

#import <Mantle.h>

// this object has instructions on how to map JSON to Objective-C properties.

@interface WxCondition : MTLModel <MTLJSONSerializing>

// These are all of your weather data properties. You’ll be using a couple of them, but its nice to have access to all of the data in the event that you want to extend your app down the road.

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

// This is simply a helper method to map weather conditions to image files.
- (NSString *)imageName;

@end
