//
//  LabelOutlineLayer.m
//  WhackAVC
//
//  Created by Antiz Technologies on 4/12/12.
//  Copyright 2012 Antiz Technologies Pvt Ltd. All rights reserved.
//

#import "LabelOutlineLayer.h"

@implementation LabelOutlineLayer

//Method to create a outline for a Label
+(CCRenderTexture*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	[label setColor:cor];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint center = ccp(label.texture.contentSize.width/2+size, label.texture.contentSize.height/2+size);
	[rt begin];
	for (int i=0; i<360; i+=15)
	{
		[label setPosition:ccp(center.x + sin(CC_DEGREES_TO_RADIANS(i))*size, center.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[rt setPosition:originalPos];
	return rt;
}

@end
