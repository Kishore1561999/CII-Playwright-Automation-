class BasePage {
    /**
     * @param {import('@playwright/test').Page} page
     */
    constructor(page) {
        this.page = page;
    }

    async navigate(path = '/') {
        await this.page.goto(path);
    }

    async pause() {
        await this.page.pause();
    }

    async waitForUrl(urlPattern) {
        await this.page.waitForURL(urlPattern);
    }
}

module.exports = BasePage;
