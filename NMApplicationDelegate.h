/* Public domain */

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>


@interface NMApplicationDelegate : NSObject {
	NSStatusItem *statusItem;
	NSArray *nextEvents;
}

@property(retain) NSArray *nextEvents;
@property(retain) NSStatusItem *statusItem;

- (void)updateStatusItemText;

@end
