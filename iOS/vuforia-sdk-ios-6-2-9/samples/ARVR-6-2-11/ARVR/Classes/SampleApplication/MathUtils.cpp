/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.


Copyright (c) 2010-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/

#include "MathUtils.h"

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
#define NULL 0
#define M_PI 3.1415926535897932384626433832795
#endif


// Utility for logging:
#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
#define LOG(...) printf(__VA_ARGS__)
#elif defined(ANDROID) || defined (__ANDROID__)
#include <android/log.h>
#define LOG_TAG    "Vuforia"
#define LOG(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#elif defined(__APPLE__) 
#define LOG(...) printf(__VA_ARGS__)
#elif defined(__linux)
#define LOG(...) printf(__VA_ARGS__)
#endif

Vuforia::Vec2F
MathUtils::Vec2FUnit()
{
    Vuforia::Vec2F v;

    v.data[0] = 1.0f;
    v.data[1] = 1.0f;

    return v;
}

Vuforia::Vec2F
MathUtils::Vec2FOpposite(const Vuforia::Vec2F& v)
{
    Vuforia::Vec2F r;

    r.data[0] = -v.data[0];
    r.data[1] = -v.data[1];

    return r;
}


Vuforia::Vec2F
MathUtils::Vec2FAdd(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2)
{
    Vuforia::Vec2F r;

    r.data[0] = v1.data[0] + v2.data[0];
    r.data[1] = v1.data[1] + v2.data[1];

    return r;
}

Vuforia::Vec2F
MathUtils::Vec2FSub(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2)
{
    Vuforia::Vec2F r;

    r.data[0] = v1.data[0] - v2.data[0];
    r.data[1] = v1.data[1] - v2.data[1];

    return r;
}

float
MathUtils::Vec2FDist(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2)
{
    float dx = v1.data[0] - v2.data[0];
    float dy = v1.data[1] - v2.data[1];

    return sqrt(dx * dx + dy * dy);
}

Vuforia::Vec2F
MathUtils::Vec2FScale(const Vuforia::Vec2F& v, float s)
{
    Vuforia::Vec2F r;

    r.data[0] = v.data[0] * s;
    r.data[1] = v.data[1] * s;

    return r;
}

float
MathUtils::Vec2FNorm(const Vuforia::Vec2F& v)
{
    return sqrt(v.data[0] * v.data[0] + v.data[1] * v.data[1]);
}


void
MathUtils::printVector(const Vuforia::Vec2F& v)
{
    LOG("Vector = { %7.3f %7.3f}\n", v.data[0], v.data[1]);
}


Vuforia::Vec3F
MathUtils::Vec3FUnit()
{
    Vuforia::Vec3F v;

    v.data[0] = 1.0f;
    v.data[1] = 1.0f;
    v.data[2] = 1.0f;

    return v;
}

Vuforia::Vec3F 
MathUtils::Vec3FOpposite(const Vuforia::Vec3F& v)
{
    Vuforia::Vec3F r;

    r.data[0] = -v.data[0];
    r.data[1] = -v.data[1];
    r.data[2] = -v.data[2];

    return r;
}


Vuforia::Vec3F
MathUtils::Vec3FAdd(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2)
{
    Vuforia::Vec3F r;

    r.data[0] = v1.data[0] + v2.data[0];
    r.data[1] = v1.data[1] + v2.data[1];
    r.data[2] = v1.data[2] + v2.data[2];

    return r;
}


Vuforia::Vec3F
MathUtils::Vec3FSub(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2)
{
    Vuforia::Vec3F r;

    r.data[0] = v1.data[0] - v2.data[0];
    r.data[1] = v1.data[1] - v2.data[1];
    r.data[2] = v1.data[2] - v2.data[2];

    return r;
}

