const { test, expect } = require('@playwright/test');
const LoginPage = require('../../../pages/common/LoginPage');
const Env = require('../../../utils/Env');

test.describe('Authentication', () => {
    let loginPage;

    test.beforeEach(async ({ page }) => {
        loginPage = new LoginPage(page);
        await loginPage.navigate(Env.BASE_URL + 'users/sign_in');
    });

    test('should login successfully with valid admin credentials', async ({ page }) => {
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

        // Verify successful login (e.g., check for dashboard URL or element)
        // Adjust assertion based on actual redirect
        await expect(page).toHaveURL(/.*esgadmin\/company_users/);
        // or
        // await expect(page.locator('text=Signed in successfully')).toBeVisible();
    });
});
