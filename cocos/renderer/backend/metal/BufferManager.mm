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
 
#include "BufferManager.h"
#include "BufferMTL.h"
#include <unordered_set>

CC_BACKEND_BEGIN

// Use an unordered_set for efficient management of buffers
std::unordered_set<BufferMTL*> BufferManager::_buffers;

void BufferManager::addBuffer(BufferMTL* buffer)
{
    if (buffer)
    {
        _buffers.insert(buffer); // Insert buffer efficiently
    }
}

void BufferManager::removeBuffer(BufferMTL* buffer)
{
    if (buffer)
    {
        _buffers.erase(buffer); // Erase buffer directly
    }
}

void BufferManager::beginFrame()
{
    for (auto& buffer : _buffers)
    {
        if (buffer) // Ensure the buffer is valid
        {
            buffer->beginFrame(); // Update frame-specific state
        }
    }
}

CC_BACKEND_END