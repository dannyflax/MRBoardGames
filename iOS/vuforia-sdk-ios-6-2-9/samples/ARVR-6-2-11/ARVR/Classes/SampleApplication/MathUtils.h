/*===============================================================================
Copyright (c) 2016 PTC Inc. All Rights Reserved.


Copyright (c) 2010-2015 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of PTC Inc., registered in the United States and other 
countries.
===============================================================================*/


#ifndef _VUFORIA_MATHUTILS_H_
#define _VUFORIA_MATHUTILS_H_

#include <Vuforia/Vectors.h>
#include <Vuforia/Matrices.h>


/// Utility class for Math operations.
/**
*
* Provide a set of linear algebra operations for
* Vuforia vector and matrix.
* all 4x4 matrix transformation consider row storage 
*/
class MathUtils
{
public:
    
    // create a 2D unit vector and return the result (result = (1,1))
    static Vuforia::Vec2F Vec2FUnit();

    // create the opposite 2D vector and return the result (result = -v)
    static Vuforia::Vec2F Vec2FOpposite(const Vuforia::Vec2F& v);

    // addition two 2D vectors and return the result (result = v1 + v2)
    static Vuforia::Vec2F Vec2FAdd(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);

    // subtract two 2D vectors and return the result (result = v1 - v2)
    static Vuforia::Vec2F Vec2FSub(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);
    
    // compute the Euclidean distance between two 2D vectors and return the result
    static float Vec2FDist(const Vuforia::Vec2F& v1, const Vuforia::Vec2F& v2);

    // multiply 2D vector by a scalar and return the result  (result  = v * s)
    static Vuforia::Vec2F Vec2FScale(const Vuforia::Vec2F&v, float s);

    // compute the norm of the 2D vector and return the result (result = ||v||)
    static float Vec2FNorm(const Vuforia::Vec2F& v);

    /// Prints a 2D vector
    static void printVector(const Vuforia::Vec2F& v);


    // create a 3D unity vector and return the result (result = (1,1,1))
    static Vuforia::Vec3F Vec3FUnit();

    // create the opposite 3D vector and return the result (result = -v)
    static Vuforia::Vec3F Vec3FOpposite(const Vuforia::Vec3F& v);

    // addition two 3D vectors and return the result (result = v1 + v2)
    static Vuforia::Vec3F Vec3FAdd(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    // subtract two 3D vectors and return the result (result = v1 - v2)
    static Vuforia::Vec3F Vec3FSub(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);
    
    // compute the Euclidean distance between two 3D vectors and return the result
    static float Vec3FDist(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    // multiply 3D vector by a scalar and return the result (result = v * s)
    static Vuforia::Vec3F Vec3FScale(const Vuforia::Vec3F& v, float s);
    
    // compute the dot product of two 3D vectors and return the result (result = v1.v2)
    static float Vec3FDot(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);
    
    // compute the cross product of two 3D vectors and return the result (result = v1 x v2)
    static Vuforia::Vec3F Vec3FCross(const Vuforia::Vec3F& v1, const Vuforia::Vec3F& v2);

    // normalize a 3D vector and return the result (result = v/||v||)
    static Vuforia::Vec3F Vec3FNormalize(const Vuforia::Vec3F& v);
    
    // transform a 3D vector by 4x4 matrix and return the result (pre multiply,  result = m * v)
    static Vuforia::Vec3F Vec3FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v);

    // transform a 3D vector by 4x4 matrix and return the result (post multiply, result = v * m)
    static Vuforia::Vec3F Vec3FTransformR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m);

    // transform a normal by a 4x4 matrix (rotation only) and return the result (pre multiply,  result = m * v)
    static Vuforia::Vec3F Vec3FTransformNormal(const Vuforia::Matrix44F& m, const Vuforia::Vec3F& v);

    // transform a normal by a 4x4 matrix (rotation only) and return the result (post multiply,  result = v * m)
    static Vuforia::Vec3F Vec3FTransformNormalR(const Vuforia::Vec3F& v, const Vuforia::Matrix44F& m);

    // compute the norm of the 3D vector and return the result (result = ||v||)
    static float Vec3FNorm(const Vuforia::Vec3F& v);

    /// Prints a 3D vector
    static void printVector(const Vuforia::Vec3F& v);


    // create a 4D unity vector
    static Vuforia::Vec4F Vec4FUnit();

    // multiply 4D vector by a scalar and return the result (result  = v * s)
    static Vuforia::Vec4F Vec4FScale(const Vuforia::Vec4F& v1, float s);

    // transform a 4D vector by matrix and return the result (pre multiply, result = m * v)
    static Vuforia::Vec4F Vec4FTransform(const Vuforia::Matrix44F& m, const Vuforia::Vec4F& v);

    // transform a 4D vector by matrix and return the result (post multiply, result = v * m)
    static Vuforia::Vec4F Vec4FTransformR(const Vuforia::Vec4F& v, const Vuforia::Matrix44F& m);


    /// Prints a 4D vector
    static void printVector(const Vuforia::Vec4F& m);


    // COMPOSITION METHODS (can be chained)

    // return an identify 4x4 matrix
    static Vuforia::Matrix44F Matrix44FIdentity();
    
