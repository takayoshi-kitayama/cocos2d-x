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
 
#include "BufferMTL.h"
#include "../Macros.h"
#include "BufferManager.h"

CC_BACKEND_BEGIN

BufferMTL::BufferMTL(id<MTLDevice> mtlDevice, std::size_t size, BufferType type, BufferUsage usage)
    : Buffer(size, type, usage), _currentFrameIndex(0), _indexUpdated(false)
{
    if (BufferUsage::DYNAMIC == usage)
    {
        _dynamicDataBuffers = [[NSMutableArray alloc] initWithCapacity:MAX_INFLIGHT_BUFFER];
        for (int i = 0; i < MAX_INFLIGHT_BUFFER; ++i)
        {
            // Efficiently create Metal buffers
            id<MTLBuffer> dynamicDataBuffer = [mtlDevice newBufferWithLength:size options:MTLResourceStorageModeShared];
            if (!dynamicDataBuffer)
            {
                NSLog(@"Failed to create dynamic Metal buffer");
                continue;
            }
            [_dynamicDataBuffers addObject:dynamicDataBuffer];
        }
        if (_dynamicDataBuffers.count > 0)
        {
            _mtlBuffer = _dynamicDataBuffers[0];
        }
        BufferManager::addBuffer(this);
    }
    else
    {
        // Create a single Metal buffer for static usage
        _mtlBuffer = [mtlDevice newBufferWithLength:size options:MTLResourceStorageModeShared];
        if (!_mtlBuffer)
        {
            NSLog(@"Failed to create Metal buffer");
        }
    }
}

BufferMTL::~BufferMTL()
{
    if (BufferUsage::DYNAMIC == _usage)
    {
        // Safely release all dynamic Metal buffers
        for (id<MTLBuffer> buffer in _dynamicDataBuffers)
        {
            if (buffer)
            {
                [buffer release];
            }
        }
        [_dynamicDataBuffers release];
        BufferManager::removeBuffer(this);
    }
    else if (_mtlBuffer)
    {
        // Release the static Metal buffer
        [_mtlBuffer release];
        _mtlBuffer = nil;
    }
}

void BufferMTL::updateData(void* data, std::size_t size)
{
    assert(size <= _size);
    updateIndex();

    if (_mtlBuffer)
    {
        // Directly copy data into Metal buffer memory
        memcpy(_mtlBuffer.contents, data, size);
    }
    else
    {
        NSLog(@"Attempted to update a null Metal buffer");
    }
}

void BufferMTL::updateSubData(void* data, std::size_t offset, std::size_t size)
{
    assert(offset + size <= _size);
    updateIndex();

    if (_mtlBuffer)
    {
        // Copy data into a specified range within the Metal buffer memory
        memcpy((uint8_t*)_mtlBuffer.contents + offset, data, size);
    }
    else
    {
        NSLog(@"Attempted to update subdata on a null Metal buffer");
    }
}

id<MTLBuffer> BufferMTL::getMTLBuffer() const
{
    return _mtlBuffer;
}

void BufferMTL::beginFrame()
{
    // Reset the index update status for the new frame
    _indexUpdated = false;
}

void BufferMTL::updateIndex()
{
    if (BufferUsage::DYNAMIC == _usage && !_indexUpdated && _dynamicDataBuffers.count > 0)
    {
        // Update the frame index and switch to the corresponding dynamic buffer
        _currentFrameIndex = (_currentFrameIndex + 1) % _dynamicDataBuffers.count;
        _mtlBuffer = _dynamicDataBuffers[_currentFrameIndex];
        _indexUpdated = true;
    }
}

CC_BACKEND_END
