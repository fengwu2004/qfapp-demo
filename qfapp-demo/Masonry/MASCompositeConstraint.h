//
//  MASCompositeConstraint.h
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASConstraint.h"
#import "MASUtilities.h"

/**
 *	A group of MASConstraint objects
 */
@interface MASCompositeConstraint : MASConstraint

/**
 *	Creates a composite with a predefined array of children
 *
 *	@输入	children	child MASConstraints
 *
 *	@返回	a composite constraint
 */
- (id)initWithChildren:(NSArray *)children;

@end
