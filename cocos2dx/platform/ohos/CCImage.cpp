/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

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

#define __CC_PLATFORM_IMAGE_CPP__
#include "platform/CCImageCommon_cpp.h"
#include "platform/CCPlatformMacros.h"
#include "platform/CCImage.h"
#include "platform/CCFileUtils.h"
#include "CCTextBitmap.h"

#include <string.h>

NS_CC_BEGIN

class BitmapDC
{
public:

    BitmapDC()
    : m_nWidth(0)
    , m_nHeight(0)
    , m_pData(NULL)
    {
    }

    ~BitmapDC(void)
    {
        if (m_pData)
        {
            delete [] m_pData;
        }
    }
    
    static BitmapDC& sharedBitmapDC()
    {
        static BitmapDC s_BmpDC;
        return s_BmpDC;
    }
   
    bool getBitmapWithDrawing(	const char *text,
    									int nWidth,
    									int nHeight,
    									CCImage::ETextAlign eAlignMask,
    									const char * pFontName,
    									float fontSize,
    									float textTintR 		= 1.0,
    									float textTintG 		= 1.0,
    									float textTintB 		= 1.0,
    									bool shadow 			= false,
    									float shadowDeltaX 		= 0.0,
    									float shadowDeltaY 		= 0.0,
    									float shadowBlur 		= 0.0,
    									float shadowIntensity 	= 0.0,
    									bool stroke 			= false,
    									float strokeColorR 		= 0.0,
    									float strokeColorG 		= 0.0,
    									float strokeColorB 		= 0.0,
    									float strokeSize 		= 0.0 )
    {
        CCTextBitmap *cCtextBitmap = new CCTextBitmap();
        CCTextBitmap::createCCTextBitmap(cCtextBitmap, text, pFontName, fontSize, textTintR, textTintG, textTintB,
                                             eAlignMask, nWidth, nHeight, shadow, shadowDeltaX, shadowDeltaY,
                                             shadowBlur, stroke, strokeColorR, strokeColorG, strokeColorB, strokeSize);
        void* pixels = cCtextBitmap->getPixelAddr();
        cocos2d::BitmapDC& bitmapDC = sharedBitmapDC();
        bitmapDC.m_nWidth = cCtextBitmap->GetWidth();
        bitmapDC.m_nHeight = cCtextBitmap->GetHeight();
        long size = bitmapDC.m_nWidth * bitmapDC.m_nHeight * 4;
        bitmapDC.m_pData =  new unsigned char[size];
        memcpy(bitmapDC.m_pData, pixels, size);
        delete cCtextBitmap;
        return true;
    }

public:
    int m_nWidth;
    int m_nHeight;
    unsigned char *m_pData;
};



bool CCImage::initWithString(
                               const char *    pText, 
                               int             nWidth/* = 0*/, 
                               int             nHeight/* = 0*/,
                               ETextAlign      eAlignMask/* = kAlignCenter*/,
                               const char *    pFontName/* = nil*/,
                               int             nSize/* = 0*/)
{
    bool bRet = false;

    do 
    {
        CC_BREAK_IF(! pText);
        
        BitmapDC &dc = BitmapDC::sharedBitmapDC();

        CC_BREAK_IF(!dc.getBitmapWithDrawing(pText, nWidth, nHeight, eAlignMask, pFontName, nSize));

        // assign the dc.m_pData to m_pData in order to save time
        m_pData = dc.m_pData;
        CC_BREAK_IF(! m_pData);

        m_nWidth    = (short)dc.m_nWidth;
        m_nHeight   = (short)dc.m_nHeight;
        m_bHasAlpha = true;
        m_bPreMulti = true;
        m_nBitsPerComponent = 8;

        bRet = true;
    } while (0);

    return bRet;
}

bool CCImage::initWithStringShadowStroke(
                                         const char * pText,
                                         int         nWidth ,
                                         int         nHeight ,
                                         ETextAlign eAlignMask ,
                                         const char * pFontName ,
                                         int          nSize ,
                                         float        textTintR,
                                         float        textTintG,
                                         float        textTintB,
                                         bool shadow,
                                         float shadowOffsetX,
                                         float shadowOffsetY,
                                         float shadowOpacity,
                                         float shadowBlur,
                                         bool  stroke,
                                         float strokeR,
                                         float strokeG,
                                         float strokeB,
                                         float strokeSize)
{
	 bool bRet = false;
	    do
	    {
	        CC_BREAK_IF(! pText);

	        BitmapDC &dc = BitmapDC::sharedBitmapDC();


	        CC_BREAK_IF(!dc.getBitmapWithDrawing(pText, nWidth, nHeight, eAlignMask, pFontName,
	        											   nSize, textTintR, textTintG, textTintB, shadow,
	        											   shadowOffsetX, shadowOffsetY, shadowBlur, shadowOpacity,
	        											   stroke, strokeR, strokeG, strokeB, strokeSize ));


	        // assign the dc.m_pData to m_pData in order to save time
	        m_pData = dc.m_pData;

	        CC_BREAK_IF(! m_pData);

	        m_nWidth    = (short)dc.m_nWidth;
	        m_nHeight   = (short)dc.m_nHeight;
	        m_bHasAlpha = true;
	        m_bPreMulti = true;
	        m_nBitsPerComponent = 8;

	        // ok 
	        bRet = true;

	    } while (0);

	    return bRet;
}

NS_CC_END
