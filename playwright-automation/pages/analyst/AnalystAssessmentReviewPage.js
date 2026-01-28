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
    await this.editButton.waitFor({ state: 'visible', timeout: 5000 });
    await this.editButton.click();
    await this.page.waitForLoadState('networkidle');
    console.log('✓ Clicked Edit button');
  }

  async fillComments(comment = 'Automated review comment') {
    const fields = await this.commentFields.all();
    console.log(`✓ Found ${fields.length} comment fields`);
    for (let i = 0; i < Math.min(fields.length, 2); i++) {
      await fields[i].fill(comment);
      console.log(`  - Filled comment field ${i + 1}`);
    }
  }

  async clickUpdate() {
    await this.updateButton.waitFor({ state: 'visible', timeout: 5000 });
    await this.updateButton.click();
    console.log('✓ Clicked Update button');

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
    await this.submitButton.waitFor({ state: 'visible', timeout: 5000 });
    await this.submitButton.click();
    console.log('✓ Clicked Submit button');
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
