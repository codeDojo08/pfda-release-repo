package precisionFDA.pages.apps;

import org.apache.log4j.Logger;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.support.FindBy;
import ru.yandex.qatools.htmlelements.element.Link;
import precisionFDA.locators.AppsLocators;
import precisionFDA.pages.AbstractPage;

public class AppsFeaturedPage extends AbstractPage {

    private final Logger log = Logger.getLogger(this.getClass());

    @FindBy(xpath = AppsLocators.APPS_FEATURED_ACTIVATED_LINK)
    private Link appsFeaturedActivatedLink;

    public AppsFeaturedPage(final WebDriver driver) {
        super(driver);
        waitUntilScriptsReady();
        waitForPageToLoadAndVerifyBy(By.xpath(AppsLocators.APPS_MAIN_DIV));
    }

    public Link getAppsFeaturedActivatedLink() {
        return appsFeaturedActivatedLink;
    }

    public boolean isFeaturedLinkActivated() {
        return isElementPresent(getAppsFeaturedActivatedLink());
    }

}
