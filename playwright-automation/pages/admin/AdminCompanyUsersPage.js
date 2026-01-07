const BasePage = require('../BasePage');

class AdminCompanyUsersPage extends BasePage {
    constructor(page) {
        super(page);
        this.searchNameInput = page.locator('input#companyNameFilter');
        this.applyButton = page.locator('#apply-filter');
        this.approveButton = page.locator('.approve_button');
        this.confirmApproveButton = page.locator('#modalApprove button#approve_button');
        this.confirmDeleteButton = page.locator('#modalDelete button#delete_button');
        this.successToast = page.locator('div.toast-message', { hasText: /Company User request status has been updated successfully./i });
        this.deleteSuccessToast = page.locator('div.toast-message', { hasText: /Company User has been deleted successfully/i });
    }

    async approveCompany(companyName) {
        console.log(`Approving company: ${companyName}`);
        await this.searchNameInput.fill(companyName);
        await this.applyButton.click();

        // await this.page.waitForTimeout(3000); // Wait for filter results

        // Find the row containing the company name (using normalize-space for robustness)
        const row = this.page.locator(`xpath=//strong[contains(normalize-space(.), "${companyName}")]/ancestor::tr`);

        try {
            await row.waitFor({ timeout: 10000 });
            console.log(`Found row for company: ${companyName}`);
        } catch (e) {
            console.log(`Row for ${companyName} not found.`);
            throw new Error(`Failed to find row for company: ${companyName}`);
        }

        // Find the approve button within the row (it's a class .approve_button)
        const approveBtn = row.locator('.approve_button');

        // Wait for the button and check if it's visible
        try {
            await approveBtn.waitFor({ state: 'visible', timeout: 5000 });
            console.log(`Approve button found and visible for: ${companyName}`);
            await approveBtn.click();

            // Wait for confirmation button in modal and click it
            await this.confirmApproveButton.waitFor({ state: 'visible', timeout: 5000 });
            await this.confirmApproveButton.click();
            console.log(`Clicked approve and confirm for: ${companyName}`);
        } catch (error) {
            console.log(`Approve button or confirmation button not found/visible for: ${companyName}`);
            // Check if already approved
            const rowText = await row.innerText();
            if (rowText.toLowerCase().includes('approved')) {
                console.log(`Company ${companyName} appears to be already approved.`);
                return;
            }
            throw new Error(`Failed to approve company ${companyName}: Approve button not found or not visible.`);
        }
    }

    async deleteCompany(companyName) {
        console.log(`Deleting company: ${companyName}`);
        await this.searchNameInput.fill(companyName);
        await this.applyButton.click();
        await this.page.waitForTimeout(3000); // Wait for filter results

        const row = this.page.locator(`xpath=//strong[contains(normalize-space(.), "${companyName}")]/ancestor::tr`);

        try {
            await row.waitFor({ timeout: 10000 });
            console.log(`Found row for company deletion: ${companyName}`);
        } catch (e) {
            console.log(`Row for ${companyName} not found for deletion.`);
            throw new Error(`Failed to find row for deleting company: ${companyName}`);
        }

        const actionDropdown = row.locator('.dropdown-toggle');
        await actionDropdown.click();

        const deleteBtn = row.locator('.delete_button');
        await deleteBtn.waitFor({ state: 'visible', timeout: 5000 });
        await deleteBtn.click();

        await this.confirmDeleteButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmDeleteButton.click();
        console.log(`Confirmed deletion for: ${companyName}`);
    }
}

module.exports = AdminCompanyUsersPage;
