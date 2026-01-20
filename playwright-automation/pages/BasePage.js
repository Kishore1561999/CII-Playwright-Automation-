class BasePage {
    /**
     * @param {import('@playwright/test').Page} page
     */
    constructor(page) {
        this.page = page;
    }

    async navigate(path = '/') {
        const Env = require('../utils/Env');
        const baseUrl = Env.BASE_URL;
        const fullUrl = path.startsWith('http') ? path : `${baseUrl}${path.replace(/^\//, '')}`;
        await this.page.goto(fullUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
    }

    async pause() {
        await this.page.pause();
    }

    async waitForUrl(urlPattern) {
        await this.page.waitForURL(urlPattern);
    }

    /**
     * Reusable Helper Methods
     */
    async fillText(selector, value) {
        await this.page.locator(selector).fill(value);
    }

    async clickElement(selector) {
        await this.page.locator(selector).click();
    }

    async selectOption(selector, value) {
        await this.page.locator(selector).selectOption(value);
    }

    /**
     * Generic Search/Filter Method
     * @param {Locator} filterInputLocator - The locator for the input field
     * @param {string} value - The value to type
     * @param {Locator} applyButtonLocator - The locator for the apply/search button
     */
    async applyFilter(filterInputLocator, value, applyButtonLocator) {
        await filterInputLocator.fill(value);
        if (applyButtonLocator) {
            await applyButtonLocator.click();
        } else {
            await filterInputLocator.press('Enter');
        }
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Applied filter: ${value}`);
    }
}

module.exports = BasePage;
