//
//  CalCalendarStoreAdditions.m
//  Next Meeting
//
//  Created by Nathan Spindel on 5/21/08.
//

#import "CalCalendarStoreAdditions.h"


@implementation CalCalendarStore (CalCalendarStoreAdditions)

// return all events from (now - 20 mins) to (now + 24 hours)
+ (NSArray *)eventsOccurringToday {
	CalCalendarStore *defaultStore = [self defaultCalendarStore];
	
	NSPredicate *todayPredicate = [self eventPredicateWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-1200] endDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24] calendars:[defaultStore calendars]];
	NSArray *events = [defaultStore eventsWithPredicate:todayPredicate];
	
	return [events sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES]]];
}

@end
