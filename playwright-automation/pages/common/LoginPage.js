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
        console.log('Starting logout process...');
        await this.page.waitForLoadState('load');
        await this.page.waitForTimeout(1000);

        // Aggressively clear any lingering modals, backdrops or toasts using JS evaluation
        await this.page.evaluate(() => {
            document.querySelectorAll('.modal-backdrop, .toast, .modal.show').forEach(el => el.remove());
            document.body.classList.remove('modal-open');
            document.body.style.overflow = '';
            document.body.style.paddingRight = '';
        }).catch(() => { });
        await this.page.locator('.modal.show, .modal-backdrop, .toast').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        const profileDropdown = this.page.locator('a.nav-link.dropdown-toggle, .user-profile-dropdown, #user-profile').first();
        const logoutLink = this.page.locator('a[href*="sign_out"], a:has-text("Log Out"), a:has-text("Logout"), button:has-text("Log Out")').first();

        await profileDropdown.scrollIntoViewIfNeeded();
        try {
            console.log('Attempting to click profile dropdown...');
            await profileDropdown.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`⚠ Standard click failed on profile dropdown: ${error.message}. Attempting JS click.`);
            await profileDropdown.dispatchEvent('click');
        }

        // Wait for dropdown animation and check visibility
        await this.page.waitForTimeout(1500);

        const modal = this.page.locator('#modalLogout, .modal:has-text("Logout"), .modal:has-text("Log Out")').first();
        try {
            console.log('Waiting for Logout link...');
            await logoutLink.waitFor({ state: 'attached', timeout: 10000 });
            await logoutLink.scrollIntoViewIfNeeded();

            // Try to click it
            await logoutLink.click({ force: true, timeout: 5000 });

            // Critical check: Did the modal appear?
            try {
                await modal.waitFor({ state: 'visible', timeout: 3000 });
            } catch (e) {
                console.warn('⚠ Modal did not appear after standard click. Retrying with JS click.');
                await logoutLink.dispatchEvent('click');
            }
        } catch (error) {
            console.warn(`⚠ Logout link interaction failed: ${error.message}. Attempting JS click fallback.`);
            await logoutLink.dispatchEvent('click');
        }

        try {
            await modal.waitFor({ state: 'visible', timeout: 10000 });
        } catch (error) {
            console.warn(`⚠ Logout modal still not visible via selector: ${error.message}. Forcing JS click on Yes button anyway.`);
        }

        const yesButton = modal.locator('a:has-text("Yes"), button:has-text("Yes"), .btn:has-text("Yes"), #logout_yes').first();
        try {
            await yesButton.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`⚠ Failed to click Yes button: ${error.message}. Attempting JS click.`);
            await yesButton.dispatchEvent('click');
        }

        // Ensure logout is complete by waiting for sign-in page
        try {
            await this.page.waitForURL(/.*sign_in/, { timeout: 15000 });
        } catch (error) {
            if (this.page.url().includes('chromewebdata') || error.name === 'TimeoutError') {
                console.warn('⚠ Logout redirect failed or timed out. Attempting reload...');
                await this.page.reload();
                await this.page.waitForURL(/.*sign_in/, { timeout: 10000 });
            } else {
                throw error;
            }
        }
    }
}

module.exports = LoginPage;
