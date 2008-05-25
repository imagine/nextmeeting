/* Public domain */

#import "CalCalendarStoreAdditions.h"


@implementation CalCalendarStore (CalCalendarStoreAdditions)

// return all events from (now - 20 mins) to (now + 24 hours)
+ (NSArray *)eventsOccurringToday {
	CalCalendarStore *defaultStore = [self defaultCalendarStore];
	
	NSPredicate *todayPredicate = [self eventPredicateWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-1200] endDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24] calendars:[defaultStore calendars]];
	NSArray *todaysEvents = [defaultStore eventsWithPredicate:todayPredicate];

	NSMutableArray *events = [NSMutableArray array];
	for (CalEvent *potentialEvent in todaysEvents) {
		if (!potentialEvent.isAllDay && [potentialEvent.startDate timeIntervalSinceDate:[NSDate date]] > -660) {
			[events addObject:potentialEvent];
		}
	}
	
	return events;
}

@end
