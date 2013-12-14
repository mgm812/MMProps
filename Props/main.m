//
//  main.m
//  Props
//
//  Created by mmy on 12/14/13.
//  Copyright (c) 2013 mmy. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 我一直不太明白为什么在dealloc里用self.property = nil会有问题;
 然后我在stackoverflow里找到了这个例子, 很简洁明了的说明了这个问题;
 最后的结论: 不要在 init 和 dealloc 里使用 self.property 这种方式;
            对于 self.property = nil 在dealloc使用没有什么问题, 但它会触发kvo;若这个属性用了kvo的话,就按苹果文档的要求写;
 你可以注视掉`kRigntWay`来看下效果;
 reference url: http://stackoverflow.com/questions/5932677/initializing-a-property-dot-notation/5932733#5932733
 */

#define kRightWay
//#define kRightWayOfInit
//#define kRightWayOfDealloc

#if defined kRightWay && !defined kRightWayOfInit && !defined kRightWayOfDealloc
    #define kAllowedOfInit      1
    #define kAllowedOfDealloc   1
#elif defined kRightWay && defined kRightWayOfInit && !defined kRightWayOfDealloc
    #define kAllowedOfInit      1
    #define kAllowedOfDealloc   0
#elif defined kRightWay && defined kRightWayOfDealloc
    #define kAllowedOfInit      0
    #define kAllowedOfDealloc   1
#else
    #define kAllowedOfInit      0
    #define kAllowedOfDealloc   0
#endif

@interface MONObjectA : NSObject
{
    NSMutableArray * array;
}

@property (nonatomic, retain) NSArray * array;

@end

@implementation MONObjectA

@synthesize array;

- (id)init
{
    self = [super init];
    if (0 != self) {
        NSLog(@"%s, %@",__PRETTY_FUNCTION__, self);
        if (kAllowedOfInit) {
            array = [NSMutableArray new];
        }
        else {
            self.array = [NSMutableArray array];
        }
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, self);
    if (kAllowedOfDealloc) {
        [array release], array = nil;
    }
    else {
        self.array = nil;
    }
    [super dealloc];
}

@end

@interface MONObjectB : MONObjectA
{
    NSMutableSet * set;
}

@end

@implementation MONObjectB

- (id)init
{
    self = [super init];
    if (0 != self) {
        NSLog(@"%s, %@",__PRETTY_FUNCTION__, self);
        set = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, self);
    [set release], set = nil;
    [super dealloc];
}

- (void)setArray:(NSArray *)arg
{
    NSLog(@"%s, %@",__PRETTY_FUNCTION__, self);
    NSMutableSet * tmp = arg ? [[NSMutableSet alloc] initWithArray:arg] : nil;
    [super setArray:arg];
    [set release];
    set = tmp;
}

@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    [[MONObjectB new] release];
    
    /* the tool must be named 'Props' for this to work as expected, or you can just change 'Props' to the executable's name */
    system("leaks Props");
    
    [pool drain];
    return 0;
}

