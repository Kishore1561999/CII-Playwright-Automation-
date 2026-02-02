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
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.emailInput.fill(email);
        await this.passwordInput.fill(password);
        // Use force: true to bypass any minor UI obstructions or lingering invisible elements
        await this.signInButton.click({ force: true });

        try {
            // Wait for redirect to dashboard or company users page
            // Admin -> /esgadmin/company_users
            // Manager -> /manager/company_users
            // Analyst -> /analyst/dashboard
            // Company User -> /company_user/dashboard
            await this.page.waitForURL(/.*esgadmin\/company_users|.*manager\/company_users|.*analyst\/dashboard|.*company_user\/dashboard|.*company_user\/peer_benchmarking/, {
                waitUntil: 'domcontentloaded',
                timeout: 45000
            });
        } catch (error) {
            // Check if still on sign-in page (login failed)
            const currentUrl = this.page.url();
            if (currentUrl.includes('sign_in')) {
                throw new Error(`Login failed for ${email}. Still on sign-in page. User may not exist or credentials are incorrect.`);
            }
            throw error;
        }
        // Removed networkidle wait as it can fail if page navigates/closes - domcontentloaded is sufficient
    }

    async logout() {
        // Ensure blocking elements (toasts, modals) are gone before clicking logout
        // await this.page.locator('.modal.show, .toast-message, .toast').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        // Use force: true because notification toasts often cover the user menu in the top right
        await this.page.locator('a.nav-link.dropdown-toggle').click(); //{ force: true }
        // Target specific profile dropdown using the avatar/profile structure
        // await this.page.locator('a.nav-link.dropdown-toggle:has(.avatar), a.nav-link.dropdown-toggle:has(.profile_name_text)').click({ force: true });
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
