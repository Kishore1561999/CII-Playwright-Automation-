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

        let attempts = 0;
        const maxAttempts = 3;

        while (attempts < maxAttempts) {
            try {
                await this.page.goto(fullUrl, { waitUntil: 'domcontentloaded', timeout: 30000 });
                return; // Navigation successful
            } catch (error) {
                attempts++;
                const isNetworkChange = error.message.includes('net::ERR_NETWORK_CHANGED');
                const isInterrupted = error.message.includes('interrupted');

                if ((isNetworkChange || isInterrupted) && attempts < maxAttempts) {
                    console.warn(`⚠ Navigation attempt ${attempts} failed for ${fullUrl} (${error.message}). Retrying in 1s...`);
                    await this.page.waitForTimeout(1000);
                    continue;
                }
                throw error;
            }
        }
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
