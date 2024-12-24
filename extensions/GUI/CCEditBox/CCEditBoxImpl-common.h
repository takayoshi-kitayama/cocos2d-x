/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2012 James Chen
 
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

#ifndef __UIEditBoxIMPLICOMMON_H__
#define __UIEditBoxIMPLICOMMON_H__

#include "ExtensionMacros.h"
#include "CCEditBoxImpl.h"

NS_CC_EXT_BEGIN


class EditBox;

class EditBoxImplCommon : public CCEditBoxImpl
{
public:
    /**
     * @js NA
     */
    EditBoxImplCommon(CCEditBox* pEditText);
    /**
     * @js NA
     * @lua NA
     */
    virtual ~EditBoxImplCommon();

    virtual bool initWithSize(const CCSize& size) override;
    virtual void setFont(const char* pFontName, int fontSize) override;
    virtual void setFontColor(const ccColor3B& color) override;
    virtual void setPlaceholderFont(const char* pFontName, int fontSize) override;
    virtual void setPlaceholderFontColor(const ccColor3B& color) override;
    virtual void setInputMode(EditBoxInputMode inputMode) override;
    virtual void setInputFlag(EditBoxInputFlag inputFlag) override;
    
    virtual void setText(const char* pText) override;
    virtual void setPlaceHolder(const char* pText) override;
    virtual void setVisible(bool visible) override;
    virtual void setMaxLength(int maxLength) override;
    virtual int  getMaxLength() override { return _maxLength; }
    virtual const char* getText(void) override { return _text.c_str(); }
    virtual void setContentSize(const CCSize& size) override;
    virtual void setAnchorPoint(const CCPoint& anchorPoint) override {}
    virtual void setPosition(const CCPoint& pos) override {}
    virtual void setReturnType(KeyboardReturnType returnType) override;
    virtual void refreshInactiveText();

    /**
     * @js NA
     * @lua NA
     */
    virtual void visit(void) = 0;

    /**
     * @js NA
     * @lua NA
     */
    //virtual void draw(Renderer *renderer, const Mat4 &parentTransform, uint32_t parentFlags) override;
    /**
     * @js NA
     * @lua NA
     */
    virtual void onEnter(void) override;
    virtual void openKeyboard() override;
    virtual void closeKeyboard() override;

    virtual void onEndEditing(const std::string& text);

    void editBoxEditingDidBegin();
    void editBoxEditingChanged(const std::string& text);
    void editBoxEditingDidEnd(const std::string& text);

    virtual bool isEditing() override = 0;
    virtual void createNativeControl(const CCRect& frame) = 0;
    virtual void setNativeFont(const char* pFontName, int fontSize) = 0;
    virtual void setNativeFontColor(const ccColor3B& color) = 0;
    virtual void setNativePlaceholderFont(const char* pFontName, int fontSize) = 0;
    virtual void setNativePlaceholderFontColor(const ccColor3B& color) = 0;
    virtual void setNativeInputMode(EditBoxInputMode inputMode) = 0;
    virtual void setNativeInputFlag(EditBoxInputFlag inputFlag) = 0;
    virtual void setNativeReturnType(KeyboardReturnType returnType) = 0;
    virtual void setNativeText(const char* pText) = 0;
    virtual void setNativePlaceHolder(const char* pText) = 0;
    virtual void setNativeVisible(bool visible) = 0;
    virtual void updateNativeFrame(const CCRect& rect) = 0;
    virtual const char* getNativeDefaultFontName() = 0;
    virtual void nativeOpenKeyboard() = 0;
    virtual void nativeCloseKeyboard() = 0;
    virtual void setNativeMaxLength(int maxLength) {};


protected:
    void         initInactiveLabels(const CCSize& size);
    void         setInactiveText(const char* pText);
    void         placeInactiveLabels(const CCSize& size);
    virtual void doAnimationWhenKeyboardMove(float duration, float distance)override {};

    CCLabelTTF* _label;
    CCLabelTTF* _labelPlaceHolder;
    EditBoxInputMode    _editBoxInputMode;
    EditBoxInputFlag    _editBoxInputFlag;
    KeyboardReturnType  _keyboardReturnType;

    std::string _text;
    std::string _placeHolder;

    std::string _fontName;
    std::string _placeholderFontName;

    int _fontSize;
    int _placeholderFontSize;

    ccColor3B _colText;
    ccColor3B _colPlaceHolder;

    int   _maxLength;
    CCSize _contentSize;
    bool _editingMode;
};



NS_CC_EXT_END

#endif /* __UIEditBoxIMPLICOMMON_H__ */

