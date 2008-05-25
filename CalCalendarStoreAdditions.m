/* Public domain */

#import "CalCalendarStoreAdditions.h"


@implementation CalCalendarStore (CalCalendarStoreAdditions)

// return all non-allday events from 20 minutes ago to midnight
+ (NSArray *)eventsOccurringToday {
	CalCalendarStore *defaultStore = [self defaultCalendarStore];
	
	NSPredicate *todayPredicate = [self eventPredicateWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-660] endDate:[NSDate dateWithNaturalLanguageString:@"tomorrow at midnight"] calendars:[defaultStore calendars]];
	NSArray *todaysEvents = [defaultStore eventsWithPredicate:todayPredicate];

	NSMutableArray *events = [NSMutableArray array];
	for (CalEvent *potentialEvent in todaysEvents)
		if (!potentialEvent.isAllDay && [potentialEvent.startDate timeIntervalSinceDate:[NSDate date]] > -660)
			[events addObject:potentialEvent];
	
	return events;
}

@end
