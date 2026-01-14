const BasePage = require('../BasePage');

class RegistrationPage extends BasePage {
    constructor(page) {
        super(page);
        // Company Info
        this.companyNameInput = page.locator('#user_company_name');
        this.sectorSelect = page.locator('#user_company_sector');
        this.scaleSelect = page.locator('#user_company_scale');
        this.descriptionInput = page.locator('#user_company_description');
        this.gstInput = page.locator('#user_gst');
        this.logoInput = page.locator('#user_company_logo');

        // Address Info
        this.addressLine1Input = page.locator('#user_company_address_line1');
        this.countrySelect = page.locator('#user_company_country');
        this.stateSelect = page.locator('#user_company_state');
        this.citySelect = page.locator('#user_company_city');
        this.zipInput = page.locator('#user_company_zip');
        this.panInput = page.locator('#user_pan_no');

        // Contact Info
        this.primaryNameInput = page.locator('#user_primary_name');
        this.primaryEmailInput = page.locator('#user_primary_email');
        this.primaryDesignationInput = page.locator('#user_primary_designation');
        this.primaryContactInput = page.locator('#user_primary_contact');

        // Login Info
        this.emailInput = page.locator('#user_email');
        this.passwordInput = page.locator('#user_password');
        this.passwordConfirmationInput = page.locator('#user_password_confirmation');

        // Navigation Tabs
        this.companyInfoTab = page.locator('#company-info');
        this.contactInfoTab = page.locator('#contact-info');
        this.loginInfoTab = page.locator('#login-info');
        this.servicesTab = page.locator('#payment-info');
        this.nextButton = page.locator('#next-btn');

        // Submit
        this.registerButton = page.locator('input[type="submit"][value="Register"]');
    }

    async fillCompanyInfo(data) {
        await this.companyNameInput.fill(data.name);
        await this.sectorSelect.selectOption({ label: data.sector });
        await this.scaleSelect.selectOption({ label: data.scale });
        await this.descriptionInput.fill(data.description);
        await this.gstInput.fill(data.gst);
        await this.logoInput.setInputFiles(data.logoPath); // Logo upload

        await this.addressLine1Input.fill(data.address);
        await this.countrySelect.selectOption(data.country); // Value or label
        // Wait for state dropdown to populate if dynamic
        await this.page.waitForTimeout(1000);
        await this.stateSelect.selectOption(data.state);
        await this.page.waitForTimeout(1000);
        await this.citySelect.selectOption(data.city);
        await this.zipInput.fill(data.zip);
        await this.panInput.fill(data.pan);
    }

    async fillContactInfo(data) {
        await this.nextButton.click();
        await this.primaryNameInput.fill(data.name);
        await this.primaryEmailInput.fill(data.email);
        await this.primaryDesignationInput.fill(data.designation);
        await this.primaryContactInput.fill(data.contact);
    }

    async fillLoginInfo(data, password) {
        await this.nextButton.click();
        await this.emailInput.fill(data.email); // Email    
        await this.passwordInput.fill(password); // Password
        await this.passwordConfirmationInput.fill(password); // Confirm Password
    }

    async selectServices() {
        await this.nextButton.click();
        await this.page.locator('#user_active').waitFor({ state: 'visible', timeout: 10000 });
        await this.page.locator('#user_active').click();
        // await this.page.locator('#services').click();
        // await this.page.locator('#basics').click();
    }

    async submit() {
        await this.registerButton.click();
    }

    async registerAccount(companyData, contactData, password) {
        await this.fillCompanyInfo(companyData);
        await this.fillContactInfo(contactData);
        await this.fillLoginInfo(contactData, password);
        await this.selectServices();
        await this.submit();
    }
}

module.exports = RegistrationPage;
