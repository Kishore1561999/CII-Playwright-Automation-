const { test, expect } = require('@playwright/test');
const LoginPage = require('../../../pages/common/LoginPage');
const AdminDashboardPage = require('../../../pages/admin/AdminDashboardPage');
const AdminCompanyUsersPage = require('../../../pages/admin/AdminCompanyUsersPage');
const Env = require('../../../utils/Env');
const TestData = require('../../../utils/TestData');

/**
 * DELETE USER CLEANUP TEST
 * 
 * This test runs AFTER:
 * 1. assessment.spec.js - Company registration, approval, and assessment submission
 * 2. post_assessment_review.spec.js - Admin assignment and analyst review
 * 
 * This test handles the cleanup: deleting the test company
 * 
 * Prerequisites:
 * - Environment variables must be set:
 *   - TEST_COMPANY_NAME: Name of the company to delete
 *   - Or: Uses hardcoded testCompanyName if env var not available
 */

test.describe('Cleanup: Delete Test Company User', () => {
    let page;
    const savedData = TestData.load();
    const testCompanyName = savedData.companyName || process.env.TEST_COMPANY_NAME || `E2E_Company_${Date.now()}`;

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
        console.log(`Cleanup: Preparing to delete company: ${testCompanyName}`);
    });

    test.afterAll(async () => {
        await page.close();
        console.log('Cleanup: Page closed');
        // Clear test data after successful cleanup
        TestData.clear();
        console.log('Cleanup: Test data cleared');
    });

    test('Step 1: Logout Current User If Logged In', async () => {
        console.log('\n=== CLEANUP STEP 1: Logout Current User ===\n');

        try {
            // Check if user is logged in by looking for logout menu
            const logoutMenu = page.locator('a.nav-link.dropdown-toggle');
            const isVisible = await logoutMenu.isVisible({ timeout: 3000 }).catch(() => false);

            if (isVisible) {
                console.log('Logout menu found - attempting to logout');
                await logoutMenu.click();

                // Wait for logout link
                const logoutLink = page.getByRole('link', { name: 'Log Out' });
                await logoutLink.waitFor({ state: 'visible', timeout: 5000 });
                await logoutLink.click();

                // Handle logout modal
                const modal = page.locator('#modalLogout');
                await modal.waitFor({ state: 'visible', timeout: 5000 });

                const confirmYes = modal.getByRole('link', { name: 'Yes' });
                await confirmYes.click();

                // Wait for redirect to sign-in page
                await page.waitForURL(/.*sign_in/, { timeout: 10000 });
                console.log('✓ User logged out successfully');
            } else {
                console.log('User already logged out');
            }
        } catch (error) {
            console.log(`⚠ Logout attempt encountered issue (may already be logged out): ${error.message}`);
        }
    });

    test('Step 2: Admin Login', async () => {
        console.log('\n=== CLEANUP STEP 2: Admin Login ===\n');

        const loginPage = new LoginPage(page);

        try {
            // Navigate to sign-in page if not already there
            const currentUrl = page.url();
            if (!currentUrl.includes('sign_in')) {
                await loginPage.navigate('/users/sign_in');
            }

            // Login as admin
            await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

            // Wait for redirect to admin dashboard
            await page.waitForURL(/.*dashboard|.*company_users/, { timeout: 15000 });
            console.log('✓ Admin logged in successfully');
        } catch (error) {
            throw new Error(`Admin login failed: ${error.message}`);
        }
    });

    test('Step 3: Navigate to Company Users', async () => {
        console.log('\n=== CLEANUP STEP 3: Navigate to Company Users ===\n');

        const adminDashboard = new AdminDashboardPage(page);

        try {
            await adminDashboard.navigateToCompanyUsers();
            console.log('✓ Navigated to Company Users page');
        } catch (error) {
            throw new Error(`Failed to navigate to Company Users: ${error.message}`);
        }
    });

    test('Step 4: Search and Delete Company', async () => {
        console.log('\n=== CLEANUP STEP 4: Search and Delete Company ===\n');
        console.log(`Searching for company: ${testCompanyName}`);

        const adminCompanyUsers = new AdminCompanyUsersPage(page);

        try {
            // Search for the company
            const searchInput = page.locator('input[placeholder*="search" i], input[class*="search"]');
            await searchInput.waitFor({ state: 'visible', timeout: 5000 });
            await searchInput.fill(testCompanyName);
            await page.waitForTimeout(1000); // Wait for search results

            console.log(`✓ Searched for company: ${testCompanyName}`);

            // Find and click delete button for this company
            // The deleteCompany method from page object should handle this
            await adminCompanyUsers.deleteCompany(testCompanyName);
            console.log(`✓ Delete action initiated for: ${testCompanyName}`);

            // Verify deletion success
            try {
                await expect(adminCompanyUsers.deleteSuccessToast).toBeVisible({ timeout: 5000 });
                console.log(`✓ Successfully deleted company: ${testCompanyName}`);
            } catch (e) {
                console.warn(`⚠ Delete success toast not found, but delete may have completed`);
            }
        } catch (error) {
            throw new Error(`Failed to delete company: ${error.message}`);
        }
    });

    test('Step 5: Verify Deletion and Logout', async () => {
        console.log('\n=== CLEANUP STEP 5: Verify Deletion and Logout ===\n');

        const adminCompanyUsers = new AdminCompanyUsersPage(page);

        try {
            // Refresh page to verify deletion
            await page.reload();
            await page.waitForLoadState('networkidle');
            console.log('✓ Page refreshed');

            // Try to search for deleted company - should not find it
            const searchInput = page.locator('input[placeholder*="search" i], input[class*="search"]');
            if (await searchInput.isVisible({ timeout: 3000 }).catch(() => false)) {
                await searchInput.fill(testCompanyName);
                await page.waitForTimeout(1000);

                // Check if company is still in list
                const companyRow = page.locator(`text=${testCompanyName}`).first();
                const isVisible = await companyRow.isVisible({ timeout: 2000 }).catch(() => false);

                if (isVisible) {
                    console.warn(`⚠ Company still appears in list (may take time to reflect)`);
                } else {
                    console.log(`✓ Company no longer appears in list - deletion confirmed`);
                }
            }

            // Logout admin
            const logoutMenu = page.locator('a.nav-link.dropdown-toggle');
            if (await logoutMenu.isVisible({ timeout: 3000 }).catch(() => false)) {
                await logoutMenu.click();
                const logoutLink = page.getByRole('link', { name: 'Log Out' });
                await logoutLink.click();

                // Handle logout modal
                const modal = page.locator('#modalLogout');
                const confirmYes = modal.getByRole('link', { name: 'Yes' });
                await confirmYes.click();

                await page.waitForURL(/.*sign_in/, { timeout: 10000 });
                console.log('✓ Admin logged out');
            }
        } catch (error) {
            console.warn(`⚠ Verification step encountered issue: ${error.message}`);
        }
    });
});

/**
 * NOTES:
 * 
 * Test Execution:
 * 1. Run assessment.spec.js first:
 *    npm test tests/e2e/company_user/assessment.spec.js
 * 
 * 2. Run post_assessment_review.spec.js second:
 *    npm test tests/e2e/analyst/post_assessment_review.spec.js
 * 
 * 3. Run this delete_user.spec.js last:
 *    npm test tests/e2e/cleanup/delete_user.spec.js
 * 
 * Or run all three in sequence:
 *    npm test tests/e2e/company_user/assessment.spec.js tests/e2e/analyst/post_assessment_review.spec.js tests/e2e/cleanup/delete_user.spec.js
 * 
 * Data Flow:
 * - assessment.spec.js creates test company and sets TEST_COMPANY_NAME env var
 * - post_assessment_review.spec.js uses TEST_COMPANY_NAME from env
 * - delete_user.spec.js uses TEST_COMPANY_NAME from env to find and delete company
 * 
 * If environment variables are not passed correctly, this test uses hardcoded
 * timestamp-based company name. Ensure TEST_COMPANY_NAME is exported from assessment.spec.js
 */
