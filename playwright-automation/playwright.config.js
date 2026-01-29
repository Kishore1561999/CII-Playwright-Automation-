// @ts-check
const { defineConfig, devices } = require('@playwright/test');
const dotenv = require('dotenv');

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
dotenv.config({ path: 'utils/.env', quiet: true });

/**
 * @see https://playwright.dev/docs/test-configuration
 */
module.exports = defineConfig({
    testDir: './tests',
    /* Run tests in files in parallel */
    fullyParallel: true,
    /* Fail the build on CI if you accidentally left test.only in the source code. */
    forbidOnly: !!process.env.CI,
    /* Retry on failures */
    retries: process.env.CI ? 1 : 0,
    /* Opt out of parallel tests on CI. */
    workers: 1,
    /* Reporter to use. See https://playwright.dev/docs/test-reporters */
    reporter: [
        ['html'],
        ['ortoni-report', {
            folder: 'ortoni-report',
            filename: 'index.html',
            title: 'CII Automation Report',
            authorName: 'Kishore RS',
            preferredTheme: 'light'
        }],
        ['allure-playwright', {
            detail: true,
            outputFolder: 'allure-results',
            suiteTitle: false
        }],
        ['json', { outputFile: 'result.json' }]
    ],
    /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
    use: {
        /* Base URL to use in actions like `await page.goto('/')`. */
        // baseURL: 'http://127.0.0.1:3000',
        baseURL: process.env.BASE_URL || 'https://devcii2.spritle.com',

        /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
        trace: 'on-first-retry',
        screenshot: 'only-on-failure',
        video: 'retain-on-failure',
        actionTimeout: 15000,
        headless: process.env.CI ? true : false,
        viewport: { width: 1920, height: 1080 },
        launchOptions: {
            args: ["--start-maximized"]
        }
    },

    /* Configure projects for major browsers */
    projects: [
        // {
        //     name: 'chromium',
        //     use: { ...devices['Desktop Chrome'] },
        // },
        {
            name: 'E2E_Flow',
            use: {
                browserName: 'chromium',
                viewport: { width: 1920, height: 1080 }
            },
            testMatch: [
                '**/tests/e2e/company_user/assessment.spec.js',
                '**/tests/e2e/company_user/peer_benchmarking.spec.js'
            ],
            fullyParallel: false,
        },
        {
            name: 'Functional_Tests',
            use: {
                browserName: 'chromium',
                viewport: { width: 1920, height: 1080 }
            },
            testMatch: [
                '**/tests/functional/**/*.spec.js'
            ],
            fullyParallel: true, // Functional tests can run parallel
        },

        // {
        //   name: 'firefox',
        //   use: { ...devices['Desktop Firefox'] },
        // },
        //
        // {
        //   name: 'webkit',
        //   use: { ...devices['Desktop Safari'] },
        // },
    ],
});
