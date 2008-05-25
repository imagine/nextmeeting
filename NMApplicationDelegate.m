/* Public domain */

#import "NMApplicationDelegate.h"
#import "CalCalendarStoreAdditions.h"
#import "CalEventAdditions.h"

#define NO_EVENTS_TODAY		@"--"


@implementation NMApplicationDelegate

@synthesize nextEvents, statusItem;

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsChanged:) name:CalEventsChangedExternallyNotification object:[CalCalendarStore defaultCalendarStore]];	
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(updateStatusItemText) name:NSWorkspaceDidWakeNotification object:NULL];

	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem.menu = statusItemMenu;
	statusItem.highlightMode = YES;
	
	[self updateStatusItem];
}

- (void)finalize {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[super finalize];
}

#pragma mark -

- (void)updateStatusItem {
	if (nextEvents == nil)
		self.nextEvents = [CalCalendarStore eventsOccurringToday];

	[self updateStatusItemTitle];
	[self updateStatusItemMenu];
	
	[self performSelector:@selector(updateStatusItem) withObject:nil afterDelay:60];	
}

- (void)eventsChanged:(NSNotification *)notification {
	self.nextEvents = nil; // invalidate the event cache
	
	[self updateStatusItem];
}

#pragma mark -

- (void)updateStatusItemTitle {
	NSString *timeRemaining = NO_EVENTS_TODAY;
	NSString *eventTitleAndLocation = nil;

	if ([nextEvents count] > 0) {
		CalEvent *event = [nextEvents objectAtIndex:0];

		eventTitleAndLocation = [NSString stringWithFormat:@"%@%@", event.title, ((event.location != nil) ? [@" at " stringByAppendingString:event.location] : @"")];		
				
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
		NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date] toDate:event.startDate options:0];
		int hours = [components hour];
		int minutes = [components minute];
		
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
	}
		
	NSDisableScreenUpdates();
	statusItem.title = timeRemaining;
	NSEnableScreenUpdates();

	statusItem.toolTip = eventTitleAndLocation;
}

- (void)updateStatusItemMenu {
	for (NSMenuItem *item in statusItemMenu.itemArray)
		if (item.tag == 0) [statusItemMenu removeItem:item];
	
	for (CalEvent *event in nextEvents) {
		NSMenuItem *eventMenuItem = [[NSMenuItem alloc] initWithTitle:event.title action:@selector(showEvent:) keyEquivalent:@""];
		eventMenuItem.representedObject = event;
		[statusItemMenu insertItem:eventMenuItem atIndex:[statusItemMenu indexOfItemWithTag:42]]; // insert above separator
	}
	
	if ([nextEvents count] == 0)
		[statusItemMenu insertItemWithTitle:@"No meetings today" action:nil keyEquivalent:@"" atIndex:0];
}

#pragma mark -

- (void)showEvent:(id)sender {
	CalEvent *event = (CalEvent*)[sender representedObject];
	[event show];	
}

@end
