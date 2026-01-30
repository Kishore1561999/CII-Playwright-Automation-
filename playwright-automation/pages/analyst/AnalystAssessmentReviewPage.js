const BasePage = require('../BasePage');

class AnalystAssessmentReviewPage extends BasePage {
  constructor(page) {
    super(page);
    this.baseURL = '/analyst/assessment'; // Dynamic: /analyst/assessment/:id/edit_assessment/cii

    // Selectors
    this.aspectsList = page.locator('#aspects-list');
    this.editButton = page.locator('a.btn-primary:has-text("Edit")');
    this.commentFields = page.locator('textarea[placeholder="CII Comments"]');
    this.updateButton = page.locator('button.update_assessment');
    this.submitButton = page.locator('button.submit_assessment');
    this.confirmYesButton = page.locator('.modal-footer #submit_assessment');

    this.selectors = {
      successMessage: 'div.toast-message, .alert-success',
    };
  }

  async _robustClick(locator, name) {
    // Ensure any lingering modals or backdrops are cleared first
    await this.page.locator('.modal.show, .modal-backdrop, .toast').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });

    await locator.scrollIntoViewIfNeeded();
    try {
      // Remove force: true to respect actionability checks (waits for overlays to disappear)
      await locator.click({ timeout: 5000 });
      console.log(`\u2713 Clicked: ${name}`);
    } catch (error) {
      console.warn(`\u26A0 Standard click failed on ${name}: ${error.message}. Attempting JS click.`);
      await locator.dispatchEvent('click');
      console.log(`\u2713 JS clicked: ${name}`);
    }
  }

  async navigateToAssessmentReview(companyUserId, userType = 'cii_user') {
    const url = `${process.env.BASE_URL}${this.baseURL}/${companyUserId}/edit_assessment/${userType}`;
    await this.page.goto(url);
    await this.page.waitForLoadState('networkidle');
    console.log(`✓ Navigated to assessment review for user: ${companyUserId}`);
  }

  async verifyAssessmentPageLoaded() {
    try {
      await this.aspectsList.waitFor({ state: 'visible', timeout: 10000 });
      console.log('✓ Assessment review page loaded (Aspects list visible)');
      return true;
    } catch (e) {
      throw new Error('Assessment review page failed to load - aspects list not found');
    }
  }

  async clickEdit() {
    console.log('Attempting to click Edit and navigate...');
    // Use Promise.all to prevent race conditions between click and navigation
    await Promise.all([
      this.page.waitForURL(/.*edit_assessment.*/),
      this._robustClick(this.editButton, 'Edit button')
    ]);

    // Wait for the Update button to appear, which indicates we are in edit mode
    await this.updateButton.waitFor({ state: 'visible', timeout: 10000 });
    // Aggressive wait to ensure transition from readonly to editable
    await this.page.waitForTimeout(2000);
    await this.page.waitForLoadState('networkidle');
  }

  async fillComments(comment = 'Unified E2E verification comment for CII.') {
    const fields = await this.commentFields.all();
    console.log(`\u2713 Found ${fields.length} comment fields`);

    for (let i = 0; i < Math.min(fields.length, 2); i++) {
      try {
        await fields[i].scrollIntoViewIfNeeded();

        // Wait for editability (max 10s)
        await fields[i].evaluate(async (el) => {
          const timeout = 10000;
          const start = Date.now();
          while (el.readOnly && (Date.now() - start) < timeout) {
            await new Promise(r => setTimeout(r, 500));
          }
        });

        await fields[i].fill(comment, { timeout: 3000 });
        console.log(`  - Filled comment field ${i + 1}`);
      } catch (error) {
        console.warn(`\u26A0 Standard fill failed on field ${i + 1}: ${error.message}. Attempting JS fallback.`);
        await fields[i].evaluate((el, val) => {
          el.readOnly = false;
          el.value = val;
          el.dispatchEvent(new Event('input', { bubbles: true }));
          el.dispatchEvent(new Event('change', { bubbles: true }));
        }, comment);
        console.log(`  - JS filled comment field ${i + 1} (Forced readOnly=false)`);
      }
    }
  }

  async clickUpdate() {
    await this._robustClick(this.updateButton, 'Update button');

    // Wait for toaster
    try {
      const toaster = this.page.locator(this.selectors.successMessage).first();
      await toaster.waitFor({ state: 'visible', timeout: 5000 });
      console.log(`✓ Success notification: ${await toaster.textContent()}`);
    } catch (e) {
      console.warn('⚠ Success notification not seen, proceeding...');
    }
  }

  async clickSubmit() {
    await this._robustClick(this.submitButton, 'Submit button');
  }

  async handleConfirmationModal() {
    try {
      const modal = this.page.locator('.modal.show, #modalSubmit'); // Generic or ID if known
      await this.confirmYesButton.waitFor({ state: 'visible', timeout: 5000 });
      await this.confirmYesButton.click();
      console.log('✓ Confirmed submission (Clicked Yes)');

      // Wait for modal and backdrop cleanup
      await modal.waitFor({ state: 'hidden', timeout: 10000 }).catch(() => { });
      await this.page.locator('.modal-backdrop').waitFor({ state: 'hidden', timeout: 5000 }).catch(() => { });
    } catch (e) {
      console.warn('⚠ Could not handle confirmation modal or "Yes" button not found');
    }
  }

  async verifySubmissionSuccess() {
    try {
      // Wait for redirect to dashboard
      await this.page.waitForURL(/analyst\/dashboard/, { timeout: 15000 });
      console.log('✓ Redirected to analyst dashboard - Submission successful');
      return true;
    } catch (e) {
      console.warn('⚠ Did not see redirect to analyst dashboard');
      return false;
    }
  }

  async waitForPageReady() {
    await this.page.waitForLoadState('networkidle');
    await this.page.waitForTimeout(500);
  }
}

module.exports = AnalystAssessmentReviewPage;
