const BasePage = require('../BasePage');

class AdminDashboardPage extends BasePage {
    constructor(page) {
        super(page);
        this.esgDiagnosticsLink = page.locator('a.menu-link[href="/esgadmin/company_users"]');
    }

    async navigateToCompanyUsers() {
        await this.esgDiagnosticsLink.click();
    }
}

module.exports = AdminDashboardPage;
