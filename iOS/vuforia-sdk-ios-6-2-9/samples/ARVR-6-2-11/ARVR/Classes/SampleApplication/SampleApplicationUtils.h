/*===============================================================================
Copyright (c) 2015-2016 PTC Inc. All Rights Reserved.

 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#ifndef __SHADERUTILS_H__
#define __SHADERUTILS_H__


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <Vuforia/Matrices.h>
#import <Vuforia/Vectors.h>


namespace SampleApplicationUtils
{
    // Print a 4x4 matrix
    void printMatrix(const float* matrix);
    
    // Print GL error information
    void checkGlError(const char* operation);
    
    int glhProjectf(float objx, float objy, float objz, float *modelview, float *projection, int *viewport, float *windowCoordinate);
    
    // Set the rotation components of a 4x4 matrix
    void setRotationMatrix(float angle, float x, float y, float z, 
                           float *nMatrix);
    
    // Set the translation components of a 4x4 matrix
    void translatePoseMatrix(float x, float y, float z,
                             float* nMatrix = NULL);
    
    // Apply a rotation
    void rotatePoseMatrix(float angle, float x, float y, float z, 
                          float* nMatrix = NULL);
    
    // Apply a scaling transformation
    void scalePoseMatrix(float x, float y, float z, 
                         float* nMatrix = NULL);
    
    // Multiply the two matrices A and B and write the result to C
    void multiplyMatrix(float *matrixA, float *matrixB, 
                        float *matrixC);
    
    void multiplyMatrix3x3(float *matrixA, float *matrixB, float *matrixC);
    
    void mtx3x3Transpose(float* mtx, const float* src);
    
    /// Use the matrix to project the extents of the video background to the viewport
    /// This will generate normalised coordinates (ie full viewport has -1,+1 range)
    /// to create a rectangle that can be used to set a scissor on the video background
    void getScissorRect(const Vuforia::Matrix44F& projectionMatrix,
                        const Vuforia::Vec4I& viewport,
                        Vuforia::Vec4I& scissorRect);
    
    // Initialise a shader
    int initShader(GLenum nShaderType, const char* pszSource, const char* pszDefs = NULL);
    
    void setOrthoMatrix(float nLeft, float nRight, float nBottom, float nTop,
                        float nNear, float nFar, float *nProjMatrix);
    
    void screenCoordToCameraCoord(int screenX, int screenY, int screenDX, int screenDY,
                                  int screenWidth, int screenHeight, int cameraWidth, int cameraHeight,
                                  int * cameraX, int* cameraY, int * cameraDX, int * cameraDY);
}

#endif  // __SHADERUTILS_H__
