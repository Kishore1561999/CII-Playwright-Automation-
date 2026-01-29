const { expect } = require('@playwright/test');
const BasePage = require('../BasePage');

class AdminPage extends BasePage {
    constructor(page) {
        super(page);

        // Navigation / Dashboard elements
        // Updated to support both Admin (/esgadmin/) and Manager (/manager/) paths
        this.esgDiagnosticsLink = page.locator('a.menu-link[href*="/esgadmin/company_users"], a.menu-link[href*="/manager/company_users"]');

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

        // New Admin Functionality Selectors
        // Basic Subscription
        this.basicSubLink = page.locator('a[href*="basic_subscription"]');

        // Updated Locators based on user HTML (with fallbacks for legacy pages)
        this.yearDropdown = page.locator('select#year-picker, select#year_id');
        this.sectorFilterInput = page.locator('input#sectorFilter'); // For clicking to open custom dropdown
        this.sectorDropdownContainer = page.locator('.filter-container'); // Container for custom checkboxes

        // For legacy Sector dropdown (if some pages still use simple select)
        this.legacySectorDropdown = page.locator('select#sector_id');

        this.searchNameInput = page.locator('input#companyNameFilter'); // Confirmed ID
        this.analystFilterDropdown = page.locator('select#analyst_search'); // New ID from user HTML

        // Prioritize #apply-filter as it is explicitly in the HTML
        this.applyFilterBtn = page.locator('#apply-filter, button#apply-filter, button:has-text("Apply")');

        // PB Data Management
        this.pbDataLink = page.locator('a[href*="/service/peer_benchmark"]');

        // CII Data Collection - supports Admin, Manager, and Analyst paths
        this.ciiDataLink = page.locator('a[href*="/service/data_collection?subscription_type=premium"], a[href*="/analyst/data_collection"]');
        this.analystNameInput = page.locator('input#analyst_name'); // Keeping as fallback or for other pages if needed

        // User Management
        this.userMgmtLink = page.locator('a[href*="/esgadmin/users"]'); // Adjust based on actual link
        this.createUserBtn = page.locator('a[href*="/esgadmin/users/new"], button:has-text("Create New CII User")');

        // User Form Locators
        this.userFirstNameInput = page.locator('input#user_first_name');
        this.userLastNameInput = page.locator('input#user_last_name');
        this.userEmailInput = page.locator('input#user_email');
        this.userMobileInput = page.locator('input#user_mobile');
        this.userRoleDropdown = page.locator('select#user_role_id');
        this.userPasswordInput = page.locator('input#user_password');
        this.userConfirmPasswordInput = page.locator('input#user_password_confirmation');
        this.createUserSubmitBtn = page.locator('input[type="submit"][value="Create User"]');
        this.updateUserSubmitBtn = page.locator('input[type="submit"][value="Update User"]');

        // ... add other user inputs as needed dynamically or in methods

    }

    async verifyDashboardLoaded() {
        await expect(this.page).toHaveURL(/.*esgadmin\/company_users/);
    }
    /**
 * ESG Diagnostic
 */
    async navigateToESGDiagnostic() {
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        // Ensure the link is visible and scrolled into view
        await this.esgDiagnosticsLink.scrollIntoViewIfNeeded();

        try {
            await this.esgDiagnosticsLink.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`\u26A0 Standard click failed on ESG Diagnostic link: ${error.message}. Attempting JS click.`);
            await this.esgDiagnosticsLink.dispatchEvent('click');
        }

