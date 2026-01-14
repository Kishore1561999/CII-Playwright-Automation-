const { test, expect } = require('@playwright/test');
const path = require('path');
const RegistrationPage = require('../../../pages/company_user/RegistrationPage');
const AdminPage = require('../../../pages/admin/AdminPage');
const LoginPage = require('../../../pages/common/LoginPage');
const DashboardPage = require('../../../pages/company_user/DashboardPage');
const AssessmentPage = require('../../../pages/company_user/AssessmentPage');
const AnalystDashboardPage = require('../../../pages/analyst/AnalystDashboardPage');
const AnalystAssessmentReviewPage = require('../../../pages/analyst/AnalystAssessmentReviewPage');
const Env = require('../../../utils/Env');
const TestData = require('../../../utils/TestData');

// Run tests in serial mode to maintain workflow order
test.describe.configure({ mode: 'serial' });

test.describe('Company User Assessment Workflow', () => {
    let page;
    let loginPage;
    let adminPage;
    let analystDashboardPage;
    let analystReviewPage;

    const timestamp = Date.now();
    const companyEmail = `e2e_user_${timestamp}@example.com`;
    const companyName = `E2E_Company_${timestamp}`;
    const password = 'Password@123';

    test.beforeAll(async ({ browser }) => {
        page = await browser.newPage();
        loginPage = new LoginPage(page);
        adminPage = new AdminPage(page);
        analystDashboardPage = new AnalystDashboardPage(page);
        analystReviewPage = new AnalystAssessmentReviewPage(page);
    });

    test.afterAll(async () => {
        console.log('Assessment workflow completed. Cleanup/deletion will be handled by separate delete_user.spec.js');
        // Store test data in environment and file for post-assessment and delete flows
        process.env.TEST_COMPANY_NAME = companyName;
        process.env.TEST_COMPANY_EMAIL = companyEmail;
        TestData.save({ companyName, companyEmail });

        // Close page connection (not deleted yet)
        await page.close();
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
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        await expect(page).toHaveURL(/.*esgadmin\/company_users/);
        await adminPage.navigateToCompanyUsers();
        await adminPage.approveCompany(companyName);
        await expect(adminPage.successToast).toBeVisible();
        await page.waitForTimeout(2000);

        // Logout Admin
        await loginPage.logout();
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
        await page.waitForURL(/.*company_user\/dashboard/, { timeout: 10000 });

        const isTakeDisabled = await dashboardPage.isTakeAssessmentDisabled();
        expect(isTakeDisabled).toBe(true);

        const isViewEnabled = await dashboardPage.isViewAssessmentEnabled();
        expect(isViewEnabled).toBe(true);
        console.log('Dashboard button states verified.');

        // Wait for potential background processing
        await page.waitForTimeout(2000);
        await loginPage.logout();
    });

    // ==========================================
    // ANALYST REVIEW FLOW (Merged from post_assessment_review.spec.js)
    // ==========================================

    test('Step 5: Admin Login and Assign Analyst', async () => {
        console.log('\n📋 STEP 5: Admin Assignment Workflow');

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        await expect(page).toHaveURL(/.*esgadmin\/company_users/);

        await adminPage.navigateToCompanyUsers();
        await adminPage.searchCompany(companyName);

        const ciiUserName = 'Kishore Analyst';
        const assignmentSuccess = await adminPage.assignAnalyst(companyName, ciiUserName);
        expect(assignmentSuccess).toBe(true);

        await loginPage.logout();
    });

    test('Step 6: Analyst Login and Review Assessment', async () => {
        console.log('\n📋 STEP 6: Analyst Review Workflow');
        test.setTimeout(120000);

        const analystEmail = 'kishore.r+analyst@spritle.com';
        const analystPassword = 'Spritle123@';
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(analystEmail, analystPassword);
        // verify the Analyst login success
        await expect(page).toHaveURL(/.*analyst\/dashboard/);

        await analystDashboardPage.navigateToAnalystDashboard();
        await analystDashboardPage.clickViewAssessment(companyName);

        // --- NEW FLOW BASED ON USER FEEDBACK ---
        await analystReviewPage.verifyAssessmentPageLoaded();
        await analystReviewPage.clickEdit();
        await analystReviewPage.fillComments('Unified E2E verification comment for CII.');
        await analystReviewPage.clickUpdate();
        await analystReviewPage.clickSubmit();
        await analystReviewPage.handleConfirmationModal();
        await analystReviewPage.verifySubmissionSuccess();

        await loginPage.logout();
    });

    test('Step 7: Admin Login and complete Review Assessment', async () => {
        console.log('\n📋 STEP 7: Admin Review Workflow');
        test.setTimeout(180000);

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        // verify the Admin login success
        await expect(page).toHaveURL(/.*esgadmin\/company_users/);

        await adminPage.navigateToCompanyUsers();
        await adminPage.searchCompany(companyName);

        const ciiUserName = 'Kishore admin';
        const assignmentSuccess = await adminPage.assignAnalyst(companyName, ciiUserName);
        expect(assignmentSuccess).toBe(true);

        await analystDashboardPage.clickViewAssessment(companyName);

        await analystReviewPage.verifyAssessmentPageLoaded();
        await analystReviewPage.clickEdit();
        await analystReviewPage.fillComments('Unified E2E verification comment for CII.');
        await analystReviewPage.clickUpdate();
        await analystReviewPage.clickSubmit();
        await analystReviewPage.handleConfirmationModal();
        await analystReviewPage.verifySubmissionSuccess();

        // --- SCORECARD & REPORT FLOW ---
        await adminPage.navigateToCompanyUsers();
        await adminPage.generateScorecard(companyName);
        await adminPage.clickGenerateTemplate(companyName);

        const reportPath = path.resolve(__dirname, '../../../utils/sample.pdf');
        await adminPage.uploadReport(companyName, reportPath);

        await loginPage.logout();
    });

    test('Step 8: Company User Login and Download Scorecard/Report', async () => {
        console.log('\n📋 STEP 8: User Download Workflow');
        test.setTimeout(120000);

        const dashboardPage = new DashboardPage(page);

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(companyEmail, password);

        // Ensure we are on dashboard
        await expect(page).toHaveURL(/.*dashboard/);

        // Download activities
        //await dashboardPage.downloadScorecard();
        await dashboardPage.downloadReport();

        await loginPage.logout();
    });

    // ==========================================
    // CLEANUP FLOW (Merged from delete_user.spec.js)
    // ==========================================

    test('Step 9: Admin Login and Delete Test Company', async () => {
        console.log('\n📋 STEP 9: Cleanup Workflow');

        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

        await adminPage.navigateToCompanyUsers();
        await adminPage.deleteCompany(companyName);

        console.log(`✓ Deleted test company: ${companyName}`);
        await loginPage.logout();
    });
});
