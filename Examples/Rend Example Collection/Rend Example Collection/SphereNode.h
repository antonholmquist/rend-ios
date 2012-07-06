//
//  SphereNode.h
//  dgi12Projekt
//
//  Created by Anton Holmberg on 2012-05-25.
//  Copyright (c) 2012 Anton Holmberg. All rights reserved.
//

#import "RENode.h"

typedef struct SphereNodeAttribs {
    CC3Vector position;
    CC3Vector texCoord;
    CC3Vector bumpAxisX;
    CC3Vector bumpAxisY;
} SphereNodeAttribs;

@interface SphereNode : RENode {
    
    int resolutionX_;
    int resolutionY_;
    int nAttribs_;
    SphereNodeAttribs *attribs_;
}

@property (nonatomic, retain) RETexture2D *texture;
@property (nonatomic, retain) RETexture2D *bumpMap;
@property (nonatomic, readwrite) float shinyness;
@property (nonatomic, readwrite) float specularLightBrightness;
@property (nonatomic, readwrite) float bumpMapOffset;

- (id)initWithResolutionX:(int)resolutionX resolutionY:(int)resolutionY radius:(float)radius;

@end
