/*
 Copyright (C) AC SOFTWARE SP. Z O.O.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#include "SAClassHelper.h"

@implementation NSDictionary (SUPLA)

-(NSString *)urlEncode:(id)obj {
    return [[NSString stringWithFormat:@"%@", obj] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

-(NSString*) urlEncodedString {
    
    NSMutableArray *fields = [NSMutableArray array];
    
    for (id key in self) {
        id value = [self objectForKey: key];
        NSString *field = [NSString stringWithFormat: @"%@=%@", [self urlEncode:key], [self urlEncode:value]];
        [fields addObject: field];
    }
    return [fields componentsJoinedByString: @"&"];
}


@end