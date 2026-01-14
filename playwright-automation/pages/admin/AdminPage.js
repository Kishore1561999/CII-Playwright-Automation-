const BasePage = require('../BasePage');

class AdminPage extends BasePage {
    constructor(page) {
        super(page);

        // Navigation / Dashboard elements
        this.esgDiagnosticsLink = page.locator('a.menu-link[href="/esgadmin/company_users"]');

        // Common Table / Filter elements
        this.searchNameInput = page.locator('input#companyNameFilter');
        this.applyFilterButton = page.locator('#apply-filter');
        this.tableRows = page.locator('table tbody tr, [class*="user-row"]');

        // Approval elements
        this.confirmApproveButton = page.locator('#modalApprove button#approve_button');
        this.confirmAssignButton = page.locator('#modalAssign button#assign_button');
        this.successToast = page.locator('div.toast-message').filter({ hasText: /Company User request status has been updated successfully/i });

        // Analyst Assignment elements
        this.analystDropdown = page.locator('select, [class*="dropdown"], [class*="analyst"]');
        this.confirmAssignmentButton = page.locator('button:has-text("Confirm"), button:has-text("Submit"), [class*="confirm"]');
        this.assignmentSuccessMessage = page.locator('div.toast-message');

        // Deletion elements
        this.confirmDeleteButton = page.locator('#modalDelete button#delete_button');
        this.deleteSuccessToast = page.locator('div.toast-message').filter({ hasText: /Company User has been deleted successfully/i });
    }

    /**
     * Navigation methods
     */
    async navigateToCompanyUsers() {
        if (await this.esgDiagnosticsLink.isVisible()) {
            await this.esgDiagnosticsLink.click();
        } else {
            await this.page.goto('/esgadmin/company_users');
        }
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Navigated to Company Users / ESG Diagnostic page');
    }

    /**
     * Search helper
     */
    async searchCompany(companyName) {
        await this.searchNameInput.fill(companyName);
        await this.applyFilterButton.click();
        await this.page.waitForTimeout(2000); // Wait for filter results
        console.log(`✓ Searched for company: ${companyName}`);
    }

    /**
     * Row helper
     */
    async getCompanyRow(companyName) {
        const row = this.page.locator(`tr:has(strong:has-text("${companyName}"))`);
        await row.waitFor({ state: 'visible', timeout: 10000 });
        return row;
    }

    /**
     * Approval workflow
     */
    async approveCompany(companyName) {
        console.log(`Approving company: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        const approveBtn = row.locator('.approve_button');
        try {
            await approveBtn.waitFor({ state: 'visible', timeout: 5000 });
            await approveBtn.click();
            await this.confirmApproveButton.waitFor({ state: 'visible', timeout: 5000 });
            await this.confirmApproveButton.click();
            console.log(`✓ Clicked approve and confirm for: ${companyName}`);
        } catch (error) {
            const rowText = await row.innerText();
            if (rowText.toLowerCase().includes('approved')) {
                console.log(`ℹ Company ${companyName} is already approved.`);
            } else {
                throw new Error(`Failed to approve company ${companyName}: ${error.message}`);
            }
        }
    }

    /**
     * Analyst Assignment workflow
     */
    async assignAnalyst(companyName, ciiUserName) {
        console.log(`Assigning analyst ${ciiUserName} to company ${companyName}`);
        //await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);
        //Select company
        const checkbox = row.locator('input[type="checkbox"]');
        await checkbox.check();
        // 2. Wait for global analyst dropdown
        const userdropdown = this.page.locator('select#analyst_id');
        await userdropdown.waitFor({ state: 'visible', timeout: 5000 });
        // 3. Select analyst
        await userdropdown.selectOption({ label: ciiUserName });
        // 4. Assign
        const assignBtn = this.page.locator('#assign');
        await assignBtn.waitFor({ state: 'visible', timeout: 5000 });
        await assignBtn.click();
        // 5. Confirm modal
        await this.confirmAssignButton.click();
        await this.page.waitForTimeout(1000);

        const message = await this.assignmentSuccessMessage.first().textContent();
        if (message && message.toLowerCase().includes('success')) {
            console.log(`✓ Assignment successful: ${companyName} → ${ciiUserName}`);
            return true;
        }
        return false;
    }

    async verifyAssignmentSuccess(companyName) {
        await this.page.waitForLoadState('networkidle');
        try {
            await this.assignmentSuccessMessage.waitFor({ state: 'visible', timeout: 5000 });
            console.log(`✓ Assignment verified for: ${companyName}`);
            return true;
        } catch (e) {
            return false;
        }
    }

    /**
     * Deletion workflow
     */
    async deleteCompany(companyName) {
        console.log(`Deleting company: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        const actionDropdown = row.locator('.dropdown-toggle');
        await actionDropdown.click();

        const deleteBtn = row.locator('.delete_button');
        await deleteBtn.waitFor({ state: 'visible', timeout: 5000 });
        await deleteBtn.click();

        await this.confirmDeleteButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmDeleteButton.click();
        console.log(`✓ Deleted test company: ${companyName}`);
    }

    /**
     * Scorecard and Report methods
     */
    async generateScorecard(companyName) {
        console.log(`Generating scorecard for: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);
        await row.locator('.score_button').click();
        await this.page.locator('#generateScoreCard').waitFor({ state: 'visible', timeout: 5000 });
        await this.page.locator('#generateScoreCard').click();
        console.log('✓ Scorecard generated (clicked Yes)');
    }

    async clickGenerateTemplate(companyName) {
        console.log(`Clicking Generate Template for: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);
        const templateBtn = row.locator('[title="Generate Template"]');
        await templateBtn.waitFor({ state: 'visible', timeout: 5000 });

        // Remove disabled class if necessary, or just click if it becomes enabled
        await templateBtn.click();
        console.log('✓ Clicked Generate Template');
    }

    async uploadReport(companyName, filePath) {
        console.log(`Uploading report for: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        await row.locator('[title="Upload report"]').click();

        const modal = this.page.locator('#modalFileupload');
        await modal.waitFor({ state: 'visible', timeout: 5000 });

        await this.page.locator('input#fileUpload').setInputFiles(filePath);

        // The Upload button might be disabled until file is selected
        const uploadBtn = this.page.locator('#file-upload-admin-btn');
        await uploadBtn.waitFor({ state: 'visible', timeout: 5000 });
        await uploadBtn.click();

        console.log('✓ Report uploaded and Upload button clicked');
    }
}

module.exports = AdminPage;
