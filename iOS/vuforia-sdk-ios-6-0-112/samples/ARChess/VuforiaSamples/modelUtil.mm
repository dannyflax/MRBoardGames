/*
     File: modelUtil.c
 Abstract: Functions for loading a model file for vertex arrays.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010~2011 Apple Inc. All Rights Reserved.
 
 */

#include "modelUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>




typedef struct modelHeaderRec
{
	char fileIdentifier[30];
	unsigned int majorVersion;
	unsigned int minorVersion;
} modelHeader;

typedef struct modelTOCRec
{
	unsigned int attribHeaderSize;
	unsigned int byteElementOffset;
	unsigned int bytePositionOffset;
	unsigned int byteTexcoordOffset;
	unsigned int byteNormalOffset;
} modelTOC;

typedef struct modelAttribRec
{
	unsigned int byteSize;
	GLenum datatype;
	GLenum primType; //If index data
	unsigned int sizePerElement;
	unsigned int numElements;
} modelAttrib;

demoModel* mdlLoadModel(const char* filepathname)
{
	if(NULL == filepathname)
	{
		return NULL;
	}
	
	demoModel* model = (demoModel*) calloc(sizeof(demoModel), 1);
	
	if(NULL == model)
	{
		return NULL;
	}
						
	
	size_t sizeRead;
	int error;
	FILE* curFile = fopen(filepathname, "r");
	
	if(!curFile)
	{	
		mdlDestroyModel(model);	
		return NULL;
	}
	
	modelHeader header;
	
	sizeRead = fread(&header, 1, sizeof(modelHeader), curFile);
	
	if(sizeRead != sizeof(modelHeader))
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	if(strncmp(header.fileIdentifier, "AppleOpenGLDemoModelWWDC2010", sizeof(header.fileIdentifier)))
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	if(header.majorVersion != 0 && header.minorVersion != 1)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	modelTOC toc;
	
	sizeRead = fread(&toc, 1, sizeof(modelTOC), curFile);
	
	if(sizeRead != sizeof(modelTOC))
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	if(toc.attribHeaderSize > sizeof(modelAttrib))
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	modelAttrib attrib;
	
	error = fseek(curFile, toc.byteElementOffset, SEEK_SET);
	
	if(error < 0)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	
    sizeRead = fread(&attrib, 1, toc.attribHeaderSize, curFile);
	
	if(sizeRead != toc.attribHeaderSize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	model->elementArraySize = attrib.byteSize;
	model->elementType = attrib.datatype;
	model->numElements = attrib.numElements;
	
	// OpenGL ES cannot use UNSIGNED_INT elements
	// So if the model has UI element...
	if(GL_UNSIGNED_INT == model->elementType)
	{
		//...Load the UI elements and convert to UNSIGNED_SHORT
		
		GLubyte* uiElements = (GLubyte*) malloc(model->elementArraySize);
		model->elements = (GLubyte*)malloc(model->numElements * sizeof(GLushort)); 
		
		sizeRead = fread(uiElements, 1, model->elementArraySize, curFile);
		
		if(sizeRead != model->elementArraySize)
		{
			fclose(curFile);
			mdlDestroyModel(model);		
			return NULL;
		}
		
		GLuint elemNum = 0;
		for(elemNum = 0; elemNum < model->numElements; elemNum++)
		{
			//We can't handle this model if an element is out of the UNSIGNED_INT range
			if(((GLuint*)uiElements)[elemNum] >= 0xFFFF)
			{
				fclose(curFile);
				mdlDestroyModel(model);		
				return NULL;
			}
			
			((GLushort*)model->elements)[elemNum] = ((GLuint*)uiElements)[elemNum];
		}
		
		free(uiElements);
	
		
		model->elementType = GL_UNSIGNED_SHORT;
		model->elementArraySize = (int)model->numElements * sizeof(GLushort);
	}
	else 
	{	
		model->elements = (GLubyte*)malloc(model->elementArraySize);
		
		sizeRead = fread(model->elements, 1, model->elementArraySize, curFile);
		
		if(sizeRead != model->elementArraySize)
		{
			fclose(curFile);
			mdlDestroyModel(model);		
			return NULL;
		}
	}

	fseek(curFile, toc.bytePositionOffset, SEEK_SET);
	
	sizeRead = fread(&attrib, 1, toc.attribHeaderSize, curFile);
	
	if(sizeRead != toc.attribHeaderSize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	model->positionArraySize = attrib.byteSize;
	model->positionType = attrib.datatype;
	model->positionSize = attrib.sizePerElement;
	model->numVertcies = attrib.numElements;
	model->positions = (GLubyte*) malloc(model->positionArraySize);
	
	sizeRead = fread(model->positions, 1, model->positionArraySize, curFile);
	printf("%s",(char *)model->positions);
    
	if(sizeRead != model->positionArraySize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	error = fseek(curFile, toc.byteTexcoordOffset, SEEK_SET);
	
	if(error < 0)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	sizeRead = fread(&attrib, 1, toc.attribHeaderSize, curFile);
	
	if(sizeRead != toc.attribHeaderSize)
	{	
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	model->texcoordArraySize = attrib.byteSize;
	model->texcoordType = attrib.datatype;
	model->texcoordSize = attrib.sizePerElement;
	
	//Must have the same number of texcoords as positions
	if(model->numVertcies != attrib.numElements)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	model->texcoords = (GLubyte*) malloc(model->texcoordArraySize);
	
	sizeRead = fread(model->texcoords, 1, model->texcoordArraySize, curFile);
	
	if(sizeRead != model->texcoordArraySize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	error = fseek(curFile, toc.byteNormalOffset, SEEK_SET);
	
	if(error < 0)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	sizeRead = fread(&attrib, 1, toc.attribHeaderSize, curFile);
	
	if(sizeRead !=  toc.attribHeaderSize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	model->normalArraySize = attrib.byteSize;
	model->normalType = attrib.datatype;
	model->normalSize = attrib.sizePerElement;

	//Must have the same number of normals as positions
	if(model->numVertcies != attrib.numElements)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
		
	model->normals = (GLubyte*) malloc(model->normalArraySize );
	
	sizeRead =  fread(model->normals, 1, model->normalArraySize , curFile);
	
    
	if(sizeRead != model->normalArraySize)
	{
		fclose(curFile);
		mdlDestroyModel(model);		
		return NULL;
	}
	
	
	fclose(curFile);
	
	return model;
	
}

demoModel* loadFile(const char* filepathname){
    
    
    FILE* f = fopen(filepathname, "r");
    char as[200] = "";
    
    
    GLuint vsize = 0;
    GLuint nsize = 0;
    GLuint tsize = 0;
    GLuint isize = 0;
    
    /*
     * Scan through the .obj file and determine number of verticies, texture coords, and normals
     */
    
    while (fgets(as,200,f)!=NULL){
        
        
        if(as[0]=='v'){
            if(as[1]=='n'){
                nsize+=3;
            }
            else if(as[1]=='t'){
                tsize+=2;
            }
            else{
                vsize+=3;
                
            }
            
        }
        else if(as[0]=='f'){
            GLuint fsize = -1;
            
            char* comp = strtok(as," ");
           
            while(comp!=NULL){
                fsize++;
                comp = strtok(NULL," ");
            }
            
            isize+=fsize;
        
        }
        
        
        
    }
    GLushort v_order[isize];
    GLushort t_order[isize];
    GLushort n_order[isize];
    
    GLfloat vertices[vsize];
   
    GLfloat textures[tsize];
    GLfloat normals[nsize];
    
    int txt = tsize;
    
    
    int i_n = 0;
    int i_v = 0;
    int i_t = 0;
    int i_i = 0;
    
    
    
    rewind(f);
    while (fgets(as,200,f)!=NULL){
        
        
        
        if(as[0]=='v'){
            if(as[1]=='n'){
                char* compn = strtok(as," ");
                int i = 0;
                while(compn!=NULL){
                    if(i!=0){
                        
                         
                        normals[i_n] = strtof(compn,NULL);
                        
                        i_n++;
                        
                        
                    }
                    compn = strtok(NULL," ");
                    i++;
                }
            }
            else if(as[1]=='t'){
                
                char* comp = strtok(as," ");
                int i = 0;
                while(comp!=NULL){
                    if(i!=0){
                        
                      
                        textures[i_t] = strtof(comp,NULL);
                        i_t++;
                        
                        
                    }
                    comp = strtok(NULL," ");
                    i++;
                }
                
            }
            else{
                char* comp = strtok(as," ");
                int i = 0;
                while(comp!=NULL){
                    
                    if(i!=0){
                        
                        vertices[i_v] = strtof(comp,NULL);
                      
                        i_v++;
                        
                    }
                    
                    comp = strtok(NULL," ");
                    i++;
                }
                
            }
            
        }
        else if(as[0]=='f'){
            char* inds[3];
            char* comp = strtok(as," ");
            int i = 0;
            while(comp!=NULL){
                if(i!=0){
                    inds[i-1] = comp;
                    
                }
                
                comp = strtok(NULL," ");
                i++;
            }
            i = 0;
            
         if(txt!=0){
             
             
            while(i<3){

               
             char* comp2 = strtok(inds[i],"/");
              
                int i2 = 0;
             
                while(comp2!=NULL){
                    switch (i2) {
                        case 0:
                            v_order[i_i] = strtof(comp2,NULL);
                            break;
                        case 1:
                            t_order[i_i] = strtof(comp2,NULL);
                            break;
                        case 2:
                            n_order[i_i] = strtof(comp2,NULL);
                            break;
                            
                        default:
                            break;
                    }
                    
             
                   
             
                    i2++;
                    comp2 = strtok(NULL,"/");
             
                }
             
             i_i++;
             
                i++;
            
            }
         }
         else{
            
             while(i<3){
            
             
             char* comp2 = strtok(inds[i],"//");
             
             int i2 = 0;
             
             while(comp2!=NULL){
                 switch (i2) {
                     case 0:
                         v_order[i_i] = strtof(comp2,NULL);
                         break;
                     case 1:
                         n_order[i_i] = strtof(comp2,NULL);
                         break;
                    
                         
                     default:
                         break;
                 }
                 
                 
                 
                 
                 i2++;
                 comp2 = strtok(NULL,"//");
                 
             }
             
             i_i++;
             
             i++;
             
         } 
         }
            
            
            
            
        }
        
        
        
        
        
       
        
    }
    
    
    GLushort elementArray[isize];
    
    GLfloat posArray[isize*3];
    
    GLfloat texcoordArray[isize*2];
    GLfloat normalArray[isize*3];
    
    
    
    int i;

    i = 0;
    
    while(i<isize){
        elementArray[i] = i;
        posArray[i*3] = vertices[((v_order[i]-1)*3)];
        posArray[i*3 + 1] = vertices[((v_order[i]-1)*3)+1];
        posArray[i*3 + 2] = vertices[((v_order[i]-1)*3)+2];
        
        
        normalArray[i*3] = normals[((n_order[i]-1)*3)];
        normalArray[i*3 + 1] = normals[((n_order[i]-1)*3)+1];
        normalArray[i*3 + 2] = normals[((n_order[i]-1)*3)+2];
        
        
        if(txt!=0){
        texcoordArray[i*2] = textures[((t_order[i]-1)*2)];
        texcoordArray[i*2 + 1] = 1.0 -
            textures[((t_order[i]-1)*2)+1];
        }
        
        i++;
    }
 
    
    
    demoModel* model = (demoModel*) calloc(sizeof(demoModel), 1);
	
	if(NULL == model)
	{
		return NULL;
	}
	
    //Makes sense, as vertices are recorded and entered as floats
	model->positionType = GL_FLOAT;
    //X, Y, and Z coordinates (3)
	model->positionSize = 3;
    //Figure out the total numbers of components in the
    //vertices array. Note that this is not the same as
    //the total number of vertices, as there are 3 components
    //per vertex.
    
	model->positionArraySize = (int)sizeof(posArray);
    //Set what the actual verticies are
    //So first we use a C command to create an empty array to hold the data
	model->positions = (GLubyte*)malloc(model->positionArraySize);
    //Then we use another command to copy the data from our 
    //position array to the empty array
	memcpy(model->positions, posArray, model->positionArraySize);
	
    if(txt!=0){
        //Do the same thing with texture coordinates
        model->texcoordType = GL_FLOAT;
        //U,V coordinates (2)
        model->texcoordSize = 2;
        model->texcoordArraySize = (int)sizeof(texcoordArray);
        model->texcoords = (GLubyte*)malloc(model->texcoordArraySize);
        memcpy(model->texcoords, texcoordArray, model->texcoordArraySize );
    }
    //And the normals
	model->normalType = GL_FLOAT;
	model->normalSize = 3;
	model->normalArraySize = (int)sizeof(normalArray);
	model->normals = (GLubyte*)malloc(model->normalArraySize);
	memcpy(model->normals, normalArray, model->normalArraySize);
	
    //And the indices
	model->elementArraySize = (int)sizeof(elementArray);
	model->elements	= (GLubyte*)malloc(model->elementArraySize);
	memcpy(model->elements, elementArray, model->elementArraySize);
	
	
	model->numElements = (int)sizeof(elementArray) / sizeof(GLushort);
	//Note that the indicies are stored as shorts
    model->elementType = GL_UNSIGNED_SHORT;
	//Also note that the word Vertices was spelled wrong :)
    //So divide the amount of elements in the vertice array by the 
    //amount of components in each vertex (in this case, 3)
    //to get the total amount of verticies
    model->numVertcies = model->positionArraySize / (model->positionSize * sizeof(GLfloat));
	
    model->primType = GL_TRIANGLES;

    
    return model;
}


demoModel* mdlLoadQuadModel()
{
    
	GLfloat posArray[] = {
		-100.0f, -100.0f, 100.0f,
		 100.0f, -100.0f, 100.0f,
		 100.0f, 100.0f,  -100.0f,
		-100.0f, 100.0f,  -100.0f
	};
		
	GLfloat texcoordArray[] = { 
		0.0f,  1.0f,
		1.0f,  1.0f,
		1.0f,  0.0f,
		0.0f,  0.0f
	};
	
	GLfloat normalArray[] = {
		0.0f, 0.0f, 1.0,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 0.0f, 1.0f,
	};
	
	GLushort elementArray[] =
	{
		0, 2, 1,
		0, 3, 2
	};
	
	demoModel* model = (demoModel*) calloc(sizeof(demoModel), 1);
	
	if(NULL == model)
	{
		return NULL;
	}
	
    //Makes sense, as vertices are recorded and entered as floats
	model->positionType = GL_FLOAT;
    //X, Y, and Z coordinates (3)
	model->positionSize = 3;
    //Figure out the total numbers of components in the
    //vertices array. Note that this is not the same as
    //the total number of vertices, as there are 3 components
    //per vertex.
	model->positionArraySize = sizeof(posArray);
    //Set what the actual verticies are
    //So first we use a C command to create an empty array to hold the data
	model->positions = (GLubyte*)malloc(model->positionArraySize);
    //Then we use another command to copy the data from our 
    //position array to the empty array
	memcpy(model->positions, posArray, model->positionArraySize);
	
    //Do the same thing with texture coordinates
	model->texcoordType = GL_FLOAT;
    //U,V coordinates (2)
	model->texcoordSize = 2;
	model->texcoordArraySize = sizeof(texcoordArray);
	model->texcoords = (GLubyte*)malloc(model->texcoordArraySize);
	memcpy(model->texcoords, texcoordArray, model->texcoordArraySize );

    //And the normals
	model->normalType = GL_FLOAT;
	model->normalSize = 3;
	model->normalArraySize = sizeof(normalArray);
	model->normals = (GLubyte*)malloc(model->normalArraySize);
	memcpy(model->normals, normalArray, model->normalArraySize);
	
    //And the indices
	model->elementArraySize = sizeof(elementArray);
	model->elements	= (GLubyte*)malloc(model->elementArraySize);
	memcpy(model->elements, elementArray, model->elementArraySize);
	
	
	
	
	model->numElements = sizeof(elementArray) / sizeof(GLushort);
	//Note that the indicies are stored as shorts
    model->elementType = GL_UNSIGNED_SHORT;
	//Also note that the word Vertices was spelled wrong :)
    //So divide the amount of elements in the vertice array by the 
    //amount of components in each vertex (in this case, 3)
    //to get the total amount of verticies
    model->numVertcies = model->positionArraySize / (model->positionSize * sizeof(GLfloat));
	
    model->primType = GL_TRIANGLES;
    
	return model;
}

void mdlDestroyModel(demoModel* model)
{
	if(NULL == model)
	{
		return;
	}
	
	free(model->elements);
	free(model->positions);
	free(model->normals);
	free(model->texcoords);
	
	free(model);
}

