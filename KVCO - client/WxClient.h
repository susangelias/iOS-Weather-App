//
//  WxClient.h
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

@import CoreLocation;
#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

//WXClient‘s sole responsibility is to create API requests and parse them;

@interface WxClient : NSObject

- (RACSignal *) fetchJSONFromURL:(NSURL *)url;
- (RACSignal *) fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *) fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *) fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
