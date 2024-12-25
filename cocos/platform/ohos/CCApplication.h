#ifndef __CC_APPLICATION_OHOS_H__
#define __CC_APPLICATION_OHOS_H__

#if CC_TARGET_PLATFORM == CC_PLATFORM_OHOS

#include "platform/CCCommon.h"
#include "platform/CCApplicationProtocol.h"


NS_CC_BEGIN

class CC_DLL Application : public ApplicationProtocol {
public:
    /**
     * @js ctor
     */
    Application();
    /**
     * @js NA
     * @lua NA
     */
    virtual ~Application();

    /**
    @brief    Callback by Director to limit FPS.
    @param interval The time, expressed in seconds, between current frame and next.
    */
    void setAnimationInterval(double interval);

    /**
    @brief    Run the message loop.
    */
    int run();

    /**
    @brief    Get current application instance.
    @return Current application instance pointer.
    */
    static Application* getInstance();

    /** @deprecated Use getInstance() instead */
    CC_DEPRECATED_ATTRIBUTE static Application* sharedApplication();

    /**
    @brief Get current language config
    @return Current language config
    */
    virtual LanguageType getCurrentLanguage();
    
    /**
    @brief Get current language iso 639-1 code
    @return Current language iso 639-1 code
    */
    virtual const char * getCurrentLanguageCode();
    
    /**
     @brief Get target platform
     */
    virtual Platform getTargetPlatform();
    
    /**
     @brief Open url in default browser
     @param String with url to open.
     @return true if the resource located by the URL was successfully opened; otherwise false.
     */
    virtual bool openURL(const std::string &url);

	/**
	@brief  This function will be called when the application screen size is changed.
	@param new width
	@param new height
	*/
	virtual void applicationScreenSizeChanged(int newWidth, int newHeight);

protected:
    static Application * sm_pSharedApplication;
};

NS_CC_END

#endif // CC_TARGET_PLATFORM == CC_PLATFORM_OHOS

#endif    // __CC_APPLICATION_OHOS_H__
