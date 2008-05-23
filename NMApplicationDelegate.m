//
//  NMApplicationDelegate.m
//  Next Meeting
//
//  Created by Nathan Spindel on 5/21/08.
//

#import "NMApplicationDelegate.h"
#import "CalCalendarStoreAdditions.h"

#define NO_EVENTS_TODAY		@"--"

@implementation NMApplicationDelegate

@synthesize nextEvents, statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsChanged:) name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];	
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateStatusItemText) name:NSWorkspaceDidWakeNotification object:NULL];

	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setAction:@selector(showCalendar)];
	
	[self updateStatusItemText];
}

- (void)finalize {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super finalize];
}

#pragma mark -

- (void)updateStatusItemText {
	int hours = 0;
	int minutes = 0;
	
	NSString *timeRemaining = NO_EVENTS_TODAY;
	NSString *eventTitle = nil;

	if (nextEvents == nil)
		self.nextEvents = [CalCalendarStore eventsOccurringToday];
	
	for (CalEvent *event in nextEvents) {
		// show the event if isn't "all day" and if it starts no earlier than 10 mins ago
		if (!event.isAllDay && [event.startDate timeIntervalSinceDate:[NSDate date]] > -660) {
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
			NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
			hours = [components hour];
			minutes = [components minute];
			
			if (hours == 0 && minutes == 0) {
				timeRemaining = @"Now!";
			} else if (hours == 0) {
				timeRemaining = [NSString stringWithFormat:@"%d min%@", minutes, ((minutes == 1 || minutes == -1) ? @"" : @"s")];
			} else {
				NSString *minFraction = nil;
				if (hours <= 5) {
					if (minutes >= 7 && minutes <= 22)
						minFraction = @"¼";
					else if (minutes >= 23 && minutes <= 37)
						minFraction = @"½";
					else if (minutes >= 38 && minutes <= 52)
						minFraction = @"¾";
				}

				timeRemaining = [NSString stringWithFormat:@"%d%@ hr%@", hours, (minFraction != nil ? [@" " stringByAppendingString:minFraction] : @""), (hours == 1 ? @"" : @"s")];
			}

			eventTitle = [NSString stringWithFormat:@"%@%@", event.title, ((event.location != nil) ? [@" at " stringByAppendingString:event.location] : @"")];
			break;
		}
	}
	
	if (hours == 0 && minutes >= -10 && minutes <= 15)
		statusItem.title = [[NSAttributedString alloc] initWithString:timeRemaining attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:14], NSFontAttributeName, nil]];
	else
		statusItem.title = timeRemaining;

	statusItem.toolTip = eventTitle;
	
	[self performSelector:@selector(updateStatusItemText) withObject:nil afterDelay:60];
}

- (void)eventsChanged:(NSNotification *)notification {
	self.nextEvents = nil; // invalidate the 24 hr event cache
	
	[self updateStatusItemText];
}

- (void)showCalendar {
	[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.apple.ical" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
}

@end
