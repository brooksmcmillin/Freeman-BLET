#import "BeaconNo.h";

static BeaconNo* inst = nil;

@implementation BeaconNo
@synthesize bNo;
-(id)init {
    if(self=[super init]) {
        self.bNo = 0;
    }
    return self;
}
+(BeaconNo*)instance {
    if (!inst) inst = [[BeaconNo alloc] init];
    return inst;
}
@end
