//
//  SensorTagTool.m
//  SensorTagTool
//
//  Created by Jack Chen on 8/03/2014.
//  Copyright (c) 2014 chendo. All rights reserved.
//

#import "SensorTagTool.h"

@interface SensorTagTool ()

@property (nonatomic, assign) char lastValue;

@end

@implementation SensorTagTool

- (instancetype)init
{
    if (self = [super init]) {
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.lastValue = 0x0;
    }
    return self;
}

- (void)start
{
    while (self.manager.state != CBCentralManagerStatePoweredOn) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    fprintf(stderr, "Searching for SensorTags...\n");
    
    [self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // YOLO
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (!self.tag && [peripheral.name isEqualToString:@"SensorTag"]) {
        self.tag = peripheral;
        [central connectPeripheral:peripheral options:nil];
        fprintf(stderr, "Connecting to %s\n", [[peripheral.identifier UUIDString] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.tag = peripheral;
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"FFE0"]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = peripheral.services;
    if (services.count == 0) {
        fprintf(stderr, "No valid services found, trying again.\n");
        [self.manager cancelPeripheralConnection:peripheral];
        self.tag = nil;
    }
    else {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFE1"]] forService:[peripheral.services firstObject]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    fprintf(stderr, "Enabling SimpleKeys...\n");
    [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics firstObject]];
    fprintf(stderr, "Ready.\n");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    char value;
    [characteristic.value getBytes:&value length:1];
    
    NSMutableDictionary *output = [NSMutableDictionary dictionary];
    output[@"uuid"] = [peripheral.identifier UUIDString];
    
    if (value & 0x1 && !(self.lastValue & 0x1)) {
        output[@"button"] = @"right";
        output[@"event"] = @"down";
    }
    
    if (!(value & 0x1) && (self.lastValue & 0x1)) {
        output[@"button"] = @"right";
        output[@"event"] = @"up";
    }
    
    if (value & 0x2 && !(self.lastValue & 0x2)) {
        output[@"button"] = @"left";
        output[@"event"] = @"down";
    }

    if (!(value & 0x2) && (self.lastValue & 0x2)) {
        output[@"button"] = @"left";
        output[@"event"] = @"up";
    }

    NSData *data = [NSJSONSerialization dataWithJSONObject:output options:0 error:nil];
    printf("%s\n", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] cStringUsingEncoding:NSUTF8StringEncoding]);
    self.lastValue = value;
    
}
@end
