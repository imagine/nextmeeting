/* Public domain */

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>


@interface NMApplicationDelegate : NSObject {
	IBOutlet NSMenu *statusItemMenu;
	
	NSStatusItem *statusItem;
	NSArray *nextEvents;
}

@property(retain) NSArray *nextEvents;
@property(retain) NSStatusItem *statusItem;

- (void)updateStatusItem;
- (void)updateStatusItemTitle;
- (void)updateStatusItemMenu;

@end