        await this.page.waitForLoadState('networkidle');
        await this.page.waitForTimeout(2000);
        console.log('\u2713 Admin: Navigated to ESG Diagnostic');
    }

    async filterByYear(year) {
        if (year) {
            await this.yearDropdown.selectOption(year);
            await this.applyFilterBtn.click();
            await this.page.waitForLoadState('networkidle');
            console.log(`✓ Admin: Filtered by Year: ${year}`);
        }
    }

    async filterBySector(sectorName) {
        if (sectorName) {
            if (await this.sectorFilterInput.isVisible()) {
                // New Custom Dropdown logic
                await this.sectorFilterInput.click();
                await this.sectorDropdownContainer.waitFor({ state: 'visible' });
                await this.page.locator(`label.form-check-label:has-text("${sectorName}")`).click();
            } else if (await this.legacySectorDropdown.isVisible()) {
                // Legacy Simple Select logic
                await this.legacySectorDropdown.selectOption({ label: sectorName });
                console.log(`✓ Admin: used legacy sector dropdown`);
            } else {
                throw new Error('No suitable sector filter locator found');
            }

            // Click apply
            await this.applyFilterBtn.click();
            await this.page.waitForLoadState('networkidle');
            console.log(`✓ Admin: Filtered by Sector: ${sectorName}`);
        }
    }

    async searchByCompany(companyName) {
        if (companyName) {
            await this.searchNameInput.fill(companyName);
            await this.applyFilterBtn.click();
            await this.page.waitForLoadState('networkidle');
            console.log(`✓ Admin: Searched for Company: ${companyName}`);
        }
    }

    async searchESGDiagnostic(companyName, sector, year) {
        // Keeping this for backward compatibility if needed, but updating to use new methods if logic overlaps, 
        // or just updating implementation to match new locators.
        // For this task, we will just use the new specific methods in the test.
        // But let's fix this one too to use new locators just in case.
        if (companyName) await this.searchNameInput.fill(companyName);
        if (sector) {
            await this.sectorFilterInput.click();
            await this.sectorDropdownContainer.waitFor({ state: 'visible' });
            await this.page.locator(`label.form-check-label:has-text("${sector}")`).click();
        }
        if (year) await this.yearDropdown.selectOption(year);

        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Searched ESG Diagnostic`);
    }

    /**
     * Basic Subscription
     */
    async navigateToBasicSubscription() {
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        // Ensure the link is visible and scrolled into view
        await this.basicSubLink.scrollIntoViewIfNeeded();

        try {
            // Attempt normal click first
            await this.basicSubLink.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`\u26A0 Standard click failed on Basic Subscription link: ${error.message}. Attempting JS click.`);
            // Fallback to JS click if viewport issues persist
            await this.basicSubLink.dispatchEvent('click');
        }

        await this.page.waitForLoadState('networkidle');
        await this.page.waitForTimeout(2000);
        console.log('\u2713 Admin: Navigated to Basic Subscription');
    }

    async searchBasicSubscription(sector, year) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Searched Basic Sub: Sector=${sector}, Year=${year}`);
    }

    async approveBasicSubscription(companyName) {
        console.log(`✓ Admin: Approving Basic Subscription for: ${companyName}`);
        await this.searchByCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        const approveBtn = row.locator('.approve_button');
        await approveBtn.waitFor({ state: 'visible', timeout: 5000 });
        await approveBtn.click();

        // Specific modal for basic subscription
        const modal = this.page.locator('#modalbasicApprove');
        await modal.waitFor({ state: 'visible', timeout: 5000 });
        const confirmBtn = modal.locator('#approve_basic_button');
        await confirmBtn.click();

        // Wait for modal and backdrop to disappear to avoid intercepting clicks
        await modal.waitFor({ state: 'hidden', timeout: 10000 });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Approved Basic Subscription for: ${companyName}`);
    }

    /**
     * PB Data Management
     */
    async navigateToPBDataManagement() {
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        // Ensure the link is visible and scrolled into view
        await this.pbDataLink.scrollIntoViewIfNeeded();

        try {
            await this.pbDataLink.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`\u26A0 Standard click failed on PB Data Management link: ${error.message}. Attempting JS click.`);
            await this.pbDataLink.dispatchEvent('click');
        }

        await this.applyFilterBtn.first().waitFor({ state: 'visible', timeout: 30000 });
        await this.page.waitForTimeout(2000);
        console.log('\u2713 Admin: Navigated to PB Data Management');
    }

    async approvePBData(companyName) {
        console.log(`✓ Admin: Approving PB Data for: ${companyName}`);
        await this.searchByCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        const approveBtn = row.locator('.approve_button');
        await approveBtn.waitFor({ state: 'visible', timeout: 5000 });
        await approveBtn.click();

        // Specific modal for PB Data
        const confirmBtn = this.page.locator('#approve_service_button');
        await confirmBtn.waitFor({ state: 'visible', timeout: 5000 });
        await confirmBtn.click();

        // Wait for any active modal or backdrop to disappear
        await this.page.locator('.modal.show').waitFor({ state: 'hidden', timeout: 10000 }).catch(() => { });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Approved PB Data for: ${companyName}`);
    }

    async searchPBData(sector, year) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Searched PB Data: Sector=${sector}, Year=${year}`);
    }

    /**
     * CII Data Collection
     */
    async navigateToCIIDataCollection() {
        // CII Data Collection is nested under PB Data Management
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        const pbLink = this.pbDataLink.first();
        const ciiLink = this.ciiDataLink.first();

        // Check if sub-menu is already visible
        if (await ciiLink.isVisible()) {
            console.log('CII Data link is visible, clicking directly.');
            await ciiLink.scrollIntoViewIfNeeded();
            try {
                // Use force: true to bypass any minor UI obstructions or lingering invisible elements
                await ciiLink.click({ force: true, timeout: 5000 });
            } catch (error) {
                console.warn(`⚠ Standard click failed on CII Data link: ${error.message}. Attempting JS click.`);
                await ciiLink.dispatchEvent('click');
            }
        } else {
            // If not visible, click PB Data menu to expand
            console.log('CII Data link hidden, clicking PB Data Management first.');
            await pbLink.scrollIntoViewIfNeeded();
            try {
                await pbLink.click({ force: true, timeout: 5000 });
            } catch (error) {
                console.warn(`⚠ Standard click failed on PB Data link: ${error.message}. Attempting JS click.`);
                await pbLink.dispatchEvent('click');
            }
            await ciiLink.waitFor({ state: 'visible', timeout: 10000 });
            await ciiLink.scrollIntoViewIfNeeded();
            try {
                await ciiLink.click({ force: true, timeout: 5000 });
            } catch (error) {
                console.warn(`⚠ Standard click failed on CII Data link fallback: ${error.message}. Attempting JS click.`);
                await ciiLink.dispatchEvent('click');
            }
        }

        // Wait for the filter button on the target page to ensure navigation is complete
        await this.applyFilterBtn.first().waitFor({ state: 'visible', timeout: 30000 });
        await this.page.waitForTimeout(2000);
        console.log('✓ Admin: Navigated to CII Data Collection');
    }

    async searchCIIData(sector, year, analystName) {
        if (sector) await this.selectOption('select#sector_id', sector);
        if (year) await this.selectOption('select#year_id', year);
        if (analystName) await this.fillText('input#analyst_name', analystName);
        await this.applyFilterBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Searched CII Data: Sector=${sector}, Year=${year}, Analyst=${analystName}`);
    }

    async verifyCiiStatus(companyName, expectedStatus) {
        console.log(`✓ Admin: Verifying status for ${companyName}`);
        await this.searchByCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        // Search for the specific span or text in the row
        // User snippet: <td class="text-center"><span style="color:#E59700">Submitted</span></td>
        const statusLocator = row.locator('td.text-center span').filter({ hasText: expectedStatus });
        await expect(statusLocator.first()).toBeVisible();
        console.log(`✓ Status verified: ${expectedStatus}`);
    }

    async deleteFromCIIDataCollection(companyName) {
        console.log(`✓ Admin: Deleting from CII Data Collection: ${companyName}`);
        const row = await this.getCompanyRow(companyName);

        // Click Delete icon from user snippet
        const deleteIcon = row.locator('span[title="Delete"]');
        await deleteIcon.waitFor({ state: 'visible', timeout: 5000 });
        await deleteIcon.click();

        // Confirm Yes on the specific #confirmDeleteButton from user snippet
        const confirmBtn = this.page.locator('button#confirmDeleteButton');
        await confirmBtn.waitFor({ state: 'visible', timeout: 5000 });
        await confirmBtn.click();

        // Wait for modal and possible success toast
        await this.page.locator('.modal.show').waitFor({ state: 'hidden', timeout: 10000 }).catch(() => { });
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Deleted successfully on CII Data Collection page`);
    }

    async deleteBasicSubscription(companyName) {
        console.log(`✓ Admin: Deleting Basic Subscription for: ${companyName}`);
        await this.searchByCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        // Direct delete button based on snippet
        const deleteBtn = row.locator('.delete_button, :text("Delete")').first();
        await deleteBtn.waitFor({ state: 'visible', timeout: 5000 });
        await deleteBtn.click();

        // Confirm modal
        const modal = this.page.locator('#modalDelete');
        await this.confirmDeleteButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmDeleteButton.click();

        // Wait for modal cleanup
        await modal.waitFor({ state: 'hidden', timeout: 10000 });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Deleted Basic Subscription for: ${companyName}`);
    }

    /**
     * User Management
     */
    async navigateToUserManagement() {
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });
        await this.userMgmtLink.scrollIntoViewIfNeeded();
        try {
            await this.userMgmtLink.click({ force: true, timeout: 5000 });
        } catch (error) {
            console.warn(`⚠ Standard click failed on User Management link: ${error.message}. Attempting JS click.`);
            await this.userMgmtLink.dispatchEvent('click');
        }
        await this.page.waitForLoadState('networkidle');
        await this.page.waitForTimeout(2000);
        console.log('✓ Admin: Navigated to User Management');
    }

    async createUser(firstName, lastName, email, mobile, roleValue, password) {
        await this.createUserBtn.click();
        await this.page.waitForLoadState('networkidle');

        await this.userFirstNameInput.fill(firstName);
        await this.userLastNameInput.fill(lastName);
        await this.userEmailInput.fill(email);
        await this.userMobileInput.fill(mobile);

        if (roleValue) await this.userRoleDropdown.selectOption(roleValue); // "1" for Admin

        await this.userPasswordInput.fill(password);
        await this.userConfirmPasswordInput.fill(password);

        await this.createUserSubmitBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Created user: ${email}`);
    }

    async editUser(email, newFirstName, newLastName) {
        console.log(`✓ Admin: Editing user: ${email}`);

        // Find row by email
        // Note: Assuming email is visible in the row. If not, might need to search first if a search box exists.
        // Based on user request, user just "clicks menu option".
        // Let's assume we can locate the row by text.

        const row = this.page.locator('tr').filter({ hasText: email });

        // Click dropdown toggle in that row
        const dropdownToggle = row.locator('.dropdown-toggle');
        await dropdownToggle.click();

        // Click Edit
        const editLink = row.locator('a[href*="/edit"]');
        await editLink.click();
        await this.page.waitForLoadState('networkidle');

        // Update fields
        if (newFirstName) await this.userFirstNameInput.fill(newFirstName);
        if (newLastName) await this.userLastNameInput.fill(newLastName);

        await this.updateUserSubmitBtn.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Get updated user: ${email}`);
    }

    async deleteUserMgmt(email) {
        console.log(`✓ Admin: Deleting user: ${email}`);
        const row = this.page.locator('tr').filter({ hasText: email });

        // Click dropdown toggle
        const dropdownToggle = row.locator('.dropdown-toggle');
        await dropdownToggle.click();

        // Click Delete
        const deleteLink = row.locator('a.delete_button');
        await deleteLink.click();

        // Confirm Modal
        const modal = this.page.locator('#modalDelete');
        await modal.waitFor({ state: 'visible' });
        await modal.locator('button#delete_button').click();

        // Wait for modal cleanup
        await modal.waitFor({ state: 'hidden', timeout: 10000 });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Deleted user: ${email}`);
    }

    /**
     * Navigation methods
     */
    async navigateToCompanyUsers() {
        // Ensure any lingering modals or backdrops are cleared first
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });
        await this.esgDiagnosticsLink.scrollIntoViewIfNeeded();
        if (await this.esgDiagnosticsLink.isVisible()) {
            try {
                await this.esgDiagnosticsLink.click({ force: true, timeout: 5000 });
            } catch (error) {
                console.warn(`⚠ Standard click failed on Company Users link: ${error.message}. Attempting JS click.`);
                await this.esgDiagnosticsLink.dispatchEvent('click');
            }
        } else {
            await this.page.goto('/esgadmin/company_users');
        }
        await this.page.waitForLoadState('networkidle');
        await this.page.waitForTimeout(2000);
        console.log('✓ Admin: Navigated to Company Users / ESG Diagnostic page');
    }

    /**
     * Search helper
     */
    async searchCompany(companyName) {
        await this.searchNameInput.fill(companyName);
        await this.applyFilterButton.click();
        await this.page.waitForLoadState('networkidle');
        console.log(`✓ Admin: Searched for company: ${companyName}`);
    }

    /**
     * Row helper
     */
    async getCompanyRow(companyName) {
        // Scope to main table rows and take the first match to avoid strict mode violation 
        // with hidden/sidebar elements (like #company-my-list)
        const row = this.page.locator('table:not(#company-my-list) tbody tr').filter({ hasText: companyName }).first();
        await row.waitFor({ state: 'visible', timeout: 10000 });
        return row;
    }

    /**
     * Approval workflow
     */
    async approveCompany(companyName) {
        console.log(`✓ Admin: Approving company: ${companyName}`);
        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);

        const approveBtn = row.locator('.approve_button');
        try {
            await approveBtn.waitFor({ state: 'visible', timeout: 5000 });
            await approveBtn.click();
            await this.confirmApproveButton.waitFor({ state: 'visible', timeout: 5000 });
            await this.confirmApproveButton.click();

            // Wait for success toast to ensure approval is processed
            try {
                await this.successToast.waitFor({ state: 'visible', timeout: 10000 });
                console.log(`✓ Approval confirmed for: ${companyName}`);
                // Give a moment for backend processing
                await this.page.waitForTimeout(2000);
            } catch (toastError) {
                console.log(`⚠ Success toast not visible, but approval may have succeeded for: ${companyName}`);
            }

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
        console.log(`✓ Admin: Assigning analyst ${ciiUserName} to company ${companyName}`);
        //await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);
        //Select company
        const checkbox = row.locator('input[type="checkbox"]');
        await checkbox.waitFor({ state: 'visible', timeout: 5000 });
        await checkbox.scrollIntoViewIfNeeded();
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
        const modal = this.page.locator('#modalAssign');
        await this.confirmAssignButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmAssignButton.click();

        // Wait for modal cleanup
        await modal.waitFor({ state: 'hidden', timeout: 10000 });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');

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

        const modal = this.page.locator('#modalDelete');
        await this.confirmDeleteButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmDeleteButton.click();

        // Wait for modal cleanup
        await modal.waitFor({ state: 'hidden', timeout: 10000 });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

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

        // Wait for modal cleanup to avoid blocking next actions
        const modal = this.page.locator('#modalScore');
        await modal.waitFor({ state: 'hidden', timeout: 10000 }).catch(() => { });
        await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

        await this.page.waitForLoadState('networkidle');
        console.log('✓ Scorecard generated (clicked Yes)');
    }

    async clickGenerateTemplate(companyName) {
        console.log(`Clicking Generate Template for: ${companyName}`);

        // Ensure all modals and backdrops are gone before searching
        await this.page.locator('.modal.show, .modal-backdrop').waitFor({ state: 'hidden', timeout: 10000 }).catch(() => { });

        await this.searchCompany(companyName);
        const row = await this.getCompanyRow(companyName);
        const templateBtn = row.locator('[title="Generate Template"]');

        await templateBtn.waitFor({ state: 'visible', timeout: 10000 });

        // If button has 'disabled' class, wait for it to be enabled or try to force it if it's a persistent state
        try {
            await expect(templateBtn).not.toHaveClass(/.*disabled.*/, { timeout: 10000 });
        } catch (e) {
            console.warn('⚠ Template button still has disabled class. Status might not have updated. Attempting to force click.');
        }

        // Use force: true to bypass any lingering invisible backdrops that Playwright thinks are intercepting
        await templateBtn.click({ force: true });
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
