//
//  IBTMacro.h
//  IBTWeb
//
//  Created by Xummer on 2019/2/12.
//  Copyright © 2019 Xummer. All rights reserved.
//

#ifndef IBTMacro_h
#define IBTMacro_h

#import "EXTScope.h"

/**
 *  Output log when debug state
 */
#ifdef DEBUG
#define DebugLog(format, ...) \
NSLog((@"%s (%@:Line %d) " format), \
__PRETTY_FUNCTION__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,\
## __VA_ARGS__);
#else
#define DebugLog(format, ...)
#endif ///< DEBUG

#endif /* IBTMacro_h */
