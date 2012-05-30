//
//  LabelOutlineLayer.h
//  WhackAVC
//
//  Created by Antiz Technologies on 4/12/12.
//  Copyright 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "cocos2d.h"

@interface LabelOutlineLayer : CCLayer {
    
}

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;

@end
