const { test, expect } = require('@playwright/test');
const AdminPage = require('../../pages/admin/AdminPage');
const LoginPage = require('../../pages/common/LoginPage');
const Env = require('../../utils/Env');

test.describe('Admin Functional Workflows', () => {
    let page;
    let loginPage;
    let adminPage;

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
        loginPage = new LoginPage(page);
        adminPage = new AdminPage(page);

        // Log in as Admin once for all tests in this describe block (if they share state/session)
        // Or login in beforeEach if session is not persistent. 
        // Assuming session persists or we just login once for efficiency.
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
    });

    test.afterAll(async () => {
        await page.close();
    });

    test('ESG Diagnostic - Search and Filter', async () => {
        await adminPage.navigateToESGDiagnostic();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table')).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table')).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table')).toBeVisible();
    });

    test('Basic Subscription - Search and Filter', async () => {
        await adminPage.navigateToBasicSubscription();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table')).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table')).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table')).toBeVisible();
    });

    test('PB Data Management - Search and Filter', async () => {
        await adminPage.navigateToPBDataManagement();

        // 1. Filter by Year
        await adminPage.filterByYear('2025');
        await expect(page.locator('table')).toBeVisible();

        // 2. Filter by Sector
        await adminPage.filterBySector('Information Technology');
        await expect(page.locator('table')).toBeVisible();

        // 3. Search by Company
        await adminPage.searchByCompany('Demo user for testing');
        await expect(page.locator('table')).toBeVisible();
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

    test('User Management - Create and Edit User', async () => {
        await adminPage.navigateToUserManagement();

        const timestamp = Date.now();
        const testUserEmail = `testuser_${timestamp}@example.com`;
        const firstName = "Test";
        const lastName = "User";
        const mobile = "1234567890";
        const password = "Password123!";

        // Create
        // Role '1' = Admin
        await adminPage.createUser(firstName, lastName, testUserEmail, mobile, '1', password);
        await expect(page.locator('body')).toContainText(testUserEmail); // Verify creation or use toast
        // await expect(page.locator('.toast-message')).toContainText('created successfully'); // Optional strict check

        // Edit
        const newFirstName = "UpdatedTest";
        await adminPage.editUser(testUserEmail, newFirstName, "UpdatedUser");
        //await expect(page.locator('body')).toContainText('User was successfully updated'); // Verify toast
        // Verify changes in table?
        await expect(page.locator('tr').filter({ hasText: testUserEmail })).toContainText(newFirstName);

        // Delete (Cleanup)
        await adminPage.deleteUserMgmt(testUserEmail);
        // Verify deletion
        await expect(page.locator('body')).not.toContainText(testUserEmail);
        // Or check toast
        // await expect(page.locator('.toast-message')).toContainText('deleted successfully');
    });
});
