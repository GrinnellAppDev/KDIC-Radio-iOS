//
//  HTMLStringParser.h
//  KDIC
//
//  Created by Colin Tremblay on 11/24/13.
//  Copyright (c) 2013 Colin Tremblay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLStringParser : NSObject

- (NSString *)removeHTMLTags:(NSString *)str;

@end
