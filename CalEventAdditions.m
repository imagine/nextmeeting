/* Public domain */

#import "CalEventAdditions.h"
#import "iCal.h"


@implementation CalEvent (CalEventAdditions)

- (void)show {
	iCalApplication *iCal = [SBApplication applicationWithBundleIdentifier:@"com.apple.iCal"];
	[iCal activate];
	
	NSArray *matchingCalendars = [[iCal calendars] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.calendar.uid]];
	if ([matchingCalendars count] > 0) {
		iCalCalendar *containingCalendar = [matchingCalendars lastObject];
		NSArray *matchingEvents = [[containingCalendar events] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid == %@", self.uid]];
		if ([matchingEvents count] > 0)
			[[matchingEvents lastObject] show];
    }
}

@end
