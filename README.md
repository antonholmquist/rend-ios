Rend - A lightweight OpenGL ES 2.0 framework for iOS
====================
Author: Anton Holmquist | http://antonholmquist.com

Rend is a very lightweight OpenGL ES 2.0 framework designed for pure rendering and to be easily integrated with UIKit. 

Why another framework?
--------------------
Rend is similar in some senses to Cocos2d/3d, but it's lighter and very flexible which may suit some kind of projects better. If you're writing a game you should probably look at Cocos or Unity, but if you want to create a rendering or interface component to be integrated into your UIKit-based project, this framework may be well suited!

Background
--------------------
>When I was looking for a framework I looked at three existing options, Cocos2d, Cocos3d and Unity. None of those seemed perfect for my needs. Cocos2d obviously doesn’t have very good 3D support, Cocos3d didn't have shader support, and Unity seemed too bloated and hard to integrate with UIKit.

The full story can be found in [this blog post](http://antonholmquist.com/blog/introducing-rend-a-lightweight-objective-c-opengl-es-2-0-framework-ios/). 


Example usage
--------------------
The first thing to do is to create a view where we can draw our content.

    REGLView *view = [[REGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    

Next, we create a scene that acts as a root node in our scene graph hierarchy. All content should be added as children to this node.

    REScene *scene = [[REScene alloc] init];

Next, we create a director that is responsible for managing drawing and connecting the view and scene:

    REDirector *director = [[REDirector alloc] init];
    director.view = view;
    director.scene = scene;
    
We also need to attach a camera to our scene. The camera  requires some configuration so we place it at (0,0,1) facing at origo. This framework uses math functions from Cocos3d which is why you see the CC3 prefix.

    RECamera *camera = [[RECamera alloc] initWithProjection:kRECameraProjectionPerspective];
    camera.position = CC3VectorMake(0, 0, 1);
    camera.upDirection = CC3VectorMake(0, 1, 0);
    camera.lookDirection = CC3VectorMake(0, 0, -1);
    camera.frustumLeft = -1;
    camera.frustumRight = 1;
    camera.frustumBottom = -1;
    camera.frustumTop = 1;
    camera.frustumNear = 0.5;
    camera.frustumFar = 2;


Finally, we add a sprite to our scene, positioning it at origo and setting width and height to 1.0. We also need to select a texture from the app bundle and add the node to our scene.

    RESprite *sprite = [[RESprite alloc] init];
    sprite.positon = CC3VectorMake(0.0, 0.0, 0.0);
    sprite.size = CC3VectorMake(1.0, 1.0, 0.0);
    sprite.texture = [RETexture2D textureNamed:@"test.png"];
    [scene addChild:sprite];
    
Now everything is set up. The only thing left is to make the director run.

    director.running = YES;
    
So that's a very basic example on how to draw a sprite. There are some more advanced examples provided with the repository.