float 
MathUtils::Vec3FDist(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2)
{
    float dx = v1.data[0] - v2.data[0];
    float dy = v1.data[1] - v2.data[1];
    float dz = v1.data[2] - v2.data[2];

    return sqrt(dx * dx + dy * dy + dz* dz);
}

Vuforia::Vec3F
MathUtils::Vec3FScale(const Vuforia::Vec3F& v, float s)
{
    Vuforia::Vec3F r;

    r.data[0] = v.data[0] * s;
    r.data[1] = v.data[1] * s;
    r.data[2] = v.data[2] * s;

    return r;
}


float
MathUtils::Vec3FDot(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2)
{
    return v1.data[0] * v2.data[0] + v1.data[1] * v2.data[1] + v1.data[2] * v2.data[2];
}


Vuforia::Vec3F
MathUtils::Vec3FCross(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2)
{
    Vuforia::Vec3F r;

    r.data[0] = v1.data[1] * v2.data[2] - v1.data[2] * v2.data[1];
    r.data[1] = v1.data[2] * v2.data[0] - v1.data[0] * v2.data[2];
    r.data[2] = v1.data[0] * v2.data[1] - v1.data[1] * v2.data[0];

    return r;
}


Vuforia::Vec3F
MathUtils::Vec3FNormalize(const Vuforia::Vec3F& v)
{
    Vuforia::Vec3F r;
    
    float length = sqrt(v.data[0] * v.data[0] + v.data[1] * v.data[1] + v.data[2] * v.data[2]);
    if (length != 0.0f)
        length = 1.0f / length;
    
    r.data[0] = v.data[0] * length;
    r.data[1] = v.data[1] * length;
    r.data[2] = v.data[2] * length;
    
    return r;
}


Vuforia::Vec3F
MathUtils::Vec3FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v)
{
    Vuforia::Vec3F r;

    // consider vector v as 4d vector with w=1.0
    r.data[0] = m.data[0] * v.data[0] +
        m.data[4] * v.data[1] +
        m.data[8] * v.data[2] +
        m.data[12];
    r.data[1] = m.data[1] * v.data[0] +
        m.data[5] * v.data[1] +
        m.data[9] * v.data[2] +
        m.data[13];
    r.data[2] = m.data[2] * v.data[0] +
        m.data[6] * v.data[1] +
        m.data[10] * v.data[2] +
        m.data[14];

    return r;
}

// code from SampleMaths, not sure about implementation here
Vuforia::Vec3F
MathUtils::Vec3FTransformR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m)
{
    Vuforia::Vec3F r;
    float lambda;

    lambda    = m.data[12] * v.data[0] +
                m.data[13] * v.data[1] +
                m.data[14] * v.data[2] +
                m.data[15];

    r.data[0] = m.data[0] * v.data[0] +
                m.data[1] * v.data[1] +
                m.data[2] * v.data[2] +
                m.data[3];
    r.data[1] = m.data[4] * v.data[0] +
                m.data[5] * v.data[1] +
                m.data[6] * v.data[2] +
                m.data[7];
    r.data[2] = m.data[8] * v.data[0] +
                m.data[9] * v.data[1] +
                m.data[10] * v.data[2] +
                m.data[11];
    
    r.data[0] /= lambda;
    r.data[1] /= lambda;
    r.data[2] /= lambda;

    return r;
}

Vuforia::Vec3F
MathUtils::Vec3FTransformNormal(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v)
{
    Vuforia::Vec3F r;
    
    r.data[0] = m.data[0] * v.data[0] +
                m.data[4] * v.data[1] +
                m.data[8] * v.data[2];
    r.data[1] = m.data[1] * v.data[0] +
                m.data[5] * v.data[1] +
                m.data[9] * v.data[2];
    r.data[2] = m.data[2] * v.data[0] +
                m.data[6] * v.data[1] +
                m.data[10] * v.data[2];
    
    return r;
}

