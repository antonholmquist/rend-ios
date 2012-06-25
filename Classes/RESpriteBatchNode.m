
#import "RESpriteBatchNode.h"
#import "RENSArrayAdditions.h"
#import "REGLStateManager.h"
#import "RECamera.h"
#import "RETexture2D.h"

#define kRESpriteBatchNodeBatchSize 24

@interface RESpriteBatchNode ()

// Add one buffer.
- (void)addBatchedAttribsBuffer;

@end

@implementation RESpriteBatchNode

@synthesize tag;

- (id)init {
    if ((self = [super init])) {
        
        
        sprites = [[NSMutableArray RE_arrayUsingWeakReferences] retain];
        vertexArrayObjects = [[NSMutableArray alloc] init];
       // batchedTexCoordAttribBuffers = [[NSMutableArray alloc] init];
        
        // Create this here, since it's preknown
        elementIndices = calloc(6 * kRESpriteBatchNodeBatchSize, sizeof(GLushort));
        batchUnitAttrib = calloc(4 * kRESpriteBatchNodeBatchSize, sizeof(GLfloat));
        
        
        
        for (int i = 0; i < kRESpriteBatchNodeBatchSize; i++) {
            
            elementIndices[i * 6 + 0] = i * 4 + 0;
            elementIndices[i * 6 + 1] = i * 4 + 1;
            elementIndices[i * 6 + 2] = i * 4 + 3;
            elementIndices[i * 6 + 3] = i * 4 + 3;
            elementIndices[i * 6 + 4] = i * 4 + 2;
            elementIndices[i * 6 + 5] = i * 4 + 0;
            
            batchUnitAttrib[i * 4 + 0] = i;
            batchUnitAttrib[i * 4 + 1] = i;
            batchUnitAttrib[i * 4 + 2] = i;
            batchUnitAttrib[i * 4 + 3] = i;
        }
        
        elementIndexBuffer = [[REBuffer alloc] initWithTarget:GL_ELEMENT_ARRAY_BUFFER data:elementIndices length:6 * kRESpriteBatchNodeBatchSize *sizeof(GLushort)];
        
        batchUnitAttribBuffer = [[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER data:batchUnitAttrib length:4 * kRESpriteBatchNodeBatchSize *sizeof(GLfloat)];
        
        modelViewMatrices = calloc(kRESpriteBatchNodeBatchSize, 16 * sizeof(GLfloat));
        
        batchedAttribs = calloc(4 * kRESpriteBatchNodeBatchSize, sizeof(RESpriteAttribs));
        
        batchedAttribsBuffers_ = [[NSMutableArray alloc] init];
        
        
        multiplyColors = calloc(4 * kRESpriteBatchNodeBatchSize, sizeof(GLfloat));
        
//        NSLog(@"creating spritebatchnode");
    } return self;
}

- (void)dealloc {
//    NSLog(@"dealloc spritebatchnode");
    
   // [batchedTexCoordAttribBuffers release];
    [vertexArrayObjects release];
    [batchedAttribsBuffers_ release];
    [elementIndexBuffer release];
    [batchUnitAttribBuffer release];
    [positionAttribBuffer release];
    [sprites release];
    free(elementIndices);
    free(batchUnitAttrib);
    free(modelViewMatrices);
    free(batchedAttribs);
    free(multiplyColors);
     
    [super dealloc];
}

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sRESpriteBatch.vsh" fragmentFilename:@"sRESpriteBatch.fsh"];
}

