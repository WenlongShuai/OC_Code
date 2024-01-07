
@interface Parsing : NSObject
{
    
}

- (float)getCalValue:(NSString*)netName rawValue:(NSNumber*)rawValue mode :(NSString*)mode;
- (NSNumber *)getCalGain:(NSString *)netName error:(NSError **)error;
- (NSNumber *)getCalOffset:(NSString *)netName error:(NSError **)error;


@end