Vuforia::Vec3F
MathUtils::Vec3FTransformNormalR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m)
{
    Vuforia::Vec3F r;

    r.data[0] = m.data[0] * v.data[0] +
        m.data[1] * v.data[1] +
        m.data[2] * v.data[2];
    r.data[1] = m.data[4] * v.data[0] +
        m.data[5] * v.data[1] +
        m.data[6] * v.data[2];
    r.data[2] = m.data[8] * v.data[0] +
        m.data[9] * v.data[1] +
        m.data[10] * v.data[2];

    return r;
}



float 
MathUtils::Vec3FNorm(const Vuforia::Vec3F& v)
{
    return sqrt(v.data[0] * v.data[0] + v.data[1] * v.data[1] + v.data[2] * v.data[2]);
}


void
MathUtils::printVector(const Vuforia::Vec3F& v)
{
    LOG("Vector = { %7.3f %7.3f %7.3f}\n", v.data[0], v.data[1], v.data[2]);
}


Vuforia::Vec4F
MathUtils::Vec4FUnit()
{
    Vuforia::Vec4F v;

    v.data[0] = 1.0f;
    v.data[1] = 1.0f;
    v.data[2] = 1.0f;
    v.data[3] = 1.0f;

    return v;
}

Vuforia::Vec4F
MathUtils::Vec4FScale(const Vuforia::Vec4F& v, float s)
{
    Vuforia::Vec4F r;

    r.data[0] = v.data[0] * s;
    r.data[1] = v.data[1] * s;
    r.data[2] = v.data[2] * s;
    r.data[3] = v.data[3] * s;

    return r;
}

Vuforia::Vec4F
MathUtils::Vec4FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec4F& v)
{
    Vuforia::Vec4F r;

    r.data[0] = m.data[0] * v.data[0] +
        m.data[4] * v.data[1] +
        m.data[8] * v.data[2] +
        m.data[12] * v.data[3];
    r.data[1] = m.data[1] * v.data[0] +
        m.data[5] * v.data[1] +
        m.data[9] * v.data[2] +
        m.data[13] * v.data[3];
    r.data[2] = m.data[2] * v.data[0] +
        m.data[6] * v.data[1] +
        m.data[10] * v.data[2] +
        m.data[14] * v.data[3];
    r.data[3] = m.data[3] * v.data[0] +
        m.data[7] * v.data[1] +
        m.data[11] * v.data[2] +
        m.data[15] * v.data[3];

    return r;
}

Vuforia::Vec4F
MathUtils::Vec4FTransformR(const Vuforia::Vec4F& v, const Vuforia::Matrix44F& m)
{
    Vuforia::Vec4F r;

    r.data[0] = m.data[0] * v.data[0] +
        m.data[1] * v.data[1] +
        m.data[2] * v.data[2] +
        m.data[3] * v.data[3];
    r.data[1] = m.data[4] * v.data[0] +
        m.data[5] * v.data[1] +
        m.data[6] * v.data[2] +
        m.data[7] * v.data[3];
    r.data[2] = m.data[8] * v.data[0] +
        m.data[9] * v.data[1] +
        m.data[10] * v.data[2] +
        m.data[11] * v.data[3];
    r.data[3] = m.data[12] * v.data[0] +
        m.data[13] * v.data[1] +
        m.data[14] * v.data[2] +
        m.data[15] * v.data[3];

    return r;
}
void
MathUtils::printVector(const Vuforia::Vec4F& v)
{
    LOG("Vector = { %7.3f %7.3f %7.3f %7.3f}\n", v.data[0], v.data[1], v.data[2], v.data[3]);
}


Vuforia::Matrix44F
MathUtils::Matrix44FIdentity()
{
    Vuforia::Matrix44F r;
    
    for (int i = 0; i < 16; i++)
        r.data[i] = 0.0f;
    
    r.data[0] = 1.0f;
    r.data[5] = 1.0f;
    r.data[10] = 1.0f;
    r.data[15] = 1.0f;
    
    return r;
}

