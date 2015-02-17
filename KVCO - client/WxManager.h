//
//  WxManager.h
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa.h>
#import "WxCondition.h"

@interface WxManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WxCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
