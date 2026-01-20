const { test, expect } = require('@playwright/test');
const AdminPage = require('../../pages/admin/AdminPage'); // Using AdminPage logic as requested
const LoginPage = require('../../pages/common/LoginPage');
const Env = require('../../utils/Env');

test.describe('Manager Functional Workflows', () => {
    let page;
    let loginPage;
    let adminPage; // Using adminPage instance for shared logic

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
        loginPage = new LoginPage(page);
        adminPage = new AdminPage(page);

        await loginPage.navigate('/users/sign_in');
        // Using Manager credentials from Env
        await loginPage.login(Env.MANAGER_EMAIL, Env.MANAGER_PASSWORD);
        await expect(page).toHaveURL(/.*manager/);
    });

    test.afterAll(async () => {
        await page.close();
    });

    test('ESG Diagnostic - Search and Filter', async () => {
        await adminPage.navigateToESGDiagnostic();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table').first()).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table').first()).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table').first()).toBeVisible();
    });

    test('Basic Subscription - Search and Filter', async () => {
        await adminPage.navigateToBasicSubscription();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table').first()).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table').first()).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table').first()).toBeVisible();
    });

    test('PB Data Management - Search and Filter', async () => {
        await adminPage.navigateToPBDataManagement();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table').first()).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table').first()).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table').first()).toBeVisible();
    });

    test('CII Data Collection - Search and Filter', async () => {
        await adminPage.navigateToCIIDataCollection();

        // 1. Filter by Year
        await adminPage.filterByYear('2024'); // Using 2024 as 2026 might not be populated
        await expect(page.locator('table').first()).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Automobiles & Auto Components');
        await expect(page.locator('table').first()).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('CII_CEAT Limited');
        await expect(page.locator('table').first()).toBeVisible();
    });

    // User Management test is EXCLUDED as requested
});
