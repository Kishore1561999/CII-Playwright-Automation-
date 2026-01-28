const { test, expect } = require('@playwright/test');
const RegistrationPage = require('../../../pages/company_user/RegistrationPage');
const AdminPage = require('../../../pages/admin/AdminPage');
const LoginPage = require('../../../pages/common/LoginPage');
const PeerBenchmarkingPage = require('../../../pages/company_user/PeerBenchmarkingPage');
const Env = require('../../../utils/Env');
const AnalystDashboardPage = require('../../../pages/analyst/AnalystDashboardPage');
const AnalystAssessmentReviewPage = require('../../../pages/analyst/AnalystAssessmentReviewPage');

// Run tests in serial mode to maintain workflow order
test.describe.configure({ mode: 'serial' });

test.describe('Peer Benchmarking Phase 2 Flow', () => {
    let sharedPage;
    let loginPage;
    let adminPage;
    let peerBenchmarkingPage;
    let analystDashboardPage;
    let analystAssessmentReviewPage;

    const timestamp = Date.now();
    const companyEmail = `pb_test_${timestamp}@example.com`;
    const companyName = `PB_Co_${timestamp}`;
    const password = 'Password@123';

    test.beforeAll(async ({ browser }) => {
        // Use a single page instance for the entire serial describe block
        sharedPage = await browser.newPage();

        // Initialize page objects once with the shared page instance
        loginPage = new LoginPage(sharedPage);
        adminPage = new AdminPage(sharedPage);
        peerBenchmarkingPage = new PeerBenchmarkingPage(sharedPage);
        analystDashboardPage = new AnalystDashboardPage(sharedPage);
        analystAssessmentReviewPage = new AnalystAssessmentReviewPage(sharedPage);
    });

    test.afterAll(async () => {
        if (sharedPage) {
            await sharedPage.close();
        }
    });

    test('Step 1: Company Registration (Basic Subscription)', async () => {
        test.setTimeout(120000); // 2 mins for registration
        const registrationPage = new RegistrationPage(sharedPage);

        await registrationPage.navigate('/users/sign_up');

        const companyData = {
            name: companyName,
            sector: 'Automobiles & Auto Components',
            scale: 'Medium',
            description: 'PB Phase 2 Test',
            gst: '07AAATC0188R1ZB',
            logoPath: 'path/Golden Bridge.png',
            address: '123 PB St',
            country: 'IN',
            state: 'DL',
            city: 'New Delhi',
            zip: '110001',
            pan: 'AAATC0188R'
        };
        const contactData = {
            name: 'PB User',
            email: companyEmail,
            designation: 'Manager',
            contact: '9876543210'
        };

        await registrationPage.registerAccountBasic(companyData, contactData, password);
        console.log(`Registered company: ${companyName}`);
        await expect(sharedPage.getByText(/Your registration form has been submitted successfully/i)).toBeVisible();
    });

    test('Step 2: Admin Approval (Basic Subscription)', async () => {
        test.setTimeout(90000); // 1.5 mins
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

        // Navigate to Basic Subscription
        await adminPage.navigateToBasicSubscription();

        // Search and Approve using the new method
        await adminPage.approveBasicSubscription(companyName);

        await loginPage.logout();
    });

    test('Step 3: Company User Peer Benchmarking Flow', async () => {
        test.setTimeout(600000); // Increase timeout to 10 minutes for long analytics process
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(companyEmail, password);

        // Handle User Guide Popup
        await peerBenchmarkingPage.handleUserGuideModal();

        // Consent
        await peerBenchmarkingPage.acceptConsent();

        // Click Provide & Edit Data
        await peerBenchmarkingPage.clickProvideData();

        // Confirm Sector
        await peerBenchmarkingPage.confirmSector();

        // Verify Navigation
        await expect(sharedPage).toHaveURL(/.*company_user\/peer_benchmark_assessment/);
        console.log('✓ Verified navigation to peer_benchmark_assessment');
        await sharedPage.waitForTimeout(1000);

        for (let index = 1; index < 36; index++) {
            const count = index < 10 ? '0' + index : index.toString();
            if (['06', '07', '09', '10', '12', '14', '15', '19', '26', '33', '35'].includes(count)) {
                await peerBenchmarkingPage.fillPeerBenchmarkQuestions2(count);
            } else if (count === '05') {
                await peerBenchmarkingPage.fillPeerBenchmarkQuestions3(count);
            } else {
                await peerBenchmarkingPage.fillPeerBenchmarkQuestions(count);
            }
            await sharedPage.waitForTimeout(500); // Small delay after each question

            if (['10', '20', '30'].includes(count)) {
                await peerBenchmarkingPage.nextButton();
                await sharedPage.waitForTimeout(1000);
            }
        }

        await peerBenchmarkingPage.saveButton();
        await sharedPage.waitForTimeout(1000);
        await peerBenchmarkingPage.runAnalytics();
        await sharedPage.waitForTimeout(1000);

        // Wait for analytics to complete and navigate to dashboard (can take > 2 mins)
        console.log('Waiting for analytics to complete...');
        await expect(sharedPage).toHaveURL(/.*company_user\/peer_benchmarking/, { timeout: 300000 });
        console.log('✓ Analytics completed and navigated to dashboard');
        await sharedPage.waitForTimeout(1000);
        await peerBenchmarkingPage.closeSuccessMessage();
        await sharedPage.waitForTimeout(1000);

        await loginPage.logout();
    });

    test('Step 4: Admin Data Management and Assignment', async () => {
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);

        // PB Data Management
        await adminPage.navigateToPBDataManagement();
        await sharedPage.waitForTimeout(1000);
        await adminPage.approvePBData(companyName);
        await sharedPage.waitForTimeout(1000);

        // CII Data Collection
        await adminPage.navigateToCIIDataCollection();
        await sharedPage.waitForTimeout(1000);
        await adminPage.searchByCompany(companyName);
        await sharedPage.waitForTimeout(1000);
        await adminPage.assignAnalyst(companyName, 'Kishore Analyst');
        await sharedPage.waitForTimeout(1000);

        await loginPage.logout();
    });

    test('Step 5: Analyst Data Collection Submission', async () => {
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ANALYST_EMAIL, Env.ANALYST_PASSWORD);

        // Check CII Data Collection
        await analystDashboardPage.navigateToCIIDataCollection();
        await sharedPage.waitForTimeout(1000);
        await analystDashboardPage.searchCompany(companyName);
        await sharedPage.waitForTimeout(1000);
        await analystDashboardPage.clickEditAssessment(companyName);
        await sharedPage.waitForTimeout(1000);

        // Submit Assessment
        await analystAssessmentReviewPage.clickSubmit();
        await sharedPage.waitForTimeout(1000);
        await analystAssessmentReviewPage.handleConfirmationModal();
        await sharedPage.waitForTimeout(1000);

        await loginPage.logout();
    });

    test('Step 6: Admin Data Deletion (Cleanup)', async () => {
        await loginPage.navigate('/users/sign_in');
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        await sharedPage.waitForTimeout(1000);

        // 1. Navigate to PB Data Management -> CII Data Collection
        await adminPage.navigateToPBDataManagement();
        await sharedPage.waitForTimeout(1000);
        await adminPage.navigateToCIIDataCollection();
        await sharedPage.waitForTimeout(1000);

        // 2. Search Company and Check Status "Submitted"
        await adminPage.verifyCiiStatus(companyName, 'Submitted');
        await sharedPage.waitForTimeout(1000);

        // 3. Delete directly on CII Data Collection page
        await adminPage.deleteFromCIIDataCollection(companyName);
        await sharedPage.waitForTimeout(1000);

        // 4. Navigate to Basic Subscription
        await adminPage.navigateToBasicSubscription();
        await sharedPage.waitForTimeout(1000);

        // 5. Search and Delete Basic Subscription
        await adminPage.deleteBasicSubscription(companyName);
        await sharedPage.waitForTimeout(1000);

        await loginPage.logout();
    });
});