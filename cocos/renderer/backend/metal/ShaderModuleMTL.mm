/****************************************************************************
 Copyright (c) 2018-2019 Xiamen Yaji Software Co., Ltd.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
 
#include "ShaderModuleMTL.h"
#include "DeviceMTL.h"

#include "glsl_optimizer.h"

CC_BACKEND_BEGIN

namespace {
    // Singleton glslopt context for reuse
    glslopt_ctx* sharedGlslOptCtx() {
        static glslopt_ctx* ctx = glslopt_initialize(kGlslTargetMetal);
        return ctx;
    }
}

ShaderModuleMTL::ShaderModuleMTL(id<MTLDevice> mtlDevice, ShaderStage stage, const std::string& source)
: ShaderModule(stage)
{
    // Reuse GLSL optimizer context
    glslopt_ctx* ctx = sharedGlslOptCtx();
    glslopt_shader_type shaderType = stage == ShaderStage::VERTEX ? kGlslOptShaderVertex : kGlslOptShaderFragment;
    glslopt_shader* glslShader = glslopt_optimize(ctx, shaderType, source.c_str(), 0);

    if (!glslShader || !glslopt_get_output(glslShader)) {
        NSLog(@"Failed to translate GLSL shader to Metal: %s", source.c_str());
        if (glslShader) glslopt_shader_delete(glslShader);
        return;
    }

    const char* metalShader = glslopt_get_output(glslShader);

    parseAttibute(mtlDevice, glslShader);
    parseUniform(mtlDevice, glslShader);
    parseTexture(mtlDevice, glslShader);
    setBuiltinUniformLocation();
    setBuiltinAttributeLocation();

    NSError* error = nil;
    NSString* shader = [NSString stringWithUTF8String:metalShader];
    id<MTLLibrary> library = [mtlDevice newLibraryWithSource:shader options:nil error:&error];
    if (!library) {
        NSLog(@"Failed to compile Metal shader: %@", error);
        NSLog(@"Metal shader source:\n%s", metalShader);
        glslopt_shader_delete(glslShader);
        return;
    }

    _mtlFunction = stage == ShaderStage::VERTEX ? [library newFunctionWithName:@"xlatMtlMain1"] : [library newFunctionWithName:@"xlatMtlMain2"];
    if (!_mtlFunction) {
        NSLog(@"Error in Metal shader function creation:\n%s", metalShader);
        [library release];
        glslopt_shader_delete(glslShader);
        assert(false);
    }

    [library release];
    glslopt_shader_delete(glslShader);
}

ShaderModuleMTL::~ShaderModuleMTL()
{
    [_mtlFunction release];
}

void ShaderModuleMTL::parseAttibute(id<MTLDevice> mtlDevice, glslopt_shader* shader)
{
    const int attributeCount = glslopt_shader_get_input_count(shader);
    for (int i = 0; i < attributeCount; ++i) {
        const char* parName;
        glslopt_basic_type parType;
        glslopt_precision parPrec;
        int parVecSize, parMatSize, parArrSize, location;
        glslopt_shader_get_input_desc(shader, i, &parName, &parType, &parPrec, &parVecSize, &parMatSize, &parArrSize, &location);

        AttributeBindInfo attributeInfo = { parName, location };
        _attributeInfo[parName] = attributeInfo;
    }
}

void ShaderModuleMTL::parseUniform(id<MTLDevice> mtlDevice, glslopt_shader* shader)
{
    const int uniformCount = glslopt_shader_get_uniform_count(shader);
    _uniformBufferSize = glslopt_shader_get_uniform_total_size(shader);

    for (int i = 0; i < uniformCount; ++i) {
        const char* parName;
        glslopt_basic_type parType;
        glslopt_precision parPrec;
        int parVecSize, parMatSize, parArrSize, location, nextLocation;

        glslopt_shader_get_uniform_desc(shader, i, &parName, &parType, &parPrec, &parVecSize, &parMatSize, &parArrSize, &location);
        nextLocation = (i + 1 < uniformCount) ? glslopt_shader_get_uniform_offset(shader, i + 1) : static_cast<int>(_uniformBufferSize);

        UniformInfo uniform = {
            static_cast<unsigned int>(parType),
            parArrSize > 0,
            parVecSize == 3,
            parMatSize > 1,
            parArrSize,
            location,
            nextLocation - location,
            location
        };

        _uniformInfos[parName] = uniform;
        _activeUniformInfos[location] = uniform;
        _maxLocation = std::max(_maxLocation, location + 1);
    }
}

int ShaderModuleMTL::getUniformLocation(Uniform name) const
{
    return _uniformLocation[name];
}

int ShaderModuleMTL::getUniformLocation(const std::string& name) const
{
    const auto& iter = _uniformInfos.find(name);
    if(iter != _uniformInfos.end())
    {
        return _uniformInfos.at(name).location;
    }
    else
        return -1;
}

void ShaderModuleMTL::setBuiltinUniformLocation()
{
    std::fill(_uniformLocation, _uniformLocation + UNIFORM_MAX, -1);
    ///u_mvpMatrix
    auto iter = _uniformInfos.find(UNIFORM_NAME_MVP_MATRIX);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::MVP_MATRIX] = iter->second.location;
    }
    
    ///u_textColor
    iter = _uniformInfos.find(UNIFORM_NAME_TEXT_COLOR);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::TEXT_COLOR] = iter->second.location;
    }
    
    ///u_effectColor
    iter = _uniformInfos.find(UNIFORM_NAME_EFFECT_COLOR);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::EFFECT_COLOR] = iter->second.location;
    }
    
    ///u_effectType
    iter = _uniformInfos.find(UNIFORM_NAME_EFFECT_TYPE);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::EFFECT_TYPE] = iter->second.location;
    }
    
    ///u_texture
    iter = _uniformInfos.find(UNIFORM_NAME_TEXTURE);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::TEXTURE] = iter->second.location;
    }
    
    ///u_texture1
    iter = _uniformInfos.find(UNIFORM_NAME_TEXTURE1);
    if(iter != _uniformInfos.end())
    {
        _uniformLocation[Uniform::TEXTURE1] = iter->second.location;
    }
}

int ShaderModuleMTL::getAttributeLocation(Attribute name) const
{
    return _attributeLocation[name];
}

int ShaderModuleMTL::getAttributeLocation(std::string name)
{
    auto iter = _attributeInfo.find(name);
    if(iter != _attributeInfo.end())
        return _attributeInfo[name].location;
    else
        return -1;
}

void ShaderModuleMTL::setBuiltinAttributeLocation()
{
    std::fill(_attributeLocation, _attributeLocation + ATTRIBUTE_MAX, -1);
    ///a_position
    auto iter = _attributeInfo.find(ATTRIBUTE_NAME_POSITION);
    if(iter != _attributeInfo.end())
    {
        _attributeLocation[Attribute::POSITION] = iter->second.location;
    }
    
    ///a_color
    iter = _attributeInfo.find(ATTRIBUTE_NAME_COLOR);
    if(iter != _attributeInfo.end())
    {
        _attributeLocation[Attribute::COLOR] = iter->second.location;
    }
    
    ///a_texCoord
    iter = _attributeInfo.find(ATTRIBUTE_NAME_TEXCOORD);
    if(iter != _attributeInfo.end())
    {
        _attributeLocation[Attribute::TEXCOORD] = iter->second.location;
    }
}

void ShaderModuleMTL::parseTexture(id<MTLDevice> mtlDevice, glslopt_shader* shader)
{
    const int textureCount = glslopt_shader_get_texture_count(shader);
    for (int i = 0; i < textureCount; ++i)
    {
        const char* parName;
        glslopt_basic_type parType;
        glslopt_precision parPrec;
        int parVecSize, parMatSize, parArrSize, location;
        glslopt_shader_get_texture_desc(shader, i, &parName, &parType, &parPrec, &parVecSize, &parMatSize, &parArrSize, &location);
        
        UniformInfo uniform;
        uniform.count = parArrSize;
        uniform.location = location;
        uniform.isArray = parArrSize > 0;
        _uniformInfos[parName] = uniform;
    }
}

CC_BACKEND_END