Vuforia::Matrix34F
MathUtils::Matrix34FIdentity()
{
    Vuforia::Matrix34F r;
    
    for (int i = 0; i < 12; i++)
        r.data[i] = 0.0f;
    
    r.data[0] = 1.0f;
    r.data[5] = 1.0f;
    r.data[10] = 1.0f;
    
    return r;
}

Vuforia::Matrix44F
MathUtils::Matrix44FTranspose(const Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F r;
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            r.data[i*4+j] = m.data[i+4*j];
    return r;
}


float
MathUtils::Matrix44FDeterminate(const Vuforia::Matrix44F& m)
{
    return  m.data[12] * m.data[9] * m.data[6] * m.data[3] - m.data[8] * m.data[13] * m.data[6] * m.data[3] -
            m.data[12] * m.data[5] * m.data[10] * m.data[3] + m.data[4] * m.data[13] * m.data[10] * m.data[3] +
            m.data[8] * m.data[5] * m.data[14] * m.data[3] - m.data[4] * m.data[9] * m.data[14] * m.data[3] -
            m.data[12] * m.data[9] * m.data[2] * m.data[7] + m.data[8] * m.data[13] * m.data[2] * m.data[7] +
            m.data[12] * m.data[1] * m.data[10] * m.data[7] - m.data[0] * m.data[13] * m.data[10] * m.data[7] -
            m.data[8] * m.data[1] * m.data[14] * m.data[7] + m.data[0] * m.data[9] * m.data[14] * m.data[7] +
            m.data[12] * m.data[5] * m.data[2] * m.data[11] - m.data[4] * m.data[13] * m.data[2] * m.data[11] -
            m.data[12] * m.data[1] * m.data[6] * m.data[11] + m.data[0] * m.data[13] * m.data[6] * m.data[11] +
            m.data[4] * m.data[1] * m.data[14] * m.data[11] - m.data[0] * m.data[5] * m.data[14] * m.data[11] -
            m.data[8] * m.data[5] * m.data[2] * m.data[15] + m.data[4] * m.data[9] * m.data[2] * m.data[15] +
            m.data[8] * m.data[1] * m.data[6] * m.data[15] - m.data[0] * m.data[9] * m.data[6] * m.data[15] -
            m.data[4] * m.data[1] * m.data[10] * m.data[15] + m.data[0] * m.data[5] * m.data[10] * m.data[15] ;
}


