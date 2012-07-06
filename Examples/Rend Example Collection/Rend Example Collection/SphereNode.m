//
//  SphereNode.m
//  dgi12Projekt
//
//  Created by Anton Holmberg on 2012-05-25.
//  Copyright (c) 2012 Anton Holmberg. All rights reserved.
//

#import "SphereNode.h"

@interface SphereNode ()

- (CC3Vector)positionForHorizontalAngle:(float)ha topAngle:(float)ta radius:(float)r;
- (CC3Vector)bumpAxisXForHorizontalAngle:(float)ha topAngle:(float)ta;
- (CC3Vector)bumpAxisYForHorizontalAngle:(float)ha topAngle:(float)ta;

@end

@implementation SphereNode

@synthesize texture = texture_;
@synthesize bumpMap = bumpMap_;
@synthesize shinyness = shinyness_;
@synthesize specularLightBrightness = specularLightBrightness_;
@synthesize bumpMapOffset = bumpMapOffset_;

- (id)initWithResolutionX:(int)resolutionX resolutionY:(int)resolutionY radius:(float)radius {
    if (self = [super init]) {
        
        resolutionX_ = resolutionX;
        resolutionY_ = resolutionY;
        
        float r = radius;
        
        nAttribs_ = 2 * resolutionX_ * (resolutionY_ - 1);
        
        NSLog(@"nAttribs_: %d", nAttribs_);
        attribs_ = calloc(nAttribs_, sizeof(SphereNodeAttribs));
        memset(attribs_, 0, nAttribs_ * sizeof(SphereNodeAttribs));
        for(int iy = 0; iy < resolutionY_ - 1; iy++) {
            for(int ix = 0; ix < resolutionX_; ix++) {
                
                int index = iy * 2 * resolutionX_ + 2 * ix;
                
                float fx = ix/(float)(resolutionX_ - 1);
                
                float fy = iy/(float)(resolutionY_ - 1);
                float nextFY = (iy + 1)/(float)(resolutionY_ - 1);
                
                float ha = fx * 2 * M_PI;
                float ta0 = fy * M_PI;
                float ta1 = nextFY * M_PI;
                
                attribs_[index].position = [self positionForHorizontalAngle:ha topAngle:ta0 radius:r];
                attribs_[index].texCoord = CC3VectorMake(fx, fy, 0);
                attribs_[index].bumpAxisX = [self bumpAxisXForHorizontalAngle:ha topAngle:ta0];
                attribs_[index].bumpAxisY = [self bumpAxisYForHorizontalAngle:ha topAngle:ta0];
                
                attribs_[index+1].position = [self positionForHorizontalAngle:ha topAngle:ta1 radius:r];
                attribs_[index+1].texCoord = CC3VectorMake(fx, nextFY, 0);
                attribs_[index+1].bumpAxisX = [self bumpAxisXForHorizontalAngle:ha topAngle:ta1];
                attribs_[index+1].bumpAxisY = [self bumpAxisYForHorizontalAngle:ha topAngle:ta1];
            }
        }
    }
    return self;
}

- (CC3Vector)bumpAxisXForHorizontalAngle:(float)ha topAngle:(float)ta {
    if(ta == 0) ta = 0.001;
    if(ABS(ta - M_PI) < 0.001) ta = M_PI - 0.001;
    CC3Vector axis = CC3VectorNormalize(CC3VectorDifference([self positionForHorizontalAngle:ha + 0.001 topAngle:ta radius:10],
                                                            [self positionForHorizontalAngle:ha - 0.001 topAngle:ta radius:10]));
    return axis;
}


- (CC3Vector)bumpAxisYForHorizontalAngle:(float)ha topAngle:(float)ta {
    if(ta == 0) ta = 0.001;
    if(ABS(ta - M_PI) < 0.001) ta = M_PI - 0.001;
    CC3Vector axis = CC3VectorNormalize(CC3VectorDifference([self positionForHorizontalAngle:ha topAngle:ta + 0.001 radius:10],
                                                            [self positionForHorizontalAngle:ha topAngle:ta - 0.001 radius:10]));
    return axis;
}


- (CC3Vector)positionForHorizontalAngle:(float)ha topAngle:(float)ta radius:(float)r {
    return CC3VectorMake(r * sin(ta) * cos(ha), r * cos(ta), r * sin(ta) * sin(ha));
}

- (void)dealloc {
    free(attribs_);
    
    self.texture = nil;
    self.bumpMap = nil;
    
    [super dealloc];
}

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sBumpSphere.vsh" fragmentFilename:@"sBumpSphere.fsh"];
}

- (void)draw {
    
    [super draw];
    
    GLint a_position = [self.program attribLocation:@"a_position"];
    GLint a_texCoord = [self.program attribLocation:@"a_texCoord"];
    GLint a_bumpAxisX = [self.program attribLocation:@"a_bumpAxisX"];
    GLint a_bumpAxisY = [self.program attribLocation:@"a_bumpAxisY"];
    
    
    glUniform1i([self.program uniformLocation:@"s_texture"], 0);
    [texture_ bind:GL_TEXTURE0];
    
    glUniform1i([self.program uniformLocation:@"s_bumpMap"], 1);
    [bumpMap_ bind:GL_TEXTURE1];
    
    glUniform1f([self.program uniformLocation:@"u_shinyness"], shinyness_);
    glUniform1f([self.program uniformLocation:@"u_specularLightBrightness"], specularLightBrightness_);
    glUniform1f([self.program uniformLocation:@"u_bumpMapOffset"], bumpMapOffset_);
    
    glEnableVertexAttribArray(a_position);
    glEnableVertexAttribArray(a_texCoord);
    glEnableVertexAttribArray(a_bumpAxisX);
    glEnableVertexAttribArray(a_bumpAxisY);
    
    glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, sizeof(SphereNodeAttribs), (void*)(attribs_) + offsetof(SphereNodeAttribs, position));
    glVertexAttribPointer(a_texCoord, 3, GL_FLOAT, GL_FALSE, sizeof(SphereNodeAttribs), (void*)(attribs_) + offsetof(SphereNodeAttribs, texCoord));
    glVertexAttribPointer(a_bumpAxisX, 3, GL_FLOAT, GL_FALSE, sizeof(SphereNodeAttribs), (void*)(attribs_) + offsetof(SphereNodeAttribs, bumpAxisX));
    glVertexAttribPointer(a_bumpAxisY, 3, GL_FLOAT, GL_FALSE, sizeof(SphereNodeAttribs), (void*)(attribs_) + offsetof(SphereNodeAttribs, bumpAxisY));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, nAttribs_);
}

@end
