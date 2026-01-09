const { test, expect } = require('@playwright/test');
const RegistrationPage = require('../../../pages/company_user/RegistrationPage');
const AdminDashboardPage = require('../../../pages/admin/AdminDashboardPage');
const AdminCompanyUsersPage = require('../../../pages/admin/AdminCompanyUsersPage');
const LoginPage = require('../../../pages/common/LoginPage');
const DashboardPage = require('../../../pages/company_user/DashboardPage');
const AssessmentPage = require('../../../pages/company_user/AssessmentPage');
const Env = require('../../../utils/Env');

// Run tests in serial mode to maintain workflow order
test.describe.configure({ mode: 'serial' });

test.describe('Company User Assessment Workflow', () => {
    let page;
    const timestamp = Date.now();
    const companyEmail = `e2e_user_${timestamp}@example.com`;
    const companyName = `E2E_Company_${timestamp}`;
    const password = 'Password@123';

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
    });

    test.afterAll(async () => {
        console.log('Starting cleanup: Deleting the User');
        try {
            const loginPage = new LoginPage(page);
            const adminDashboard = new AdminDashboardPage(page);
            const adminCompanyUsers = new AdminCompanyUsersPage(page);

            // Attempt to logout if stuck in user session
            try {
                await page.locator('a.nav-link.dropdown-toggle').click();
                await page.getByRole('link', { name: 'Log Out' }).waitFor({ state: 'visible', timeout: 5000 });
                await page.getByRole('link', { name: 'Log Out' }).click();
                // Wait for logout modal and click Yes
                await page.locator('#modalLogout').waitFor({ state: 'visible', timeout: 5000 });
                await page.locator('#modalLogout').getByRole('link', { name: 'Yes' }).click();

                // Ensure logout is complete by waiting for sign-in page
                await page.waitForURL(/.*sign_in/, { timeout: 10000 });
            } catch (error) {
                console.log('Cleanup: User already logged out or unable to logout', error.message);
            }

            // Login as Admin
            //await loginPage.navigate('/users/sign_in');
            await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
            await adminDashboard.navigateToCompanyUsers();

            // Delete the company
            await adminCompanyUsers.deleteCompany(companyName);
            await expect(adminCompanyUsers.deleteSuccessToast).toBeVisible();
            console.log(`Successfully deleted company: ${companyName}`);
        } catch (error) {
            console.error('Error during cleanup:', error);
        } finally {
            await page.close();
        }
    });

    test('Step 1: Company Registration', async () => {
        const registrationPage = new RegistrationPage(page);
        await registrationPage.navigate('/users/sign_up');

        const companyData = {
            name: companyName,
            sector: 'Automobiles & Auto Components',
            scale: 'Medium',
            description: 'E2E Workflow Test',
            gst: '07AAATC0188R1ZB',
            logoPath: 'path/Golden Bridge.png',
            address: '123 Workflow St',
            country: 'IN',
            state: 'DL',
            city: 'New Delhi',
            zip: '110001',
            pan: 'AAATC0188R'
        };
        const contactData = {
            name: 'Workflow User',
            email: companyEmail,
            designation: 'Manager',
            contact: '9876543210'
        };

        await registrationPage.registerAccount(companyData, contactData, password);
        console.log(`Registered company: ${companyName}`);
        await expect(page.getByText(/Your registration form has been submitted successfully/i)).toBeVisible();
    });

    test('Step 2: Admin Approval', async () => {
        test.setTimeout(60000);
        const loginPage = new LoginPage(page);
        const adminDashboard = new AdminDashboardPage(page);
        const adminCompanyUsers = new AdminCompanyUsersPage(page);

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        await adminDashboard.navigateToCompanyUsers();
        await adminCompanyUsers.approveCompany(companyName);
        await expect(adminCompanyUsers.successToast).toBeVisible();
        await page.waitForTimeout(2000);

        // Logout Admin
        await page.locator('a.nav-link.dropdown-toggle').click();
        await page.getByRole('link', { name: 'Log Out' }).waitFor({ state: 'visible', timeout: 5000 });
        await page.getByRole('link', { name: 'Log Out' }).click();

        // Wait for logout modal and click Yes
        await page.locator('#modalLogout').waitFor({ state: 'visible', timeout: 5000 });
        await page.locator('#modalLogout').getByRole('link', { name: 'Yes' }).click();

        // Ensure logout is complete by waiting for sign-in page
        await page.waitForURL(/.*sign_in/, { timeout: 10000 });
    });

    test('Step 3: Company User Login & Assessment', async () => {
        console.log('Starting Step 3: Company User Login & Assessment');
        test.setTimeout(300000);
        const loginPage = new LoginPage(page);
        const dashboardPage = new DashboardPage(page);
        const assessmentPage = new AssessmentPage(page);

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(companyEmail, password);
        await page.waitForTimeout(2000);
        await dashboardPage.clickTakeAssessment();
        await page.waitForTimeout(2000);
        await assessmentPage.closeInstructions();
        await page.waitForTimeout(2000);

        // Fill a dummy question to verify save/submit
        await assessmentPage.selectAspect(); // Corporate Governance
        // Wait for questions to load
        for (let index = 1; index < 9; index++) {
            const count = '0' + index;
            //console.log(count);
            await assessmentPage.corporateGovernance(count);
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton(); // Business Ethics
        for (let index = 1; index < 9; index++) {
            const count = '0' + index;
            await assessmentPage.businessEthics(count);
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton(); //Risk Management
        for (let index = 1; index < 8; index++) {
            const count = '0' + index;
            if (count == '07') {
                await page.locator('#rm_07_The_organisation_has_not_been_involved_in_any_such_crisis_situation').dblclick();
            } else {
                await assessmentPage.riskManagement(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 7; index++) {
            const count = '0' + index;
            if (count == '02') {
                await page.locator('#td_02_There_is_no_sustainability_reporting').dblclick();
            } else {
                await assessmentPage.transparencyDisclosure(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 13; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.humanRights(count);
            }
            else {
                const count = index;
                await assessmentPage.humanRights(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 6; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.humanCapital(count);
            }
            else {
                const count = index;
                await assessmentPage.humanCapital(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 9; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.ohs(count);
            }
            else {
                const count = index;
                await assessmentPage.ohs(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 7; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.csr(count);
            }
            else {
                const count = index;
                await assessmentPage.csr(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 12; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.environmentManagement(count);
            }
            else {
                const count = index;
                await assessmentPage.environmentManagement(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 7; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.supplyChain(count);
            }
            else {
                const count = index;
                await assessmentPage.supplyChain(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 8; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.bioDiversity(count);
            }
            else {
                const count = index;
                await assessmentPage.bioDiversity(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.aspectNextButton();
        for (let index = 1; index < 12; index++) {
            if (index < 10) {
                const count = '0' + index;
                await assessmentPage.productResponsibility(count);
            }
            else {
                const count = index;
                await assessmentPage.productResponsibility(count);
            }
            await page.waitForTimeout(500); // Slower execution to ensure clicks register
        }
        await assessmentPage.save();
        await expect(assessmentPage.saveSuccessToast).toBeVisible();

        // Debug: Check submit button state before submission
        const isSubmitDisabled = await assessmentPage.submitButton.isDisabled();
        console.log(`DEBUG: Submit button disabled state before submit(): ${isSubmitDisabled}`);

        await assessmentPage.submit();
        await expect(assessmentPage.submitSuccessToast).toBeVisible();
        // Wait for the application's automatic redirect to dashboard and ensure it's loaded
        await page.waitForURL(/.*company_user\/dashboard/, { timeout: 15000, waitUntil: 'load' });
    });

    test('Step 4: Verify Dashboard After Submission', async () => {
        console.log('Starting Step 4: Verify Dashboard After Submission');
        const dashboardPage = new DashboardPage(page);
        // Ensure we are on the dashboard after the automatic redirect
        await page.waitForURL(/.*company_user\/dashboard/, { timeout: 10000 });

        // Verify Take Assessment is disabled
        const isTakeDisabled = await dashboardPage.isTakeAssessmentDisabled();
        expect(isTakeDisabled).toBe(true);

        // Verify View Assessment is enabled
        const isViewEnabled = await dashboardPage.isViewAssessmentEnabled();
        expect(isViewEnabled).toBe(true);
        console.log('Dashboard button states verified: Take Assessment disabled, View Assessment enabled.');
        await page.waitForTimeout(2000);
    });


});
