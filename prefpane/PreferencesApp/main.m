#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>

@interface JitouchPref : NSPreferencePane
- (void)mainViewDidLoad;
- (void)willSelect;
- (void)didSelect;
- (void)willUnselect;
- (void)didUnselect;
@end

@interface PreferencesAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property (strong) NSWindow *window;
@property (strong) id prefPane;
@end

@implementation PreferencesAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    // If embedded inside Jitouch.app/Contents/Resources/Jitouch Preferences.app:
    // Jitouch.prefPane is at Jitouch.app/Contents/Resources/Jitouch.prefPane
    NSString *resourcesDir = [bundlePath stringByDeletingLastPathComponent];
    NSString *prefPath = [resourcesDir stringByAppendingPathComponent:@"Jitouch.prefPane"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
        prefPath = [[NSBundle mainBundle] pathForResource:@"Jitouch" ofType:@"prefPane"];
    }
    if (!prefPath || ![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
        prefPath = @"/Applications/Jitouch.app/Contents/Resources/Jitouch.prefPane";
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:prefPath]) {
        prefPath = [@"~/Library/PreferencePanes/Jitouch.prefPane" stringByExpandingTildeInPath];
    }
    
    NSBundle *bundle = [NSBundle bundleWithPath:prefPath];
    if (!bundle) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Can't find Jitouch.prefPane."];
        [alert setInformativeText:@"Please make sure Jitouch is properly installed in /Applications."];
        [alert runModal];
        [alert release];
        [NSApp terminate:nil];
        return;
    }
    
    NSError *err = nil;
    if (![bundle loadAndReturnError:&err]) {
        NSLog(@"Error loading Jitouch.prefPane: %@", err);
        [NSApp terminate:nil];
        return;
    }
    
    Class prefClass = [bundle principalClass];
    self.prefPane = [[prefClass alloc] initWithBundle:bundle];
    [self.prefPane loadMainView];
    
    NSView *mainView = [self.prefPane mainView];
    NSRect viewFrame = [mainView frame];
    
    NSWindowStyleMask style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
    self.window = [[NSWindow alloc] initWithContentRect:viewFrame
                                              styleMask:style
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Jitouch Preferences"];
    [self.window center];
    [self.window setContentView:mainView];
    [self.window setDelegate:self];
    
    // Ensure the main Jitouch engine is running in background
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    BOOL jitouchRunning = NO;
    for (NSRunningApplication *app in apps) {
        if ([app.bundleIdentifier isEqualToString:@"com.jitouch.Jitouch"]) {
            jitouchRunning = YES;
            break;
        }
    }
    if (!jitouchRunning) {
        NSString *outerApp = [resourcesDir stringByDeletingLastPathComponent];
        NSString *jitouchBin = [outerApp stringByAppendingPathComponent:@"MacOS/Jitouch"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:jitouchBin]) {
            jitouchBin = @"/Applications/Jitouch.app/Contents/MacOS/Jitouch";
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:jitouchBin]) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:jitouchBin]];
        }
    }
    
    if ([self.prefPane respondsToSelector:@selector(willSelect)]) {
        [self.prefPane willSelect];
    }
    if ([self.prefPane respondsToSelector:@selector(didSelect)]) {
        [self.prefPane didSelect];
    }
    
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if ([self.prefPane respondsToSelector:@selector(willUnselect)]) {
        [self.prefPane willUnselect];
    }
    if ([self.prefPane respondsToSelector:@selector(didUnselect)]) {
        [self.prefPane didUnselect];
    }
    [NSApp terminate:nil];
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        
        NSMenu *mainMenu = [[NSMenu alloc] init];
        
        NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
        [mainMenu addItem:appMenuItem];
        NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Jitouch Preferences"];
        [appMenu addItemWithTitle:@"Hide Jitouch Preferences" action:@selector(hide:) keyEquivalent:@"h"];
        [appMenu addItem:[NSMenuItem separatorItem]];
        [appMenu addItemWithTitle:@"Quit Jitouch Preferences" action:@selector(terminate:) keyEquivalent:@"q"];
        [appMenuItem setSubmenu:appMenu];
        
        NSMenuItem *editMenuItem = [[NSMenuItem alloc] init];
        [mainMenu addItem:editMenuItem];
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
        [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
        [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
        [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
        [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
        [editMenuItem setSubmenu:editMenu];

        NSMenuItem *windowMenuItem = [[NSMenuItem alloc] init];
        [mainMenu addItem:windowMenuItem];
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
        [windowMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
        [windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
        [windowMenuItem setSubmenu:windowMenu];
        
        [app setMainMenu:mainMenu];
        
        PreferencesAppDelegate *delegate = [[PreferencesAppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
