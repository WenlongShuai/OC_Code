#import <Foundation/Foundation.h>

#include "Parsing.h"

int main(int argc, const char * argv[])
{
    Parsing *c = [Parsing new];
    float x = [c getCalValue:@"ODIN_CHARGE" rawValue:@(2000) mode:@"qqq"];
    NSLog(@"%f",x);

    return 0;
}
