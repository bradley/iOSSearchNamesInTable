//
//  SNBeatListViewController.m
//  iOSSearchNamesInTable
//
//  Created by Bradley Griffith on 8/13/13.
//  Copyright (c) 2013 Bradley Griffith. All rights reserved.
//

#import "SNBeatListViewController.h"
#import "SNBeatCell.h"

@interface SNBeatListViewController()
@property (nonatomic, strong)NSArray *beats;
@property (nonatomic, strong)NSDictionary *sortedBeats;
@property (nonatomic, strong)NSArray *beatIndex;
@property (nonatomic, strong)NSString *searchString;
@property BOOL isFiltered;
@end

@implementation SNBeatListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _beats = [NSArray arrayWithObjects:@"Alene Lee", @"Amiri Baraka", @"Sinclair Beiles", @"Carol Bergé", @"Jane Bowles", @"Paul Bowles", @"John Brandi", @"Richard Brautigan", @"Ray Bremser", @"Chandler Brossard", @"James Broughton", @"Slim Brundage", @"Baird Bryant", @"William S. Burroughs", @"Carolyn Cassady", @"Neal Cassady", @"Neeli Cherkovski", @"Ira Cohen", @"Gregory Corso", @"Elise Cowen", @"Diane di Prima", @"Kirby Doyle", @"William Everson", @"Harry Fainlight", @"Lawrence Ferlinghetti", @"Michael John Fles", @"Jack Gelber", @"Brion Gysin", @"Anselm Hollo", @"John Clellon Holmes", @"Václav Hrabě", @"Herbert Huncke", @"Ted Joans", @"Joyce Johnson", @"Lenore Kandel", @"Bob Kaufman", @"Jack Kerouac", @"Jan Kerouac", @"Ken Kesey", @"Tuli Kupferberg", @"Joanne Kyger", @"Ron Loewinsohn", @"Michael McClure", @"David Meltzer", @"Jack Micheline", @"Barbara Moraff", @"Eric Big Daddy Nord", @"Harold Norse", @"Jeff Nuttall", @"Charles Olson", @"Peter Orlovsky", @"Rochelle Owens", @"Charles Plymell", @"Ed Sanders", @"Herschel Silverman", @"Gary Snyder", @"Carl Solomon", @"Gilbert Sorrentino", @"Jack Spicer", @"Joffre Stewart", @"Alexander Trocchi", @"Janine Pommy Vega", @"Puffer Volpe", @"Anne Waldman", @"Lew Welch", @"Philip Whalen", @"John Wieners", @"A. D. Winans", @"Wulf Zendik", @"Harriet Sohmers Zwerling", nil];
    [self sortBeats:_beats];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_beatIndex count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_beatIndex objectAtIndex:section];
    NSArray *usersForKey = [_sortedBeats objectForKey:key];
    return [usersForKey count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[_beatIndex objectAtIndex:section] uppercaseString];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _beatIndex;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BeatCell";
    SNBeatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *key = [_beatIndex objectAtIndex:indexPath.section];
    NSArray *usersForKey = [_sortedBeats objectForKey:key];
    NSString *user = [usersForKey objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *styledString = [self highlightSubstring:_searchString inString:user];
    cell.nameLabel.attributedText = styledString;
    return cell;
}

- (void)sortBeats:(NSArray *)beats {
    // Sorts users into a dictionary alphabetical sections.
    
    if (!_isFiltered)
        beats = [beats sortedDiacriticalAlphabetical];
    
    NSMutableDictionary *sectioned = [NSMutableDictionary dictionary];
    NSString *firstChar = nil;
    NSMutableArray *keys = [NSMutableArray array];
    
    NSLog(@"%@", beats);
    for(NSString *beatname in beats) {
        if(![beatname length])continue;
        
        NSMutableArray *names = nil;
        firstChar = [[[beatname decomposedStringWithCanonicalMapping] substringToIndex:1] uppercaseString];
        
        if (!(names = [sectioned objectForKey:firstChar])) {
            names = [NSMutableArray array];
            [sectioned setObject:names forKey:firstChar];
            [keys addObject:firstChar];
        }
        
        [names addObject:beatname];
    }
    
    NSLog(@"%@", sectioned);
    
    _sortedBeats = sectioned.copy;
    if (_isFiltered) {
        // Keep keys in order of names returned by search function.
        _beatIndex = keys;
    }
    else {
        // Arrange keys alphabetically.
        _beatIndex = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
}

- (NSMutableAttributedString *)highlightSubstring:(NSString *)subString inString:(NSString *)containerString {
    NSMutableAttributedString *styledString = [[NSMutableAttributedString alloc] initWithString:containerString];
    
    if (subString && containerString) {
        
        CGFloat fontSize = 17;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
        
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               boldFont, NSFontAttributeName, nil];
        NSRange range = [containerString rangeOfString:subString
                                               options:(NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch)];
        
        
        [styledString addAttributes:attrs range:range];
    }
    
    return styledString;
}

#pragma mark - Search bar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchString = searchText.copy;
    
    NSArray *searched;
    if (_searchString.length > 0) {
        _isFiltered = YES;
        NSArray *sorted = [_beats sortedDiacriticalAlphabetical];
        
        // Find and build array of all users whos names contain the search string, giving priority to names
        // that begin with the search text.
        NSMutableArray *foundInFirstname = [[NSMutableArray alloc] init];
        NSMutableArray *foundInName = [[NSMutableArray alloc] init];
        for (NSString *user in sorted) {
            NSRange range = [user rangeOfString:searchText
                                        options:(NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch+NSAnchoredSearch)];
            if (range.length > 0) {
                [foundInFirstname addObject:user];
            }
            else {
                range = [user rangeOfString:searchText
                                    options:NSCaseInsensitiveSearch+NSDiacriticInsensitiveSearch];
                if (range.length > 0) {
                    [foundInName addObject:user];
                }
            }
        }
        searched = [foundInFirstname arrayByAddingObjectsFromArray:foundInName];
    }
    else {
        _isFiltered = NO;
        searched = _beats;
    }
    
    [self sortBeats:searched];
    [_tableView reloadData];
}

@end


@implementation NSArray (Reverse)

- (NSArray *)sortedDiacriticalAlphabetical {
    NSArray *sorted = [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:obj2 options:NSDiacriticInsensitiveSearch+NSCaseInsensitiveSearch];
    }];
    return sorted;
}

@end