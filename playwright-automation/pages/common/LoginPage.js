const BasePage = require('../BasePage');

class LoginPage extends BasePage {
    constructor(page) {
        super(page);
        this.emailInput = page.locator('input[name="user[email]"]');
        this.passwordInput = page.locator('input[name="user[password]"]');
        this.signInButton = page.locator('input[type="submit"][value="Sign In"]');
        this.forgotPasswordLink = page.locator('text=Forgot Password?');
        this.createAccountLink = page.locator('text=Create an Account');
    }

    async login(email, password) {
        await this.emailInput.fill(email);
        await this.passwordInput.fill(password);
        await this.signInButton.click();
        // Wait for redirect to dashboard or company users page to ensure it's loaded before next steps
        await this.page.waitForURL(/.*dashboard|.*company_users|.*analyst\/dashboard/, { waitUntil: 'load', timeout: 30000 });
        await this.page.waitForLoadState('networkidle');
    }
    async logout() {
        await this.page.locator('a.nav-link.dropdown-toggle').click();
        await this.page.getByRole('link', { name: 'Log Out' }).waitFor({ state: 'visible', timeout: 5000 });
        await this.page.getByRole('link', { name: 'Log Out' }).click();

        // Wait for logout modal and click Yes
        await this.page.locator('#modalLogout').waitFor({ state: 'visible', timeout: 5000 });
        await this.page.locator('#modalLogout').getByRole('link', { name: 'Yes' }).click();

        // Ensure logout is complete by waiting for sign-in page
        await this.page.waitForURL(/.*sign_in/, { timeout: 10000 });
    }
}

module.exports = LoginPage;
