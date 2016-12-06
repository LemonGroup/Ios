//
//  LGPersonListSingltonTests.m
//  Lemon Stat
//
//  Created by Arkadiy Grigoryanc on 06.12.16.
//  Copyright © 2016 Decidion. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LGPersonListSingleton.h"
#import "LGPerson.h"

@interface LGPersonListSingltonTests : XCTestCase

@end

@implementation LGPersonListSingltonTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSortEvents {
    // given
    LGPerson *person1 = [LGPerson personWithID:nil andName:@"Arkadiy"];
    LGPerson *person2 = [LGPerson personWithID:nil andName:@"Ivan"];
    LGPerson *person3 = [LGPerson personWithID:nil andName:@"Aleksandr"];
    LGPerson *person4 = [LGPerson personWithID:nil andName:@"Daria"];
    LGPerson *person5 = [LGPerson personWithID:nil andName:@"Yan"];
    LGPerson *person6 = [LGPerson personWithID:nil andName:@"Валентин"];
    LGPerson *person7 = [LGPerson personWithID:nil andName:@"Анастасия"];
    
    [LGPersonListSingleton sharedPersonList].persons = @[person1, person2, person3,
                                                         person4, person5, person6,
                                                         person7];
    [[LGPersonListSingleton sharedPersonList] sortList];
    
    NSArray *correctSortedArray = @[person3, person1, person4,
                                    person2, person5, person7,
                                    person6];
    
    // when
    NSArray *sortedWithTestingMethodArray = [LGPersonListSingleton sharedPersonList].persons;
    
    // then
    XCTAssertEqualObjects(correctSortedArray, sortedWithTestingMethodArray, @"Сортировка эвентов работает неправильно");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
