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

#include "platform/CCCommon.h"
#include "napi/helper/NapiHelper.h"
#include "CCLogOhos.h"
#include <stdio.h>

NS_CC_BEGIN

#define MAX_LEN (cocos2d::kMaxLogLen + 1)

void CCLog(const char* pszFormat, ...)
{
    char buf[MAX_LEN];

    va_list args;
    va_start(args, pszFormat);
    vsnprintf(buf, MAX_LEN, pszFormat, args);
    va_end(args);
    OHOS_LOGI("cocos2d-x debug info %{public}s", buf);
}

void CCMessageBox(const char* pszMsg, const char* pszTitle)
{
    std::string msg(pszMsg);
    std::string title(pszTitle);
    JSFunction::getFunction("DiaLog.showDialog").invoke<void>(msg, title);
}

void CCLuaLog(const char* pszFormat)
{
    OHOS_LOGI("cocos2d-x debug info %{public}s", pszFormat);
}

NS_CC_END
