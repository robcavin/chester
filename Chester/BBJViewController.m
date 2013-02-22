//
//  BBJViewController.m
//  Chester
//
//  Created by Rob on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBJViewController.h"
#import <AVFoundation/AVFoundation.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define RIGHT 1
#define LEFT -1

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_MODELVIEWPROJECTION_MATRIX_2,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_TEXTURE_OFFSET,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.


GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

GLfloat backgroundScene[30] = {
     64.0f, 0.0f, 0.0f,  0.5f, 0.5f,
     64.0f, 64.0f, 0.0f,   0.5f, 0.0f,
     0.0f, 64.0f, 0.0f,   0.0f, 0.0f,

     64.0f, 0.0f,  0.0f,   0.5f, 0.5f,
     0.0f, 0.0f,  0.0f,   0.0f, 0.5f,
     0.0f, 64.0f,  0.0f,   0.0f, 0.0f
};

@interface BBJViewController () {
    GLuint _program;
    GLuint _program2;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;

    GLuint _vertexArray2;
    GLuint _vertexBuffer2;
    
    GLuint _texture1;
    GLKTextureInfo* texture;
    
    GLKVector2 speed;
    GLKVector2 position;
    GLKVector2 acceleration;
    
    int direction;

}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) IBOutlet UIButton* leftButton;
@property (strong, nonatomic) IBOutlet UIButton* rightButton;
@property (strong, nonatomic) IBOutlet UIButton* jumpButton;
@property (strong, nonatomic) GLKTextureInfo* texture;
@property (strong, nonatomic) GLKTextureInfo* texture2;
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) AVAudioPlayer* jumpSound;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (IBAction)jumpButtonPressed:(id)sender;

@end

@implementation BBJViewController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize leftButton;
@synthesize rightButton;
@synthesize jumpButton;
@synthesize texture;
@synthesize texture2;
@synthesize player;
@synthesize jumpSound;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"pastorale" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    player.numberOfLoops = -1; //infinite
    
    [player play];

    soundFilePath = [[NSBundle mainBundle] pathForResource:@"jump" ofType:@"wav"];
    soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    self.jumpSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
   
    position = GLKVector2Make(0, 75.0);
    speed = GLKVector2Make(0,0);
    acceleration = GLKVector2Make(0,0);
    direction = 1;
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)) return NO;
    else return YES;
}


/*- (GLuint)setupTexture:(NSString *)fileName {    
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, 
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);    
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    
    return texName;
}*/


- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    NSError* error;
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"chester-texture" ofType:@"png"];
    self.texture = [GLKTextureLoader textureWithContentsOfFile:filePath 
                                                  options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps,
                                                           nil] 
                                                    error:&error];

    filePath = [[NSBundle mainBundle] pathForResource:@"landscape4" ofType:@"png"];
    self.texture2 = [GLKTextureLoader textureWithContentsOfFile:filePath 
                                                  options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithBool:YES], GLKTextureLoaderGenerateMipmaps,
                                                           nil] 
                                                    error:&error];
    
    NSLog(@"%d %d",texture.width, texture.height);
    //_texture1 = [self setupTexture:@"landscape.png"];
    //NSLog(@"%@",glGetError());
    
    if (error) NSLog(@"%@",error);
    
    
    [self loadShaders];
 
    //self.effect = [[GLKBaseEffect alloc] init];
    //self.effect.light0.enabled = GL_TRUE;
    //self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    //glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);


    glGenVertexArraysOES(1, &_vertexArray2);
    glBindVertexArrayOES(_vertexArray2);
    
    glGenBuffers(1, &_vertexBuffer2);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer2);
    glBufferData(GL_ARRAY_BUFFER, sizeof(backgroundScene), backgroundScene, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods
- (IBAction)jumpButtonPressed:(id)sender {
    if (position.y == 75) {
        speed = GLKVector2Make(speed.x, 300);
        [jumpSound play];
    }
}

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    //GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    //modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    //modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    //self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    if (leftButton.highlighted) direction = LEFT;
    else if (rightButton.highlighted) direction = RIGHT;
    speed = GLKVector2Make(((-2.0*leftButton.highlighted) + (2.0*rightButton.highlighted))*64,
                           speed.y + acceleration.y*self.timeSinceLastUpdate);
    position = GLKVector2Add(position, 
                             GLKVector2Add(GLKVector2MultiplyScalar(speed,self.timeSinceLastUpdate), 
                                           GLKVector2MultiplyScalar(acceleration,
                                                                    self.timeSinceLastUpdate*self.timeSinceLastUpdate)));
    acceleration.y = -9.81 * 64; // 64 pixels per meter
    if (position.y < 75) {
        position.y = 75;
        speed.y = 0;
    }

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static int frame = 0;
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
/*    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    //[self.effect prepareToDraw];
    
    //glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);*/

    
    glBindVertexArrayOES(_vertexArray2);

    glUseProgram(_program2);

    glActiveTexture(GL_TEXTURE0); 
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);

    GLKMatrix4 projectionMatrix;

    glBindTexture(GL_TEXTURE_2D, texture2.name);
    
    projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, 0.0f, 100.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 7.5, 5, 0);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX_2], 1, 0, projectionMatrix.m);
    
    glUniform2f(uniforms[UNIFORM_TEXTURE_OFFSET], 0, 0.5);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    //float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    //GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    glBindTexture(GL_TEXTURE_2D, texture.name);
    projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, 0.0f, 100.0f);
    
    projectionMatrix = GLKMatrix4Translate(projectionMatrix, position.x, position.y, 0);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, direction, 1, 1);
    projectionMatrix = GLKMatrix4Translate(projectionMatrix, -32,0, 0);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX_2], 1, 0, projectionMatrix.m);

    if (speed.x != 0) {
        switch ((frame++)/5 % 3) {
            case 0:
                glUniform2f(uniforms[UNIFORM_TEXTURE_OFFSET], 0, 0);
                break;
            case 1 :
                glUniform2f(uniforms[UNIFORM_TEXTURE_OFFSET], 0.5, 0);
                break;
            case 2:
                glUniform2f(uniforms[UNIFORM_TEXTURE_OFFSET], 0, 0.5);
                break;            
            default:
                break;
        }
    } else {
        glUniform2f(uniforms[UNIFORM_TEXTURE_OFFSET], 0.5, 0);
    }
    
    glDrawArrays(GL_TRIANGLES, 0, 6);


    //glBindTexture(GL_TEXTURE_2D, texture2.name);
    //glDrawArrays(GL_TRIANGLES, 0, 6);
    

}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    GLuint vertShader2, fragShader2;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    
    
    _program2 = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader2" ofType:@"vsh"];
    NSLog(@"%@", vertShaderPathname);
    
    if (![self compileShader:&vertShader2 type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader2" ofType:@"fsh"];
    if (![self compileShader:&fragShader2 type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program2, vertShader2);
    
    // Attach fragment shader to program.
    glAttachShader(_program2, fragShader2);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program2, GLKVertexAttribPosition, "position2");
    glBindAttribLocation(_program2, GLKVertexAttribTexCoord0, "texcoord0");

    
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }

    
    // Link program.
    if (![self linkProgram:_program2]) {
        NSLog(@"Failed to link program: %d", _program2);
        
        if (vertShader) {
            glDeleteShader(vertShader2);
            vertShader2 = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader2);
            fragShader2 = 0;
        }
        if (_program2) {
            glDeleteProgram(_program2);
            _program2 = 0;
        }
        
        return NO;
    }
    
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");

    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX_2] = glGetUniformLocation(_program2, "modelViewProjectionMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program2, "Texture");
    uniforms[UNIFORM_TEXTURE_OFFSET] = glGetUniformLocation(_program2, "textureOffset");

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }

    
    if (vertShader2) {
        glDetachShader(_program2, vertShader2);
        glDeleteShader(vertShader2);
    }
    if (fragShader2) {
        glDetachShader(_program2, fragShader2);
        glDeleteShader(fragShader2);
    }
    
    return YES;
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
