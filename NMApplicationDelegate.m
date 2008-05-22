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
	
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setAction:@selector(showCalendar)];
	
	[self updateStatusItemText];
}

- (void)finalize {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super finalize];
}

#pragma mark -

- (void)updateStatusItemText {
	int hours = 0;
	int minutes = 0;
	
	NSString *timeRemaining = NO_EVENTS_TODAY;

	if (nextEvents == nil)
		self.nextEvents = [CalCalendarStore eventsOccurringToday];
	
	for (CalEvent *event in nextEvents) {
		if (!event.isAllDay && [event.startDate compare:[NSDate date]] == NSOrderedDescending) {
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
			NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
			hours = [components hour];
			minutes = [components minute];
			
			timeRemaining = (hours == 0) ? [NSString stringWithFormat:@"%d mins", minutes] : [NSString stringWithFormat:@"%d hrs", hours];
		}
	}
	
	if (hours == 0 && minutes <= 15)
		[statusItem setTitle:[[NSAttributedString alloc] initWithString:timeRemaining attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:14], NSFontAttributeName, nil]]];		
	else
		[statusItem setTitle:timeRemaining];
	
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
