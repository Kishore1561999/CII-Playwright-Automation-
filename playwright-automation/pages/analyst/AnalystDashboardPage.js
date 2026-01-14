const BasePage = require('../BasePage');

class AnalystDashboardPage extends BasePage {
  constructor(page) {
    super(page);
    this.baseURL = '/analyst/dashboard';

    // Selectors
    this.dashboardTitle = page.locator('h1, [class*="dashboard"], [class*="heading"]');
    this.userRows = page.locator('table tbody tr, [class*="user-row"], [class*="item"]');
    this.statusBadge = page.locator('[class*="badge"], [class*="status"]');
  }

  async navigateToAnalystDashboard() {
    await this.navigate(this.baseURL);
    await this.page.waitForLoadState('networkidle');
    console.log('✓ Navigated to Analyst Dashboard');
  }

  async verifyDashboardLoaded() {
    await this.dashboardTitle.first().waitFor({ state: 'visible', timeout: 10000 });
    console.log('✓ Analyst dashboard loaded');
    return true;
  }

  async getAssignedUserRow(companyName) {
    // Using filter to find the row containing company name
    const row = this.userRows.filter({ hasText: companyName });
    await row.first().waitFor({ state: 'visible', timeout: 10000 });
    return row.first();
  }

  async clickViewAssessment(companyName) {
    const row = await this.getAssignedUserRow(companyName);

    // Click the "View response" dropdown button
    await row.locator('button[title="View response"]').click();

    // Click the "CII user response" link in the dropdown
    await row.locator('a.dropdown-item', { hasText: 'CII user response' }).click();

    await this.page.waitForLoadState('networkidle');
    console.log(`✓ Clicked View Response -> CII user response for: ${companyName}`);
  }

  async verifyUserStatus(companyName, expectedStatus) {
    const row = await this.getAssignedUserRow(companyName);
    const badge = row.locator(this.statusBadge).first();

    const status = await badge.textContent();
    console.log(`✓ User status for ${companyName}: ${status}`);
    return status.includes(expectedStatus);
  }

  async refreshDashboard() {
    await this.page.reload();
    await this.page.waitForLoadState('networkidle');
    console.log('✓ Dashboard refreshed');
  }
}

module.exports = AnalystDashboardPage;
