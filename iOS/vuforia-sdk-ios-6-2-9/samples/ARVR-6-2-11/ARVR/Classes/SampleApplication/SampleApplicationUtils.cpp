/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.

 Copyright (c) 2012-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
 Vuforia is a trademark of PTC Inc., registered in the United States and other
 countries.
 ===============================================================================*/

#include <math.h>
#include <stdio.h>
#include <string.h>
#include "SampleApplicationUtils.h"
#include <Vuforia/Tool.h>


namespace SampleApplicationUtils
{
    // Print a 4x4 matrix
    void
    printMatrix(const float* mat)
    {
        for (int r = 0; r < 4; r++, mat += 4) {
            printf("%7.3f %7.3f %7.3f %7.3f", mat[0], mat[1], mat[2], mat[3]);
        }
    }
    
    
    // Print GL error information
    void
    checkGlError(const char* operation)
    { 
        for (GLint error = glGetError(); error; error = glGetError()) {
            printf("after %s() glError (0x%x)\n", operation, error);
        }
    }
    
    int glhProjectf(float objx, float objy, float objz, float *modelview, float *projection, int *viewport, float *windowCoordinate)
    {
        //Transformation vectors
        float fTempo[8];
        //Modelview transform
        fTempo[0]=modelview[0]*objx+modelview[4]*objy+modelview[8]*objz+modelview[12];  //w is always 1
        fTempo[1]=modelview[1]*objx+modelview[5]*objy+modelview[9]*objz+modelview[13];
        fTempo[2]=modelview[2]*objx+modelview[6]*objy+modelview[10]*objz+modelview[14];
        fTempo[3]=modelview[3]*objx+modelview[7]*objy+modelview[11]*objz+modelview[15];
        //Projection transform, the final row of projection matrix is always [0 0 -1 0]
        //so we optimize for that.
        fTempo[4]=projection[0]*fTempo[0]+projection[4]*fTempo[1]+projection[8]*fTempo[2]+projection[12]*fTempo[3];
        fTempo[5]=projection[1]*fTempo[0]+projection[5]*fTempo[1]+projection[9]*fTempo[2]+projection[13]*fTempo[3];
        fTempo[6]=projection[2]*fTempo[0]+projection[6]*fTempo[1]+projection[10]*fTempo[2]+projection[14]*fTempo[3];
        fTempo[7]=-fTempo[2];
        //The result normalizes between -1 and 1
        if(fTempo[7]==0.0)	//The w value
            return 0;
        fTempo[7]=1.0/fTempo[7];
        //Perspective division
        fTempo[4]*=fTempo[7];
        fTempo[5]*=fTempo[7];
        fTempo[6]*=fTempo[7];
        //Window coordinates
        //Map x, y to range 0-1
        windowCoordinate[0]=(fTempo[4]*0.5+0.5)*viewport[2]+viewport[0];
        windowCoordinate[1]=(fTempo[5]*0.5+0.5)*viewport[3]+viewport[1];
        //This is only correct when glDepthRange(0.0, 1.0)
        windowCoordinate[2]=(1.0+fTempo[6])*0.5;	//Between 0 and 1
        return 1;
    }
    
    
    // Set the rotation components of a 4x4 matrix
    void
    setRotationMatrix(float angle, float x, float y, float z, 
                                   float *matrix)
    {
        double radians, c, s, c1, u[3], length;
        int i, j;
        
        radians = (angle * M_PI) / 180.0;
        
        c = cos(radians);
        s = sin(radians);
        
        c1 = 1.0 - cos(radians);
        
        length = sqrt(x * x + y * y + z * z);
        
        u[0] = x / length;
        u[1] = y / length;
        u[2] = z / length;
        
        for (i = 0; i < 16; i++) {
            matrix[i] = 0.0;
        }
        
        matrix[15] = 1.0;
        
        for (i = 0; i < 3; i++) {
            matrix[i * 4 + (i + 1) % 3] = u[(i + 2) % 3] * s;
            matrix[i * 4 + (i + 2) % 3] = -u[(i + 1) % 3] * s;
        }
        
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                matrix[i * 4 + j] += c1 * u[i] * u[j] + (i == j ? c : 0.0);
            }
        }
    }
    
    
    // Set the translation components of a 4x4 matrix
    void
    translatePoseMatrix(float x, float y, float z, float* matrix)
    {
        if (matrix) {
            // matrix * translate_matrix
            matrix[12] += (matrix[0] * x + matrix[4] * y + matrix[8]  * z);
            matrix[13] += (matrix[1] * x + matrix[5] * y + matrix[9]  * z);
            matrix[14] += (matrix[2] * x + matrix[6] * y + matrix[10] * z);
            matrix[15] += (matrix[3] * x + matrix[7] * y + matrix[11] * z);
        }
    }
    
    
    // Apply a rotation
    void
    rotatePoseMatrix(float angle, float x, float y, float z,
                                  float* matrix)
    {
        if (matrix) {
            float rotate_matrix[16];
            setRotationMatrix(angle, x, y, z, rotate_matrix);
            
            // matrix * scale_matrix
            multiplyMatrix(matrix, rotate_matrix, matrix);
        }
    }
    
    
    // Apply a scaling transformation
    void
    scalePoseMatrix(float x, float y, float z, float* matrix)
    {
        if (matrix) {
            // matrix * scale_matrix
            matrix[0]  *= x;
            matrix[1]  *= x;
            matrix[2]  *= x;
            matrix[3]  *= x;
            
            matrix[4]  *= y;
            matrix[5]  *= y;
            matrix[6]  *= y;
            matrix[7]  *= y;
            
            matrix[8]  *= z;
            matrix[9]  *= z;
            matrix[10] *= z;
            matrix[11] *= z;
        }
    }
    
    
    // Multiply the two matrices A and B and write the result to C
    void
    multiplyMatrix(float *matrixA, float *matrixB, float *matrixC)
    {
        int i, j, k;
        float aTmp[16];
        
        for (i = 0; i < 4; i++) {
            for (j = 0; j < 4; j++) {
                aTmp[j * 4 + i] = 0.0;
                
                for (k = 0; k < 4; k++) {
                    aTmp[j * 4 + i] += matrixA[k * 4 + i] * matrixB[j * 4 + k];
                }
            }
        }
        
        for (i = 0; i < 16; i++) {
            matrixC[i] = aTmp[i];
        }
    }
    
    // Multiply the two matrices A and B and write the result to C
    void
    multiplyMatrix3x3(float *matrixA, float *matrixB, float *matrixC)
    {
        int i, j, k;
        float aTmp[9];
        
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                aTmp[j * 3 + i] = 0.0;
                
                for (k = 0; k < 3; k++) {
                    aTmp[j * 3 + i] += matrixA[k * 3 + i] * matrixB[j * 3 + k];
                }
            }
        }
        
        for (i = 0; i < 9; i++) {
            matrixC[i] = aTmp[i];
        }
    }
    
    void mtx3x3Transpose(float* mtx, const float* src)
    {
        float tmp;
        mtx[0] = src[0];
        mtx[4] = src[4];
        mtx[8] = src[8];
        
        tmp = src[1];
        mtx[1] = src[3];
        mtx[3] = tmp;
        
        tmp = src[2];
        mtx[2] = src[6];
        mtx[6] = tmp;
        
        tmp = src[5];
        mtx[5] = src[7];
        mtx[7] = tmp;
    }
    
   void
    getScissorRect(const Vuforia::Matrix44F& projectionMatrix,
                   const Vuforia::Vec4I& viewport,
                   Vuforia::Vec4I& scissorRect)
    {
        
        // Use the matrix to project the extents of the video background to the viewport
        // This will generate normalised coordinates (ie full viewport has -1,+1 range)
        Vuforia::Vec4F vbMin = Vuforia::Vec4F(-1, -1, 0, 1);
        Vuforia::Vec4F vbMax = Vuforia::Vec4F( 1,  1, 0, 1);
        
        Vuforia::Vec4F viewportCentreToVBMin = Vuforia::Tool::multiply(vbMin, projectionMatrix);
        Vuforia::Vec4F viewportCentreToVBMax = Vuforia::Tool::multiply(vbMax, projectionMatrix);
        
        // Convert the normalised coordinates to screen pixels
        float pixelsPerUnitX = viewport.data[2] / 2.0f; // as left and right are 2 units apart
        float pixelsPerUnitY = viewport.data[3] / 2.0f; // as top and bottom are 2 units apart
        float screenMinToViewportCentrePixelsX = viewport.data[0] + pixelsPerUnitX;
        float screenMinToViewportCentrePixelsY = viewport.data[1] + pixelsPerUnitY;
        
        float viewportCentreToVBMinPixelsX = viewportCentreToVBMin.data[0] * pixelsPerUnitX;
        float viewportCentreToVBMinPixelsY = viewportCentreToVBMin.data[1] * pixelsPerUnitY;
        float viewportCentreToVBMaxPixelsX = viewportCentreToVBMax.data[0] * pixelsPerUnitX;
        float viewportCentreToVBMaxPixelsY = viewportCentreToVBMax.data[1] * pixelsPerUnitY;
        
        // Calculate the extents of the video background on the screen
        scissorRect.data[0] = static_cast<int>(screenMinToViewportCentrePixelsX + viewportCentreToVBMinPixelsX);
        scissorRect.data[1] = static_cast<int>(screenMinToViewportCentrePixelsY + viewportCentreToVBMinPixelsY);
        scissorRect.data[2] = static_cast<int>(viewportCentreToVBMaxPixelsX - viewportCentreToVBMinPixelsX);
        scissorRect.data[3] = static_cast<int>(viewportCentreToVBMaxPixelsY - viewportCentreToVBMinPixelsY);
    }
    
    // Initialise a shader
    int
    initShader(GLenum nShaderType, const char* pszSource, const char* pszDefs)
    {
        GLuint shader = glCreateShader(nShaderType);
        
        if (shader) {
            if(pszDefs == NULL)
            {
                glShaderSource(shader, 1, &pszSource, NULL);
            }
            else
            {   
                const char* finalShader[2] = {pszDefs,pszSource};
                GLint finalShaderSizes[2] = {static_cast<GLint>(strlen(pszDefs)), static_cast<GLint>(strlen(pszSource))};
                glShaderSource(shader, 2, finalShader, finalShaderSizes);
            }
            
            glCompileShader(shader);
            GLint compiled = 0;
            glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
            
            if (!compiled) {
                GLint infoLen = 0;
                glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
                
                if (infoLen) {
                    char* buf = new char[infoLen];
                    glGetShaderInfoLog(shader, infoLen, NULL, buf);
                    printf("Could not compile shader %d: %s\n", shader, buf);
                    delete[] buf;
                }
            }
        }
        
        return shader;
    }
    
    
    // Create a shader program
    int
    createProgramFromBuffer(const char* pszVertexSource,
                            const char* pszFragmentSource,
                            const char* pszVertexShaderDefs,
                            const char* pszFragmentShaderDefs)

    {
        GLuint program = 0;
        GLuint vertexShader = initShader(GL_VERTEX_SHADER, pszVertexSource, pszVertexShaderDefs);
        GLuint fragmentShader = initShader(GL_FRAGMENT_SHADER, pszFragmentSource, pszFragmentShaderDefs);
        
        if (vertexShader && fragmentShader) {
            program = glCreateProgram();
            
            if (program) {
                glAttachShader(program, vertexShader);
                checkGlError("glAttachShader");
                glAttachShader(program, fragmentShader);
                checkGlError("glAttachShader");
                
                glLinkProgram(program);
                GLint linkStatus;
                glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
                
                if (GL_TRUE != linkStatus) {
                    GLint infoLen = 0;
                    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
                    
                    if (infoLen) {
                        char* buf = new char[infoLen];
                        glGetProgramInfoLog(program, infoLen, NULL, buf);
                        printf("Could not link program %d: %s\n", program, buf);
                        delete[] buf;
                    }
                }
            }
        }
        
        return program;
    }
    
    
    void
    setOrthoMatrix(float nLeft, float nRight, float nBottom, float nTop, 
                                float nNear, float nFar, float *nProjMatrix)
    {
        if (!nProjMatrix)
        {
            //         arLogMessage(AR_LOG_LEVEL_ERROR, "PLShadersExample", "Orthographic projection matrix pointer is NULL");
            return;
        }       
        
        int i;
        for (i = 0; i < 16; i++)
            nProjMatrix[i] = 0.0f;
        
        nProjMatrix[0] = 2.0f / (nRight - nLeft);
        nProjMatrix[5] = 2.0f / (nTop - nBottom);
        nProjMatrix[10] = 2.0f / (nNear - nFar);
        nProjMatrix[12] = -(nRight + nLeft) / (nRight - nLeft);
        nProjMatrix[13] = -(nTop + nBottom) / (nTop - nBottom);
        nProjMatrix[14] = (nFar + nNear) / (nFar - nNear);
        nProjMatrix[15] = 1.0f;
    }
    
    // Transforms a screen pixel to a pixel onto the camera image,
    // taking into account e.g. cropping of camera image to fit different aspect ratio screen.
    // for the camera dimensions, the width is always bigger than the height (always landscape orientation)
    // Top left of screen/camera is origin
    void
    screenCoordToCameraCoord(int screenX, int screenY, int screenDX, int screenDY,
                             int screenWidth, int screenHeight, int cameraWidth, int cameraHeight,
                             int * cameraX, int* cameraY, int * cameraDX, int * cameraDY)
    {
        
        printf("screenCoordToCameraCoord:%d,%d %d,%d, %d,%d, %d,%d",screenX, screenY, screenDX, screenDY,
              screenWidth, screenHeight, cameraWidth, cameraHeight );

        
        bool isPortraitMode = (screenWidth < screenHeight);
        float videoWidth, videoHeight;
        videoWidth = (float)cameraWidth;
        videoHeight = (float)cameraHeight;
        if (isPortraitMode)
        {
            // the width and height of the camera are always
            // based on a landscape orientation
            // videoWidth = (float)cameraHeight;
            // videoHeight = (float)cameraWidth;
            
            
            // as the camera coordinates are always in landscape
            // we convert the inputs into a landscape based coordinate system
            int tmp = screenX;
            screenX = screenY;
            screenY = screenWidth - tmp;
            
            tmp = screenDX;
            screenDX = screenDY;
            screenDY = tmp;
            
            tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
            
        }
        else
        {
            videoWidth = (float)cameraWidth;
            videoHeight = (float)cameraHeight;
        }
        
        float videoAspectRatio = videoHeight / videoWidth;
        float screenAspectRatio = (float) screenHeight / (float) screenWidth;
        
        float scaledUpX;
        float scaledUpY;
        float scaledUpVideoWidth;
        float scaledUpVideoHeight;
        
        if (videoAspectRatio < screenAspectRatio)
        {
            // the video height will fit in the screen height
            scaledUpVideoWidth = (float)screenHeight / videoAspectRatio;
            scaledUpVideoHeight = screenHeight;
            scaledUpX = (float)screenX + ((scaledUpVideoWidth - (float)screenWidth) / 2.0f);
            scaledUpY = (float)screenY;
        }
        else
        {
            // the video width will fit in the screen width
            scaledUpVideoHeight = (float)screenWidth * videoAspectRatio;
            scaledUpVideoWidth = screenWidth;
            scaledUpY = (float)screenY + ((scaledUpVideoHeight - (float)screenHeight)/2.0f);
            scaledUpX = (float)screenX;
        }
        
        if (cameraX)
        {
            *cameraX = (int)((scaledUpX / (float)scaledUpVideoWidth) * videoWidth);
        }
        
        if (cameraY)
        {
            *cameraY = (int)((scaledUpY / (float)scaledUpVideoHeight) * videoHeight);
        }
        
        if (cameraDX)
        {
            *cameraDX = (int)(((float)screenDX / (float)scaledUpVideoWidth) * videoWidth);
        }
        
        if (cameraDY)
        {
            *cameraDY = (int)(((float)screenDY / (float)scaledUpVideoHeight) * videoHeight);
        }
    }

    
}   // namespace ShaderUtils
