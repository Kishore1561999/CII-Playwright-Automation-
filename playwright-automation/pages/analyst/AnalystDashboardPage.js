const { expect } = require('@playwright/test');
const BasePage = require('../BasePage');

class AnalystDashboardPage extends BasePage {
  constructor(page) {
    super(page);
    this.baseURL = '/analyst/dashboard';

    // Selectors
    this.dashboardTitle = page.locator('h1, [class*="dashboard"], [class*="heading"]');
    this.userRows = page.locator('table tbody tr, [class*="user-row"], [class*="item"]');
    this.statusBadge = page.locator('[class*="badge"], [class*="status"]');

    // CII Data Collection (Analyst)
    this.ciiDataLink = page.locator('a[href*="cii_data"]');
    this.sectorDropdown = page.locator('select#sector_id');
    this.yearDropdown = page.locator('select#year_id');
    this.applyFilterBtn = page.locator('#apply-filter, button:has-text("Search")');
  }

  async verifyDashboardLoaded() {
    await expect(this.page).toHaveURL(/.*analyst\/dashboard/);
  }

  /**
   * CII Data Collection
   */
  async navigateToCIIDataCollection() {
    await this.ciiDataLink.click();
    await this.page.waitForLoadState('networkidle');
    console.log('✓ Analyst: Navigated to CII Data Collection');
  }

  async searchCIIData(sector, year) {
    if (sector) await this.selectOption('select#sector_id', sector);
    if (year) await this.selectOption('select#year_id', year);
    await this.applyFilterBtn.click();
    await this.page.waitForLoadState('networkidle');
    console.log(`✓ Analyst: Searched CII Data: Sector=${sector}, Year=${year}`);
  }

  async navigateToAnalystDashboard() {
    await this.navigate(this.baseURL);
    await this.page.waitForLoadState('networkidle');
    console.log('✓ Navigated to Analyst Dashboard');
  }

  // Duplicate verifyDashboardLoaded removed


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
