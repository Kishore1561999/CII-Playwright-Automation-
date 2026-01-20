const { test, expect } = require('@playwright/test');
const RegistrationPage = require('../../pages/company_user/RegistrationPage');
const AdminPage = require('../../pages/admin/AdminPage');
const LoginPage = require('../../pages/common/LoginPage');
const DashboardPage = require('../../pages/company_user/DashboardPage');
const Env = require('../../utils/Env');

test.describe('Registration and Approval Flow', () => {
    let page;
    let loginPage;
    let adminPage;
    let registrationPage;

    const timestamp = Date.now();
    const companyEmail = `func_test_${timestamp}@example.com`;
    const companyName = `Func_Co_${timestamp}`;
    const password = 'Password@123';

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
        loginPage = new LoginPage(page);
        adminPage = new AdminPage(page);
        registrationPage = new RegistrationPage(page);
    });

    test.afterAll(async () => {
        await page.close();
        // Typically cleanup would happen here or in a separate cleanup test
    });

    test('Company Registration', async () => {
        await registrationPage.navigate('/users/sign_up');

        const companyData = {
            name: companyName,
            sector: 'Automobiles & Auto Components',
            scale: 'Medium',
            description: 'Functional Test',
            gst: '07AAATC0188R1ZB',
            logoPath: 'path/Golden Bridge.png', // Ensure this file exists or update method to handle missing
            address: '123 Func St',
            country: 'IN',
            state: 'DL',
            city: 'New Delhi',
            zip: '110001',
            pan: 'AAATC0188R'
        };
        const contactData = {
            name: 'Func User',
            email: companyEmail,
            designation: 'Manager',
            contact: '9876543210'
        };

        // Note: modify registerAccount in RegistrationPage if logoPath handling is strict
        // For now assuming existing method works or we mock it, keeping it simple
        await registrationPage.registerAccount(companyData, contactData, password);
        await expect(page.getByText(/Your registration form has been submitted successfully/i)).toBeVisible();
        // try {
        //     await registrationPage.registerAccount(companyData, contactData, password);
        //     await expect(page.getByText(/Your registration form has been submitted successfully/i)).toBeVisible();
        // } catch (e) {
        //     console.log('Registration might have failed or needs valid file path');
        //     // Check if failure is due to file path, if so, we might need a dummy file
        // }
    });

    test('Admin Approval', async () => {
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        await adminPage.navigateToCompanyUsers();
        await adminPage.approveCompany(companyName);
        await loginPage.logout();
    });

    test('Company User Login', async () => {
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(companyEmail, password);
        await expect(page).toHaveURL(/.*dashboard/);
        console.log('✓ Company User successfully logged in after approval');
        await loginPage.logout();
    });
    test('Admin Login and Delete Test Company', async () => {

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

        await adminPage.navigateToCompanyUsers();
        await adminPage.deleteCompany(companyName);

        console.log(`✓ Deleted test company: ${companyName}`);
        await loginPage.logout();
    });
});