Vuforia::Matrix44F
MathUtils::Matrix44FInverse(const Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F r;
    
    float det = 1.0f / Matrix44FDeterminate(m);
    
    r.data[0]   = m.data[6]*m.data[11]*m.data[13] - m.data[7]*m.data[10]*m.data[13]
                + m.data[7]*m.data[9]*m.data[14] - m.data[5]*m.data[11]*m.data[14]
                - m.data[6]*m.data[9]*m.data[15] + m.data[5]*m.data[10]*m.data[15];
    
    r.data[4]   = m.data[3]*m.data[10]*m.data[13] - m.data[2]*m.data[11]*m.data[13]
                - m.data[3]*m.data[9]*m.data[14] + m.data[1]*m.data[11]*m.data[14]
                + m.data[2]*m.data[9]*m.data[15] - m.data[1]*m.data[10]*m.data[15];
    
    r.data[8]   = m.data[2]*m.data[7]*m.data[13] - m.data[3]*m.data[6]*m.data[13]
                + m.data[3]*m.data[5]*m.data[14] - m.data[1]*m.data[7]*m.data[14]
                - m.data[2]*m.data[5]*m.data[15] + m.data[1]*m.data[6]*m.data[15];
    
    r.data[12]  = m.data[3]*m.data[6]*m.data[9] - m.data[2]*m.data[7]*m.data[9]
                - m.data[3]*m.data[5]*m.data[10] + m.data[1]*m.data[7]*m.data[10]
                + m.data[2]*m.data[5]*m.data[11] - m.data[1]*m.data[6]*m.data[11];
    
    r.data[1]   = m.data[7]*m.data[10]*m.data[12] - m.data[6]*m.data[11]*m.data[12]
                - m.data[7]*m.data[8]*m.data[14] + m.data[4]*m.data[11]*m.data[14]
                + m.data[6]*m.data[8]*m.data[15] - m.data[4]*m.data[10]*m.data[15];
    
    r.data[5]   = m.data[2]*m.data[11]*m.data[12] - m.data[3]*m.data[10]*m.data[12]
                + m.data[3]*m.data[8]*m.data[14] - m.data[0]*m.data[11]*m.data[14]
                - m.data[2]*m.data[8]*m.data[15] + m.data[0]*m.data[10]*m.data[15];
    
    r.data[9]   = m.data[3]*m.data[6]*m.data[12] - m.data[2]*m.data[7]*m.data[12]
                - m.data[3]*m.data[4]*m.data[14] + m.data[0]*m.data[7]*m.data[14]
                + m.data[2]*m.data[4]*m.data[15] - m.data[0]*m.data[6]*m.data[15];
    
    r.data[13]  = m.data[2]*m.data[7]*m.data[8] - m.data[3]*m.data[6]*m.data[8]
                + m.data[3]*m.data[4]*m.data[10] - m.data[0]*m.data[7]*m.data[10]
                - m.data[2]*m.data[4]*m.data[11] + m.data[0]*m.data[6]*m.data[11];
    
    r.data[2]   = m.data[5]*m.data[11]*m.data[12] - m.data[7]*m.data[9]*m.data[12]
                + m.data[7]*m.data[8]*m.data[13] - m.data[4]*m.data[11]*m.data[13]
                - m.data[5]*m.data[8]*m.data[15] + m.data[4]*m.data[9]*m.data[15];
    
    r.data[6]   = m.data[3]*m.data[9]*m.data[12] - m.data[1]*m.data[11]*m.data[12]
                - m.data[3]*m.data[8]*m.data[13] + m.data[0]*m.data[11]*m.data[13]
                + m.data[1]*m.data[8]*m.data[15] - m.data[0]*m.data[9]*m.data[15];
    
    r.data[10]  = m.data[1]*m.data[7]*m.data[12] - m.data[3]*m.data[5]*m.data[12]
                + m.data[3]*m.data[4]*m.data[13] - m.data[0]*m.data[7]*m.data[13]
                - m.data[1]*m.data[4]*m.data[15] + m.data[0]*m.data[5]*m.data[15];
    
    r.data[14]  = m.data[3]*m.data[5]*m.data[8] - m.data[1]*m.data[7]*m.data[8]
                - m.data[3]*m.data[4]*m.data[9] + m.data[0]*m.data[7]*m.data[9]
                + m.data[1]*m.data[4]*m.data[11] - m.data[0]*m.data[5]*m.data[11];
    
    r.data[3]   = m.data[6]*m.data[9]*m.data[12] - m.data[5]*m.data[10]*m.data[12]
                - m.data[6]*m.data[8]*m.data[13] + m.data[4]*m.data[10]*m.data[13]
                + m.data[5]*m.data[8]*m.data[14] - m.data[4]*m.data[9]*m.data[14];
    
    r.data[7]  = m.data[1]*m.data[10]*m.data[12] - m.data[2]*m.data[9]*m.data[12]
                + m.data[2]*m.data[8]*m.data[13] - m.data[0]*m.data[10]*m.data[13] 
                - m.data[1]*m.data[8]*m.data[14] + m.data[0]*m.data[9]*m.data[14];
    
    r.data[11]  = m.data[2]*m.data[5]*m.data[12] - m.data[1]*m.data[6]*m.data[12]
                - m.data[2]*m.data[4]*m.data[13] + m.data[0]*m.data[6]*m.data[13]
                + m.data[1]*m.data[4]*m.data[14] - m.data[0]*m.data[5]*m.data[14];
    
    r.data[15]  = m.data[1]*m.data[6]*m.data[8] - m.data[2]*m.data[5]*m.data[8]
                + m.data[2]*m.data[4]*m.data[9] - m.data[0]*m.data[6]*m.data[9]
                - m.data[1]*m.data[4]*m.data[10] + m.data[0]*m.data[5]*m.data[10];
    
    for (int i = 0; i < 16; i++)
        r.data[i] *= det;
    
    return r;
}