- (void)addBatchedAttribsBuffer {
    REBuffer *batchedAttribsBuffer = [[[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER data:nil length:(4 * kRESpriteBatchNodeBatchSize * sizeof(RESpriteAttribs)) usage:GL_DYNAMIC_DRAW] autorelease];
    [batchedAttribsBuffers_ addObject:batchedAttribsBuffer];
}

/*
- (void)addChild:(RENode *)node {
    // Batch nodes can't have children. Add as sprite instead
}

- (void)removeChild:(RENode *)node {
    // Batch nodes can't have children.
}
 */

- (void)addSprite:(RESprite*)sprite {
    
    NSAssert(sprite.batchNode == self, @"RESpriteBatchNode: addSprite should not be called directly. Use batchNode property on sprite instead");
    
    if ([sprites indexOfObjectIdenticalTo:sprite] == NSNotFound) {
        
        [sprites addObject:sprite];
    }
    
    
    //[batchedAttribsBuffers_ removeAllObjects];
}

- (void)removeSprite:(RESprite*)sprite {
    
    [sprites removeObjectIdenticalTo:sprite];
    //[batchedAttribsBuffers_ removeAllObjects];
}

- (void)draw {
    
    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR); 
    //glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    
    // Sprites to actually draw. Leave hidden or no-alpha sprites out.
    NSMutableArray *spritesToDraw = [NSMutableArray array];
    
    for (RESprite *sprite in sprites) {
        //if (sprite.hidden || [sprite.alpha floatValue] == 0.0) {
        if (sprite.isAncestorHidden || [sprite.alpha floatValue] == 0.0) {
            continue;
        }        
        [spritesToDraw addObject:sprite];
    }
    
    RESprite *firstSprite = [spritesToDraw count] > 0 ? [spritesToDraw objectAtIndex:0] : nil; // First sprite determines texture for all sprites.
    if (!firstSprite) return;
    
    
    //glUseProgram(program.program);
    [[REGLStateManager sharedManager] setCurrentProgram:program.program];
    
    
    REProgram *p = self.program;
    
    // Take some properties from first sprite.
    self.blendEnabled = firstSprite.blendEnabled;
    self.blendFunc = firstSprite.blendFunc;
    self.cullFaceEnabled = firstSprite.cullFaceEnabled;
    self.depthMask = firstSprite.depthMask;
    self.depthTestEnabled = firstSprite.depthTestEnabled;
    self.stencilFunc = firstSprite.stencilFunc;
    self.stencilOp = firstSprite.stencilOp;
    self.stencilTestEnabled = firstSprite.stencilTestEnabled;
    
    /*
    // Should change these to honor self properties instead of having default values..
    [[REGLStateManager sharedManager] setCullFaceEnabled:NO];
    [[REGLStateManager sharedManager] setDepthMask:NO];
//    [[REGLStateManager sharedManager] setDepthTestEnabled:[firstSprite.depthTestEnabled bo
    //[[REGLStateManager sharedManager] setBlendFunc:REGLBlendFuncMake(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)];
    [[REGLStateManager sharedManager] setBlendFunc:[firstSprite.blendFunc REGLBlencFuncValue]];
     */
    
    GLint a_position = [p attribLocation:@"a_position"];
    GLint a_texCoord = [p attribLocation:@"a_texCoord"];
    GLint s_texture = [p uniformLocation:@"s_texture"];
    
    GLint u_pMatrix = [p uniformLocation:@"u_pMatrix"];
    GLint u_mvMatrix = [p uniformLocation:@"u_mvMatrix"];
    
    GLint u_multiplyColor = [p uniformLocation:@"u_multiplyColor"];
    
    GLint a_batchUnit = [p attribLocation:@"a_batchUnit"];
    
    [[REGLStateManager sharedManager] setActiveTexture:GL_TEXTURE0];
    [firstSprite.texture bind];
    
    glUniform1i(s_texture, 0);
    
    // Projection matrix will be the same for all batches
    RECamera *cam = self.camera;
    CC3GLMatrix *projectionMatrix = cam ? cam.projectionMatrix : [CC3GLMatrix identity];
    glUniformMatrix4fv(u_pMatrix, 1, GL_FALSE, projectionMatrix.glMatrix);
    
    // Don't create this until now, so we can fetch position attribs from first sprite. They will all share the same internal position
    if (!positionAttribBuffer) {
        GLfloat *positionAttribs = calloc(4 * 3 * kRESpriteBatchNodeBatchSize, sizeof(GLfloat));
        for (int i = 0; i < kRESpriteBatchNodeBatchSize; i++) {
            for (int j = 0; j < 4; j++) {
                memcpy(positionAttribs + i * 4 * 3 + j * 3, (void*)&firstSprite.attribs[j].position, 3 * sizeof(GLfloat));
            }
        }
        positionAttribBuffer = [[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER data:positionAttribs length:4 * 3 * kRESpriteBatchNodeBatchSize *sizeof(GLfloat)];
        free(positionAttribs);
    }
    
    // Loop batches
    for (int batch = 0; batch <= [spritesToDraw count] / kRESpriteBatchNodeBatchSize; batch++) {
        
        
        // Loop sprites to determine sprites in this batch
        NSMutableArray *spritesInBatch = [NSMutableArray arrayWithCapacity:kRESpriteBatchNodeBatchSize];
        for (int spriteIndex = 0; spriteIndex < kRESpriteBatchNodeBatchSize; spriteIndex++) {
            
            int totalSpriteIndex = batch * kRESpriteBatchNodeBatchSize + spriteIndex;
            
            if (totalSpriteIndex >= [spritesToDraw count]) {
                break; // We're done
            }
            
            RESprite *sprite = [spritesToDraw objectAtIndex:totalSpriteIndex];
            [spritesInBatch addObject:sprite];
            
            NSAssert(firstSprite.texture == sprite.texture, @"RESpriteBatchNode: Can't batch sprites with different textures!");
            
            /*
            // Leave hidden sprites out. This is not optimal, but works.
            if (!sprite.hidden || [sprite.alpha floatValue] == 0.0) {
                [spritesInBatch addObject:sprite];
            }
             */
        }
        
        
        // If we don't have any sprites in this batch, just break
        if ([spritesInBatch count] == 0)
            break;
        
        
        // Uniforms
        CC3GLMatrix *viewMatrix = cam ? cam.viewMatrix : [CC3GLMatrix identity];
        
        //CC3GLMatrix *modelViewMatrix = [[CC3GLMatrix alloc] init];
        
        for (int i = 0; i < [spritesInBatch count]; i++) {
            RESprite *sprite = [spritesInBatch objectAtIndex:i];
            
            // NOTE: THIS IS REALLY SLOW???
            //CC3GLMatrix *modelViewMatrix = [viewMatrix copy]; // Set modelview matrix based on self (and later child)
            //CC3GLMatrix *modelViewMatrix = [CC3GLMatrix copy]; // Set modelview matrix based on self (and later child)
            [modelViewMatrix populateFrom:viewMatrix];
            CC3GLMatrix *g = [sprite globalTransformMatrix]; // SLOW!!?
            [modelViewMatrix multiplyByMatrix:g]; 
            memcpy(modelViewMatrices + 16 * i, modelViewMatrix.glMatrix, 16 * sizeof(GLfloat));
            
            
            // Color
            CC3Vector4 multiplyColor = sprite.multiplyColor;
            multiplyColor.w = multiplyColor.w * [sprite.alpha floatValue];
            memcpy(multiplyColors + 4 * i, &multiplyColor, 4 * sizeof(GLfloat));
            
        }
        //[modelViewMatrix release];
        
        glUniformMatrix4fv(u_mvMatrix, [spritesInBatch count], GL_FALSE, modelViewMatrices);
        glUniform4fv(u_multiplyColor, [spritesInBatch count], multiplyColors);
        
        
        GLfloat *texCoords = malloc(4 * 2 * sizeof(GLfloat) * [spritesInBatch count]);
        
        // Create batched attribs
        for (int i = 0; i < [spritesInBatch count]; i++) {
            RESprite *sprite = [spritesInBatch objectAtIndex:i];
            
            for (int j = 0; j < 4; j++) {
                CC3Vector texCoord = sprite.attribs[j].texCoord;
                memcpy(texCoords + i * 4 * 2 + 2 * j, &texCoord, 2 * sizeof(GLfloat));
            }
            
            // Warning: We only really need tex coords, but we're copying everything. Unesseccary!
           // memcpy(batchedAttribs + i * 4, sprite.attribs, 4 * sizeof(RESpriteAttribs));
            //[batchedAttribsBuffer updateSubData:sprite.attribs offset:(i * 4 * sizeof(RESpriteAttribs)) length:4 * sizeof(RESpriteAttribs)];
        }
        
        //REBuffer *batchedAttribsBuffer = nil;
        
        // If we need another batch attribs buffer
        if ([batchedAttribsBuffers_ count] <= batch) {
            //[self addBatchedAttribsBuffer];
        }
        
        //batchedAttribsBuffer = [batchedAttribsBuffers_ objectAtIndex:batch];            
        
        // THIS IS SLOW! PLZ DON't do it. Maybe we can avoid adding sprites with animating/toggling texures content frames to the batch.
       // [batchedAttribsBuffer setSubData:texCoords offset:0 length:4 * 2 * sizeof(GLfloat) * [spritesInBatch count]];
        
        [REBuffer unbind];
        
        glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
        //[[REGLStateManager sharedManager] setVertexAttribArray:a_texCoord enabled:GL_TRUE];
        glEnableVertexAttribArray(a_texCoord);
        
        // Position attribute buffer. These stay constant.
        [positionAttribBuffer bind];
        glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, 0, 0);
        //[[REGLStateManager sharedManager] setVertexAttribArray:a_position enabled:GL_TRUE];
        glEnableVertexAttribArray(a_position);
        
        // batchUnitAttrib. These stay constant.
        [batchUnitAttribBuffer bind];
        glVertexAttribPointer(a_batchUnit, 1, GL_FLOAT, GL_FALSE, 0,0);
        //[[REGLStateManager sharedManager] setVertexAttribArray:a_batchUnit enabled:GL_TRUE];
        glEnableVertexAttribArray(a_batchUnit);
        
        
        
        
        
        /*
        
        REVertexArrayObject *vertexArrayObject = batch < [vertexArrayObjects count] ? [vertexArrayObjects objectAtIndex:batch] : nil;
        
        if (!vertexArrayObject) {
            
            vertexArrayObject = [[[REVertexArrayObject alloc] init] autorelease];
            [vertexArrayObjects addObject:vertexArrayObject];
            
            //[REVertexArrayObject unbind];
            
            [vertexArrayObject bind];
        
            [batchedAttribsBuffer bind]; // ERROR!!? The bound buffer is connected to the VAO? http://www.khronos.org/registry/gles/extensions/OES/OES_vertex_array_object.txt
            
            //[REBuffer unbindArrayBuffer];
            
            // Needed since each sprite may have different texcoords from atlas. Has to be updated at least each time a child sprite is added.
            //glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(RESpriteAttribs), (void*)(batchedAttribs) + offsetof(RESpriteAttribs, texCoord));
            //glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(RESpriteAttribs), (const void*)offsetof(RESpriteAttribs, texCoord));
            
            glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, 0, 0);

            //[[REGLStateManager sharedManager] setVertexAttribArray:a_texCoord enabled:GL_TRUE];
            glEnableVertexAttribArray(a_texCoord);
            
            // Position attribute buffer. These stay constant.
            [positionAttribBuffer bind];
            glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, 0, 0);
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_position enabled:GL_TRUE];
            glEnableVertexAttribArray(a_position);
            
            // batchUnitAttrib. These stay constant.
            [batchUnitAttribBuffer bind];
            glVertexAttribPointer(a_batchUnit, 1, GL_FLOAT, GL_FALSE, 0,0);
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_batchUnit enabled:GL_TRUE];
            glEnableVertexAttribArray(a_batchUnit);
            
            
            //[REBuffer unbind]; //should be done here? Anton: Makes no difference
        }
        
        //NSLog(@"[spritesInBatch count]: %d, batch: %d, vertexArrayObject: %@", [spritesInBatch count], batch, vertexArrayObject);
         
        [REBuffer unbind]; // This is neccessary! Else it will crash on second batch for some reason. Basically we want no vbo to be bound when using vao. Apple unbinds this on configuration.
        [vertexArrayObject bind];
         
         */
         
        [elementIndexBuffer bind];
        glDrawElements(GL_TRIANGLES, 6 * [spritesInBatch count] , GL_UNSIGNED_SHORT, 0);
        
        free(texCoords);
        
        //NSLog(@"glDrawElements");
        
    }
}

@end
