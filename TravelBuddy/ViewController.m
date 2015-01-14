//
//  ViewController.m
//  TravelBuddy
//
//  Created by J.J. Jackson on 1/12/15.
//  Copyright (c) 2015 Expect Labs. All rights reserved.
//

#import "ViewController.h"

#import <JHSidebar/JHSidebarViewController.h>

static NSString *const kMindMeldAppID = @"c682a671fa69af8e61b08f0866431e01097f8bc6";

static NSString *const kMindMeldDomainID = @"1796";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [super viewDidLoad];
    
    self.mindMeldApp = [[MMApp alloc] initWithAppID:kMindMeldAppID];
    self.mindMeldApp.delegate = self;
    [self.mindMeldApp start:nil onSuccess:^(id response) {
        NSLog(@"Successfully started!");
        self.mindMeldApp.activeSession.documents.useBothPushAndPull = NO;
        self.mindMeldApp.activeSession.documents.apiParams = @{ @"domainid": kMindMeldDomainID };
        [self.mindMeldApp.activeSession.documents startUpdates];
    } onFailure: ^(NSError *error) {
        NSLog(@"Error on startup: %@", error);
    }
     ];
    // We'll define this in just a bit
    [self createListener];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMenuButtonPress:(id)sender {
    // Toggle left sidebar
    [self.sidebarViewController toggleLeftSidebar];
}

- (void)loadView
{
    [super loadView];
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // Listen Button
    CGRect buttonFrame = CGRectMake(15, 60, 100, 30);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = buttonFrame;
    [button setTitle:@"Start Listening" forState:UIControlStateNormal];
    [button setTitle:@"Stop Listening" forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    [button sizeToFit];
    [button addTarget:self action:@selector(pressedListenButton:)
     forControlEvents:UIControlEventTouchUpInside];
    self.button = button;
    [self.view addSubview:button];
    
    // Transcript Label
    CGRect transcriptFrame = CGRectMake(15, 120, screenRect.size.width, 30);
    UILabel *transcriptLabel = [[UILabel alloc] initWithFrame: transcriptFrame];
    self.transcriptLabel = transcriptLabel;
    [self.view addSubview:transcriptLabel];
    
    // Results Table
    CGRect tableFrame = CGRectMake(0, 180, screenRect.size.width,
                                   screenRect.size.height - 180);
    UITableView *table = [[UITableView alloc] initWithFrame:tableFrame];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultsTableView = table;
    table.dataSource = self;
    [self.view addSubview:table];
}

- (void)createListener {
    self.listener = [MMListener listener];
    // Just listen to one user statement then stop.
    self.listener.continuous = NO;
    // Send us partial results as the user is speaking.
    self.listener.interimResults = YES;
    
    // Keep the state of the button in sync with listener state.
    typeof(self) __weak weakSelf = self;
    self.listener.onBeganRecording = ^(MMListener *listener) {
        weakSelf.button.selected = YES;
    };
    
    self.listener.onFinishedRecording = ^(MMListener *listener) {
        weakSelf.button.selected = NO;
    };
    
    self.listener.onFinished = ^(MMListener *listener) {
        weakSelf.button.selected = NO;
    };
    
    // Here we handle any errors that may be ocurring
    self.listener.onError = ^(MMListener *listener, NSError *error) {
        NSLog(@"listener error: %@", error);
        weakSelf.button.selected = NO;
    };
    
    // After recording and processing the user's speech, we'll receive the
    // parsed text from the listener. We need to add a text entry so that we can
    // get related documents.
    self.listener.onResult = ^(MMListener *listener, MMListenerResult *newResult) {
        if (newResult.transcript.length) {
            weakSelf.transcriptLabel.text = newResult.transcript;
            if (newResult.final) {
                // use different text colors to indicate interim and final results
                weakSelf.transcriptLabel.textColor = [UIColor blackColor];
                // This is where we actually post the text entry; we'll define
                // it below.
                [weakSelf addMindMeldTextEntry:newResult.transcript];
            } else {
                weakSelf.transcriptLabel.textColor = [UIColor darkGrayColor];
            }
        }
    };
}

- (void)pressedListenButton:(id)obj {
    if (self.button.selected) {
        // We're listening, so stop.
        self.button.selected = NO;
        [self.listener stopListening];
    } else {
        // We're not listening, so start.
        self.button.selected = YES;
        [self.listener startListening];
    }
}

- (void)addMindMeldTextEntry:(NSString *)text {
    if (!(text && text.length > 0)) {
        return;
    }
    
    MMSuccessHandler successHandler = ^(NSDictionary *response) {
        NSLog(@"successfully submitted text entry: \"%@\"", text);
    };
    
    MMFailureHandler failureHandler = ^(NSError *error) {
        NSLog(@"error submitting text entry: %@", error);
    };
    
    NSDictionary *textEntry = @{ @"text": text, // The content of the text entry.
                                 @"type": @"speech", // The type of the text entry; this can be used to filter text entries
                                 @"weight": @"1.0" }; // The text entries will all have the same weight. If we valued certain text entries over others, we might raise or lower this accordingly.
    
    [self.mindMeldApp.activeSession.textEntries postWithBody:textEntry
                                                   onSuccess:successHandler
                                                   onFailure:failureHandler];
}

- (void)documentListDidUpdate:(MMDocumentList *)documents {
    [self.resultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                         withRowAnimation:UITableViewRowAnimationFade];
}

- (void)documentList:(MMDocumentList *)documents
didFailUpdateWithError:(NSError *)error {
    NSLog(@"Failed to update document list");
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (self.mindMeldApp.activeSession) {
        return self.mindMeldApp.activeSession.documents.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kDocumentCellID = @"documentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDocumentCellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kDocumentCellID];
    }
    
    cell.textLabel.text = self.mindMeldApp.activeSession.documents[indexPath.row][@"title"];
    
    return cell;
}

@end
