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
 
#include "ProgramMTL.h"
#include "ShaderModuleMTL.h"
#include "base/ccMacros.h"

CC_BACKEND_BEGIN
namespace {
    // Use a static constant to avoid repeated allocations.
    constexpr auto metalSpecificDefine = "#define METAL\n";
}

ProgramMTL::ProgramMTL(const std::string& vertexShader, const std::string& fragmentShader)
: Program(vertexShader, fragmentShader)
{
    // Avoid repeated allocations and unnecessary copies
    _vertexShader = static_cast<ShaderModuleMTL*>(ShaderCache::newVertexShaderModule(vertexShader));
    _fragmentShader = static_cast<ShaderModuleMTL*>(ShaderCache::newFragmentShaderModule(metalSpecificDefine + fragmentShader));

    CC_SAFE_RETAIN(_vertexShader);
    CC_SAFE_RETAIN(_fragmentShader);
}

ProgramMTL::~ProgramMTL()
{
    CC_SAFE_RELEASE(_vertexShader);
    CC_SAFE_RELEASE(_fragmentShader);
}

int ProgramMTL::getAttributeLocation(Attribute name) const
{
    return _vertexShader->getAttributeLocation(name);
}

int ProgramMTL::getAttributeLocation(const std::string &name) const
{
    return _vertexShader->getAttributeLocation(name);
}

UniformLocation ProgramMTL::getUniformLocation(backend::Uniform name) const
{
    return getUniformLocationHelper(
        [this, name]() { return _vertexShader->getUniformLocation(name); },
        [this, name]() { return _fragmentShader->getUniformLocation(name); });
}

UniformLocation ProgramMTL::getUniformLocation(const std::string& uniform) const
{
    return getUniformLocationHelper(
        [this, &uniform]() { return _vertexShader->getUniformLocation(uniform); },
        [this, &uniform]() { return _fragmentShader->getUniformLocation(uniform); });
}

int ProgramMTL::getMaxVertexLocation() const
{
    return _vertexShader->getMaxLocation();
}

int ProgramMTL::getMaxFragmentLocation() const
{
    return _fragmentShader->getMaxLocation();
}

const std::unordered_map<std::string, AttributeBindInfo> ProgramMTL::getActiveAttributes() const
{
    return _vertexShader->getAttributeInfo();
}

const UniformInfo& ProgramMTL::getActiveUniformInfo(ShaderStage stage, int location) const
{
    return (stage == ShaderStage::VERTEX) ? _vertexShader->getActiveUniform(location) : _fragmentShader->getActiveUniform(location);
}

std::size_t ProgramMTL::getUniformBufferSize(ShaderStage stage) const
{
    return (stage == ShaderStage::VERTEX) ? _vertexShader->getUniformBufferSize() : _fragmentShader->getUniformBufferSize();
}

const std::unordered_map<std::string, UniformInfo>& ProgramMTL::getAllActiveUniformInfo(ShaderStage stage) const
{
    return (stage == ShaderStage::VERTEX) ? _vertexShader->getAllActiveUniformInfo() : _fragmentShader->getAllActiveUniformInfo();
}

// Helper function to reduce duplicated code in getUniformLocation methods
UniformLocation ProgramMTL::getUniformLocationHelper(std::function<int()> getVSLocation, std::function<int()> getFSLocation) const
{
    UniformLocation uniformLocation;
    auto vsLocation = getVSLocation();
    auto fsLocation = getFSLocation();

    if (vsLocation != -1 && fsLocation != -1) {
        uniformLocation.shaderStage = ShaderStage::VERTEX_AND_FRAGMENT;
        uniformLocation.location[0] = vsLocation;
        uniformLocation.location[1] = fsLocation;
    } else if (vsLocation != -1) {
        uniformLocation.shaderStage = ShaderStage::VERTEX;
        uniformLocation.location[0] = vsLocation;
    } else {
        uniformLocation.shaderStage = ShaderStage::FRAGMENT;
        uniformLocation.location[1] = fsLocation;
    }

    return uniformLocation;
}

CC_BACKEND_END