    // return an identity 3x4 matrix
    static Vuforia::Matrix34F Matrix34FIdentity();
    
    // transpose a 4x4 matrix and return the result (result = transpose(m))
    static Vuforia::Matrix44F Matrix44FTranspose(const Vuforia::Matrix44F& m);
    
    // compute the determinate of a 4x4 matrix and return the result ( result = det(m) )
    static float Matrix44FDeterminate(const Vuforia::Matrix44F& m);
    
    // computer the inverse of the matrix and return the result ( result = inverse(m) )
    static Vuforia::Matrix44F Matrix44FInverse(const Vuforia::Matrix44F& m);
    
    // translate the matrix m by a vector v and return the result (post-multiply, result = M * T(trans) )
    static Vuforia::Matrix44F Matrix44FTranslate(const Vuforia::Vec3F& trans, const Vuforia::Matrix44F& m);

    // rotate the matrix m by the axis/angle rotation and return the result  (post-multiply, result = M * R(angle, axis) )
    // angle is in degrees
    static Vuforia::Matrix44F Matrix44FRotate(float angle, const Vuforia::Vec3F& axis, const Vuforia::Matrix44F& m);

    // scale the matrix m by a vector scale and return the result (post-multiply, result = M * S (scale) )
    static Vuforia::Matrix44F Matrix44FScale(const Vuforia::Vec3F& scale, const Vuforia::Matrix44F& m);


    // create a perspective projection matrix and return the result (using a CV CS convention, z positive)
    // fov is in degrees
    static Vuforia::Matrix44F Matrix44FPerspective(float fovy, float aspectRatio, float near, float far);

    // create a perspective projection matrix and return the result (using a GL CS convention, z negative)
    // fov is in degrees
    static Vuforia::Matrix44F Matrix44FPerspectiveGL(float fovy, float aspectRatio, float near, float far);

    // create an orthographic projection matrix and return the result (using a CV CS convention, z positive)
    static Vuforia::Matrix44F Matrix44FOrthographic(float left, float right, float bottom, float top, float near, float far);

    // create an orthographic projection matrix and return the result (using a GL CS convention, z negative)
    static Vuforia::Matrix44F Matrix44FOrthographicGL(float left, float right, float bottom, float top, float near, float far);

    // create a look at model view matrix and return the result
    static Vuforia::Matrix44F Matrix44FLookAt(const Vuforia::Vec3F& eye, const Vuforia::Vec3F& center, const Vuforia::Vec3F& up);

    // create copy of the 4x4 matrix and return the result
    static Vuforia::Matrix44F copyMatrix(const Vuforia::Matrix44F& m);


    // ARGUMENT METHODS (result always returned in argument)

    /// Prints a 4x4 matrix.
    static void printMatrix(const Vuforia::Matrix44F& m);

    /// create a rotation matrix with the axis/angle rotation
    // angle is in degrees
    static void makeRotationMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m);

    /// create a translation matrix with the vector v
    static void makeTranslationMatrix(const Vuforia::Vec3F& v, Vuforia::Matrix44F& m);

    /// create a scaling matrix with the vector scale
    static void makeScalingMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F& m);

    /// create a perspective projection matrix with the perspective parameters  (using a CV CS convention, z positive)
    static void makePerspectiveMatrix(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m);

    /// create a perspective projection matrix with the perspective parameters (using a GL CS convention, z negative)
    static void makePerspectiveMatrixGL(float fovy, float aspectRatio, float near, float far, Vuforia::Matrix44F& m);

    /// create an orthographic projection matrix with the orthographic parameters (using a CV CS convention, z positive)
    static void makeOrthographicMatrix(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m);

    /// create an orthographic projection matrix with the orthographic parameters (using a GL CS convention, z negative)
    static void makeOrthographicMatrixGL(float left, float right, float bottom, float top, float near, float far, Vuforia::Matrix44F& m);

    /// create a look at model view matrix with the viewpoint parameters
    static void makeLookAtMatrix(const Vuforia::Vec3F& eye, const Vuforia::Vec3F& center, const Vuforia::Vec3F& up, Vuforia::Matrix44F& m);

    // translate the matrix m by a vector v (post-multiply, result = M * T(trans) )
    static void translateMatrix(const Vuforia::Vec3F& v, Vuforia::Matrix44F& m);

    // rotate the matrix m by the axis/angle rotation (post-multiply, result = M * R(angle, axis) )
    // angle is in degrees
    static void rotateMatrix(float angle, const Vuforia::Vec3F& axis, Vuforia::Matrix44F& m);
    
    // scale the matrix m by a vector scale and return the result (post-multiply, result = M * S (scale) )
    static void scaleMatrix(const Vuforia::Vec3F& scale, Vuforia::Matrix44F& m);
    
    /// Multiplies the two matrices A and B and writes the result to C (C = mA*mB)
    static void multiplyMatrix(const Vuforia::Matrix44F& mA, const Vuforia::Matrix44F& mB, Vuforia::Matrix44F& mC);
    
};

/// Multiplies the two matrices A and B and return the result
static Vuforia::Matrix44F operator*(const Vuforia::Matrix44F& mA, const Vuforia::Matrix44F& mB);


#endif // _VUFORIA_SAMPLEMATH_H_