Vuforia::Matrix44F 
MathUtils::Matrix44FTranslate(const Vuforia::Vec3F& trans, const Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F r;

    r= copyMatrix(m);
    translateMatrix(trans, r);

    return r;
}

Vuforia::Matrix44F 
MathUtils::Matrix44FRotate(float angle, const Vuforia::Vec3F& axis, const Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F r;

    r = copyMatrix(m);
    rotateMatrix(angle, axis, r);

    return r;
}

Vuforia::Matrix44F 
MathUtils::Matrix44FScale(const Vuforia::Vec3F& scale, const Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F r;

    r = copyMatrix(m);
    scaleMatrix(scale, r);

    return r;
}


Vuforia::Matrix44F 
MathUtils::Matrix44FPerspective(float fovy, float aspectRatio, float near, float far)
{
    Vuforia::Matrix44F r;

    makePerspectiveMatrix(fovy, aspectRatio, near, far, r);

    return r;
}


Vuforia::Matrix44F
MathUtils::Matrix44FPerspectiveGL(float fovy, float aspectRatio, float near, float far)
{
    Vuforia::Matrix44F r;

    makePerspectiveMatrixGL(fovy, aspectRatio, near, far, r);

    return r;
}

Vuforia::Matrix44F 
MathUtils::Matrix44FOrthographic(float left, float right, float bottom, float top, float near, float far)
{
    Vuforia::Matrix44F r;

    makeOrthographicMatrix(left, right, bottom, top, near, far, r);

    return r;
}

Vuforia::Matrix44F
MathUtils::Matrix44FOrthographicGL(float left, float right, float bottom, float top, float near, float far)
{
    Vuforia::Matrix44F r;

    makeOrthographicMatrixGL(left, right, bottom, top, near, far, r);

    return r;
}



void
MathUtils::printMatrix(const Vuforia::Matrix44F& m)
{
    LOG("Matrix = {\n");
    for (int r = 0; r < 4; r++)
        LOG("%7.3f %7.3f %7.3f %7.3f\n",m.data[r*4], m.data[r*4+1], m.data[r*4+2], m.data[r*4+3]);
    LOG("}\n");

}


Vuforia::Matrix44F
MathUtils::copyMatrix(const Vuforia::Matrix44F& m)
{
    return m;
}


void
MathUtils::makeRotationMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m)
{
    double radians, c, s, c1, u[3], length;
    int i, j;

    m = Matrix44FIdentity();

    radians = (angle * M_PI) / 180.0;

    c = cos(radians);
    s = sin(radians);

    c1 = 1.0 - cos(radians);

    length = sqrt(axis.data[0] * axis.data[0] + axis.data[1] * axis.data[1] + axis.data[2] * axis.data[2]);

    u[0] = axis.data[0] / length;
    u[1] = axis.data[1] / length;
    u[2] = axis.data[2] / length;

    for (i = 0; i < 16; i++)
        m.data[i] = 0.0;

    m.data[15] = 1.0;

    for (i = 0; i < 3; i++)
    {
        m.data[i * 4 + (i + 1) % 3] = (float)(u[(i + 2) % 3] * s);
        m.data[i * 4 + (i + 2) % 3] = (float)(-u[(i + 1) % 3] * s);
    }

    for (i = 0; i < 3; i++)
    {
        for (j = 0; j < 3; j++)
            m.data[i * 4 + j] += (float)(c1 * u[i] * u[j] + (i == j ? c : 0.0));
    }
}


