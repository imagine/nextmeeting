//
//  CalCalendarStoreAdditions.h
//  Next Meeting
//
//  Created by Nathan Spindel on 5/21/08.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>


@interface CalCalendarStore (CalCalendarStoreAdditions)

+ (NSArray *)eventsOccurringToday;

@end
