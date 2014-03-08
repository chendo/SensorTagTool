//
//  main.m
//  SensorTagTool
//
//  Created by Jack Chen on 8/03/2014.
//  Copyright (c) 2014 chendo. All rights reserved.
//

#import "SensorTagTool.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        SensorTagTool *tool = [[SensorTagTool alloc] init];
        [tool start];
        [[NSRunLoop currentRunLoop] run];
        
        
    }
    return 0;
}

