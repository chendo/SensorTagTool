//
//  SensorTagTool.h
//  SensorTagTool
//
//  Created by Jack Chen on 8/03/2014.
//  Copyright (c) 2014 chendo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@interface SensorTagTool : NSObject<CBPeripheralDelegate, CBCentralManagerDelegate>

@property (nonatomic, strong) CBPeripheral *tag;
@property (nonatomic, strong) CBCentralManager *manager;

- (void)start;

@end
