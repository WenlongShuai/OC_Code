#import <Foundation/Foundation.h>
#include "Parsing.h"

@implementation CYG

- (NSNumber *)getCalGain:(NSString *)netName error:(NSError **)error
{
    if([netName isEqualToString:@"ODIN_CHARGE_1"])
    {
        return @(1);
    }
    else if([netName isEqualToString:@"ODIN_CHARGE_2"])
    {
        return @(2);
    }
    else
    {
        return @(1.5);
    }
    
}

- (NSNumber *)getCalOffset:(NSString *)netName error:(NSError **)error
{
    if([netName isEqualToString:@"ODIN_CHARGE_1"])
    {
        return @(0.123);
    }
    else if([netName isEqualToString:@"ODIN_CHARGE_2"])
    {
        return @(0.234);
    }
    else
    {
        return @(0.456);
    }
}

- (float)getCalValue:(NSString*)netName rawValue:(NSNumber*)rawValue mode :(NSString*)mode
{
    NSNumber *gain;
    NSNumber *offset;
    NSString *combiningStr;
    if([mode isEqualToString:@"RAW"])
    {
        return [rawValue floatValue];
    }
    //1.先将json文件读取为NSData类型的数据
    NSString *dataString = [NSString stringWithContentsOfFile:@"/Users/mac/Desktop/test.json" encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    //2.解析json数据
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    //3.取出key对应的value值，并再次存入字典中
    NSDictionary *calInfo = [dict objectForKey:@"CAL_INFO"];
    for(NSString *boards in calInfo)
    {
        NSDictionary *calNets = [calInfo objectForKey:boards];
        for(NSString *calNet in calNets)
        {
            //正则表达式  匹配ODIN_CHARGE_MEASURE_C_1字符串中的_1，为后面做准备
            NSString *pattern = @"[_]+\\d+.*";
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
            // 查找整个字符串，返回值是数组，数组中存放的是符合条件的字符串
            NSArray *results = [regex matchesInString:calNet options:0 range:NSMakeRange(0, calNet.length)];
            for (NSTextCheckingResult *result in results)
            {
                combiningStr = [netName stringByAppendingString:[calNet substringWithRange:result.range]];
            }
            //判断拼接后的字符串是否为相应通路的网络标号
            if([combiningStr isEqualToString:calNet])
            {
                NSDictionary *calRule = [calNets objectForKey:calNet];
                //分别获取key为start和stop的值
                int start = ((NSString *)[calRule objectForKey:@"start"]).intValue;
                int stop = ((NSString *)[calRule objectForKey:@"stop"]).intValue;
                //判断rawValue是否在start和stop之间，如果是，则获取该通路的gain和offset值
                if([rawValue floatValue] >= start && [rawValue floatValue] < stop)
                {
                    gain = [self getCalGain:calNet error:NULL];
                    offset = [self getCalOffset:calNet error:NULL];
                    goto OVER;
                }
            }
        }
    }
    
OVER:
    return [rawValue floatValue]*[gain floatValue]+[offset floatValue];
}

@end
