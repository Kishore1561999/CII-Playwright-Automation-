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
    this.ciiDataLink = page.locator('a[href="/analyst/data_collection"]');
    this.sectorDropdown = page.locator('select#sector_id');
    this.yearDropdown = page.locator('select#year_id');
    this.applyFilterBtn = page.locator('#apply-filter, button:has-text("Search")');
  }

  async _robustClick(locator, name) {
    // Ensure any lingering modals or backdrops are cleared first
    await this.page.locator('.modal.show, .modal-backdrop, .toast').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

    await locator.scrollIntoViewIfNeeded();
    try {
      await locator.click({ force: true, timeout: 5000 });
      console.log(`\u2713 Clicked: ${name}`);
    } catch (error) {
      console.warn(`\u26A0 Standard click failed on ${name}: ${error.message}. Attempting JS click.`);
      await locator.dispatchEvent('click');
      console.log(`\u2713 JS clicked: ${name}`);
    }
  }

  async verifyDashboardLoaded() {
    await expect(this.page).toHaveURL(/.*analyst\/dashboard/);
  }

  /**
   * CII Data Collection
   */
  async navigateToCIIDataCollection() {
    await this._robustClick(this.ciiDataLink, 'Analyst CII Data link');
    await this.page.waitForLoadState('networkidle');
    await this.page.waitForTimeout(2000);
  }

  async searchCompany(companyName) {
    // Assuming a search input exists, based on AdminPage it's often input#companyNameFilter or just a search box
    // User request: "Search the company name in search box"
    const searchInput = this.page.getByPlaceholder(/Search/i).or(this.page.locator('input[type="search"]')).or(this.page.locator('input#companyNameFilter'));
    await searchInput.first().fill(companyName);

    const applyBtn = this.page.locator('#apply-filter, button:has-text("Search"), button:has-text("Apply")');
    if (await applyBtn.isVisible()) {
      await applyBtn.click();
    } else {
      await searchInput.press('Enter');
    }

    await this.page.waitForLoadState('networkidle');
    console.log(`✓ Analyst: Searched for company: ${companyName}`);
  }

  async clickEditAssessment(companyName) {
    console.log(`✓ Analyst: Clicking Edit for ${companyName}`);
    // Find row with company name (optional, if search is effectively filtering)
    // Locator from request: <a ... href="/analyst/analyst_data_collection/320/provide_data">...<i class="bx bx-edit-alt ..."></i></a>
    const editBtn = this.page.locator(`a[href*="provide_data"]`).first();
    await editBtn.waitFor({ state: 'visible', timeout: 10000 });
    await editBtn.click();
    await this.page.waitForLoadState('networkidle');
  }

  async searchCIIData(sector, year) {
    if (sector) await this.selectOption('select#sector_id', sector);
    if (year) await this.selectOption('select#year_id', year);
    await this.applyFilterBtn.click();
    await this.page.waitForLoadState('networkidle');
    console.log(`✓ Analyst: Searched CII Data: Sector=${sector}, Year=${year}`);
  }

  async navigateToAnalystDashboard() {
    await this.page.goto(this.baseURL);
    await this.page.waitForLoadState('networkidle');
    await this.page.waitForTimeout(2000);
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
