// PluginWindowController.h
// 
// Copyright (c) 2013 Marin Usalj | mneorr.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <AppKit/AppKit.h>
#import "ATZPackageTableView.h"

@interface ATZPluginWindowController : NSWindowController<NSTableViewDelegate, NSControlTextEditingDelegate>

@property (nonatomic, retain) NSArray *packages;
@property (nonatomic, retain) NSPredicate *filterPredicate;

@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet ATZPackageTableView *tableView;
@property (assign) IBOutlet NSTextField *statusLabel;
@property (assign) IBOutlet NSTextField *restartLabel;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)checkboxPressed:(NSButton *)sender;
- (IBAction)openPackageWebsitePressed:(NSButton *)sender;

- (IBAction)showAllPackages:(id)sender;
- (IBAction)showOnlyPlugins:(id)sender;
- (IBAction)showOnlyColorSchemes:(id)sender;
- (IBAction)showOnlyTemplates:(id)sender;

@end