void
MathUtils::makeTranslationMatrix(const Vuforia::Vec3F& trans, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    m.data[12] = trans.data[0];
    m.data[13] = trans.data[1];
    m.data[14] = trans.data[2];
}

void
MathUtils::makeScalingMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    m.data[0] = scale.data[0];
    m.data[5] = scale.data[1];
    m.data[10] = scale.data[2];
}

void 
MathUtils::makePerspectiveMatrix(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    float radiansFOVY = (fovy * M_PI) / 180.0f;

    float ymax = near * tanf(radiansFOVY);
    float xmax = ymax * aspectRatio;

    float v0 = 2.0f * near;
    float v1 = 2.0f * xmax;
    float v2 = 2.0f * ymax;
    float v3 = far + near;
    float v4 = far - near;

    m.data[0] = v0 / v1;  m.data[4] = 0.0f;  m.data[8] = 0.0f;  m.data[12] = 0.0f;
    m.data[1] = 0.0f;  m.data[5] = -v0 / v2;  m.data[9] = 0.0f;  m.data[13] = 0.0f;
    m.data[2] = 0.0f;  m.data[6] = 0.0f;  m.data[10] = v3 / v4;  m.data[14] = -v0*far / v4;
    m.data[3] = 0.0f;  m.data[7] = 0.0f;  m.data[11] = 1.0f;  m.data[15] = 0.0f;
}

void
MathUtils::makePerspectiveMatrixGL(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    float radiansFOVY = (fovy * M_PI) / 180.0f;

    float top = near * tanf(radiansFOVY);
    float right = top * aspectRatio;

    m.data[0] = near / right;  m.data[4] = 0.0f;  m.data[8] = 0.0f;  m.data[12] = 0.0f;
    m.data[1] = 0.0f;  m.data[5] = near / top;  m.data[9] = 0.0f;  m.data[13] = 0.0f;
    m.data[2] = 0.0f;  m.data[6] = 0.0f;  m.data[10] = -(far + near) / (far - near);  m.data[14] = -2 * (far*near) / (far - near);
    m.data[3] = 0.0f;  m.data[7] = 0.0f;  m.data[11] = -1;  m.data[15] = 0.0f;
}


void 
MathUtils::makeOrthographicMatrix(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    m.data[0] = 2.0f / (right - left); m.data[4] = 0.0f;  m.data[8] = 0.0f;  m.data[12] = -(right + left) / (right - left);
    m.data[1] = 0.0f;  m.data[5] = 2.0f / (top - bottom);  m.data[9] = 0.0f;  m.data[13] = -(top + bottom) / (top - bottom);
    m.data[2] = 0.0f;  m.data[6] = 0.0f;  m.data[10] = -2.0f / (near - far);  m.data[14] = (far + near) / (far - near);
    m.data[3] = 0.0f;  m.data[7] = 0.0f;  m.data[11] = 0.0f;  m.data[15] = 1.0f;
}


void
MathUtils::makeOrthographicMatrixGL(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();
    

    m.data[0] = 2.0f / (right - left); m.data[4] = 0.0f;  m.data[8] = 0.0f;  m.data[12] = -(right + left) / (right - left);
    m.data[1] = 0.0f;  m.data[5] = 2.0f / (top - bottom);  m.data[9] = 0.0f;  m.data[13] = -(top + bottom) / (top - bottom);
    m.data[2] = 0.0f;  m.data[6] = 0.0f;  m.data[10] = -2.0f / (far - near);  m.data[14] = -(far + near) / (far - near);
    m.data[3] = 0.0f;  m.data[7] = 0.0f;  m.data[11] = 0.0f;  m.data[15] = 1.0f;
}


