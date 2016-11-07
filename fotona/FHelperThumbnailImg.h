//
//  FHelperThumbnailImg.h
//  fotona
//
//  Created by Janos on 19/10/16.
//  Copyright © 2016 4egenus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHelperThumbnailImg : NSObject



+(void) getThumbnailForMedia:(FMedia *)media onTableView:(UITableView *)tableView withIndex:(NSIndexPath *)indexPath;
+(void) preloadImage:(NSMutableArray *)mediaArray mediaType:(NSString *)mediaType forTableView:(UITableView *)tableView onIndex:(NSIndexPath *) indexPath;
@end
