const BasePage = require('../../pages/BasePage');

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
        // Wait for redirect to dashboard or company users page
        await this.page.waitForURL(/.*dashboard|.*company_users/, { waitUntil: 'networkidle', timeout: 30000 });
    }
}

module.exports = LoginPage;
