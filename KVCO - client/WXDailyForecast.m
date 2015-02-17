//
//  WXDailyForecast.m
//  KVCO - client
//
//  Ryan Nystrom - Tutorial: iOS 7 Best Practises; A Weather App Case Study
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *) JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    return paths;
}
@end
