const { expect } = require('@playwright/test');
const BasePage = require('../BasePage');

class ManagerPage extends BasePage {
    constructor(page) {
        super(page);

        // Selectors
        this.esgDiagnosticsLink = page.locator('a[href*="esgadmin/company_users"]'); // Similar to Admin
        this.basicSubLink = page.locator('a[href*="basic_subscription"]');
        this.pbDataLink = page.locator('a[href*="pb_data"]');
        this.ciiDataLink = page.locator('a[href*="cii_data"]');

        this.applyFilterBtn = page.locator('#apply-filter, button:has-text("Search")');
    }
    async verifyDashboardLoaded() {
        await expect(this.page).toHaveURL(/.*manager/);
    }

    /**
     * ESG Diagnostic
     */
    async navigateToESGDiagnostic() {
        await this.esgDiagnosticsLink.click();
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Manager: Navigated to ESG Diagnostic');
    }

    async searchESGDiagnostic(companyName, sector, year) {
        if (companyName) await this.fillText('input#companyNameFilter', companyName);
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Manager: Searched ESG Diagnostic`);
    }

    /**
     * Basic Subscription
     */
    async navigateToBasicSubscription() {
        await this.basicSubLink.click();
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Manager: Navigated to Basic Subscription');
    }

    async searchBasicSubscription(sector, year) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Manager: Searched Basic Sub`);
    }

    /**
     * PB Data Management
     */
    async navigateToPBDataManagement() {
        await this.pbDataLink.click();
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Manager: Navigated to PB Data Management');
    }

    async searchPBData(sector, year) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Manager: Searched PB Data`);
    }

    /**
     * CII Data Collection
     */
    async navigateToCIIDataCollection() {
        await this.ciiDataLink.click();
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Manager: Navigated to CII Data Collection');
    }

    async searchCIIData(sector, year, analystName) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        if (analystName) await this.fillText('input#analyst_name', analystName);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Manager: Searched CII Data`);
    }
}

module.exports = ManagerPage;