void
MathUtils::makeLookAtMatrix(const Vuforia::Vec3F& eye, const Vuforia::Vec3F& center, const Vuforia::Vec3F& up, Vuforia::Matrix44F& m)
{
    m = Matrix44FIdentity();

    Vuforia::Vec3F Y = up;
    Vuforia::Vec3F Z = Vec3FSub(center,eye);

    Vuforia::Vec3F X = Vec3FCross(Y, Z);
    Y = Vec3FCross(Z, X);

    X = Vec3FNormalize(X);
    Y = Vec3FNormalize(Y);
    Z = Vec3FNormalize(Z);

    Vuforia::Vec3F invEye = Vec3FOpposite(eye);

    m.data[0] = X.data[0];      m.data[4] = X.data[1];      m.data[8] = X.data[2];      m.data[12] = Vec3FDot(X, invEye);
    m.data[1] = Y.data[0];      m.data[5] = Y.data[1];      m.data[9] = Y.data[2];      m.data[13] = Vec3FDot(Y, invEye);
    m.data[2] = Z.data[0];      m.data[6] = Z.data[1];      m.data[10] = Z.data[2];     m.data[14] = Vec3FDot(Z, invEye);
    m.data[3] = 0.0f;           m.data[7] = 0.0f;           m.data[11] = 0.0f;          m.data[15] = 1.f;

}

void
MathUtils::translateMatrix(const Vuforia::Vec3F& v, Vuforia::Matrix44F& m)
{
    // m = m * translate_m
    m.data[12] +=
        (m.data[0] * v.data[0] + m.data[4] * v.data[1] + m.data[8] * v.data[2]);

    m.data[13] +=
        (m.data[1] * v.data[0] + m.data[5] * v.data[1] + m.data[9] * v.data[2]);

    m.data[14] +=
        (m.data[2] * v.data[0] + m.data[6] * v.data[1] + m.data[10] * v.data[2]);

    m.data[15] +=
        (m.data[3] * v.data[0] + m.data[7] * v.data[1] + m.data[11] * v.data[2]);
}


void
MathUtils::rotateMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m)
{
    Vuforia::Matrix44F rotationMatrix;

    // create a rotation matrix
    MathUtils::makeRotationMatrix(angle, axis, rotationMatrix);

    // m = m * scale_matrix
    MathUtils::multiplyMatrix(m, rotationMatrix, m);
}


void
MathUtils::scaleMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F & m)
{
    //m =  m * scale_m
    m.data[0] *= scale.data[0];
    m.data[1] *= scale.data[0];
    m.data[2] *= scale.data[0];
    m.data[3] *= scale.data[0];

    m.data[4] *= scale.data[1];
    m.data[5] *= scale.data[1];
    m.data[6] *= scale.data[1];
    m.data[7] *= scale.data[1];

    m.data[8] *= scale.data[2];
    m.data[9] *= scale.data[2];
    m.data[10] *= scale.data[2];
    m.data[11] *= scale.data[2];
}


void
MathUtils::multiplyMatrix(const Vuforia::Matrix44F& matrixA, const Vuforia::Matrix44F& matrixB, Vuforia::Matrix44F& matrixC)
{
    int i, j, k;
    Vuforia::Matrix44F aTmp;

    // matrixC= matrixA * matrixB
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            aTmp.data[j * 4 + i] = 0.0;

            for (k = 0; k < 4; k++)
                aTmp.data[j * 4 + i] += matrixA.data[k * 4 + i] * matrixB.data[j * 4 + k];
        }
    }

    for (i = 0; i < 16; i++)
        matrixC.data[i] = aTmp.data[i];
}



Vuforia::Matrix44F
operator*(const Vuforia::Matrix44F& mA, const Vuforia::Matrix44F& mB)
{
    Vuforia::Matrix44F r;

    MathUtils::multiplyMatrix(mA, mB, r);

    return r;
}


