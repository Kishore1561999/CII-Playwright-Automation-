const { test, expect } = require('@playwright/test');
const LoginPage = require('../../pages/common/LoginPage');
const DashboardPage = require('../../pages/company_user/DashboardPage');
const AdminPage = require('../../pages/admin/AdminPage');
const ManagerPage = require('../../pages/manager/ManagerPage');
const AnalystDashboardPage = require('../../pages/analyst/AnalystDashboardPage');
const Env = require('../../utils/Env');

test.describe('Functional Login Flows', () => {
    test.setTimeout(60000);
    let loginPage;

    test.beforeEach(async ({ page }) => {
        loginPage = new LoginPage(page);
        await loginPage.navigate();
    });

    test('Admin Login', async ({ page }) => {
        await loginPage.login(Env.ADMIN_EMAIL, Env.ADMIN_PASSWORD);
        const adminPage = new AdminPage(page);
        await adminPage.verifyDashboardLoaded();
    });

    // Manager Login
    test('Manager Login', async ({ page }) => {
        await loginPage.login(Env.MANAGER_EMAIL, Env.MANAGER_PASSWORD);
        const managerPage = new ManagerPage(page);
        await managerPage.verifyDashboardLoaded();
    });

    test('Analyst Login', async ({ page }) => {
        await loginPage.login(Env.ANALYST_EMAIL, Env.ANALYST_PASSWORD);
        const analystPage = new AnalystDashboardPage(page);
        await analystPage.verifyDashboardLoaded();
    });
});

