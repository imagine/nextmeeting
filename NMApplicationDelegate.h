//
//  NMApplicationDelegate.h
//  Next Meeting
//
//  Created by Nathan Spindel on 5/21/08.
//

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
