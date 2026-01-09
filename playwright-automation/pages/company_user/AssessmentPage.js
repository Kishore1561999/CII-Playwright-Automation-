const BasePage = require('../BasePage');

class AssessmentPage extends BasePage {
    constructor(page) {
        super(page);
        this.instructionsModal = page.locator('#modalInstructions');
        this.closeInstructionsButton = this.instructionsModal.locator('button.btn-close');
        this.aspectLink = page.locator('[id="0-list"]');
        this.aspectNextButtonLocator = page.locator('.btn.btn-primary.next.float-right');
        this.corporateGovernanceRadioButton = (index) => page.locator(`#cg_${index}_No_information_available`);
        this.businessEthicsRadioButton = (index) => page.locator(`#be_${index}_No_information_available`);
        this.riskManagementRadioButton = (index) => page.locator(`#rm_${index}_No_information_available`);
        this.transparencyDisclosureRadioButton = (index) => page.locator(`#td_${index}_No_information_available`);
        this.humanRightsRadioButton = (index) => page.locator(`#hr_${index}_No_information_available`);
        this.humanCapitalRadioButton = (index) => page.locator(`#hc_${index}_No_information_available`);
        this.ohsRadioButton = (index) => page.locator(`#ohs_${index}_No_information_available`);
        this.csrRadioButton = (index) => page.locator(`#csr_${index}_No_information_available`);
        this.environmentManagementRadioButton = (index) => page.locator(`#em_${index}_No_information_available`);
        this.supplyChainRadioButton = (index) => page.locator(`#sc_${index}_No_information_available`);
        this.bioDiversityRadioButton = (index) => page.locator(`#bd_${index}_No_information_available`);
        this.productResponsibilityRadioButton = (index) => page.locator(`#pr_${index}_No_information_available`);
        this.saveButton = page.locator('button.save_assessment');
        this.submitButton = page.locator('button.submit_assessment');
        this.confirmSubmitButton = page.locator('#modalSubmit button#submit_assessment');
        this.saveSuccessToast = page.locator('div.toast-message', { hasText: 'Saved successfully' });
        this.submitSuccessToast = page.locator('div.toast-message', { hasText: 'Assessment Submitted Successfully' });
    }

    async closeInstructions() {
        console.log('Waiting for instructions modal (#modalInstructions)...');
        try {
            // Wait for modal to be visible (with a short timeout)
            await this.instructionsModal.waitFor({ state: 'visible', timeout: 5000 });
            console.log('Instructions modal visible, clicking close button...');

            // Try clicking the close button
            await this.closeInstructionsButton.click();

            // Wait for it to disappear
            await this.instructionsModal.waitFor({ state: 'hidden', timeout: 5000 });
            console.log('Instructions modal closed and hidden.');
        } catch (error) {
            console.log('Instructions modal did not appear or could not be closed within timeout.');
        }
    }

    async selectAspect() {
        console.log('Checking if aspect link exists...');
        const count = await this.aspectLink.count();
        console.log(`Aspect link count: ${count}`);
        if (count > 0) {
            console.log('Clicking aspect link...');
            await this.aspectLink.click();
            console.log('Aspect link clicked.');
        } else {
            console.log('Aspect link NOT found on page.');
            throw new Error('Aspect link [id="0-list"] not found on page.');
        }
    }
    async aspectNextButton() {
        console.log('Clicking aspect next button...');
        await this.aspectNextButtonLocator.click();
        console.log('Aspect next button clicked.');
    }
    async _checkRadioButton(locator) {
        // Ensure the element is visible and scrolled into view
        await locator.waitFor({ state: 'visible', timeout: 10000 });
        
        // Scroll into view to ensure it's not hidden behind overlays
        await locator.scrollIntoViewIfNeeded();
        
        // Add small delay to ensure DOM is stable
        await this.page.waitForTimeout(300);
        
        // Check if the element is disabled
        const isDisabled = await locator.isDisabled();
        if (isDisabled) {
            console.warn(`Radio button is disabled, waiting for it to be enabled...`);
            // Wait for the element to be enabled
            await this.page.waitForFunction((selector) => {
                const el = document.querySelector(selector);
                return el && !el.disabled;
            }, locator.locator(':first-child'));
        }
        
        // Use dblclick as per the previous working pattern if single click is unreliable
        await locator.dblclick({ force: true });
        
        // Verify the click registered by checking if it's now checked
        const isChecked = await locator.isChecked();
        console.log(`Radio button checked status: ${isChecked}`);
    }

    async corporateGovernance(index) {
        await this._checkRadioButton(this.corporateGovernanceRadioButton(index));
    }
    async businessEthics(index) {
        await this._checkRadioButton(this.businessEthicsRadioButton(index));
    }
    async riskManagement(index) {
        await this._checkRadioButton(this.riskManagementRadioButton(index));
    }
    async transparencyDisclosure(index) {
        await this._checkRadioButton(this.transparencyDisclosureRadioButton(index));
    }
    async humanRights(index) {
        await this._checkRadioButton(this.humanRightsRadioButton(index));
    }
    async humanCapital(index) {
        await this._checkRadioButton(this.humanCapitalRadioButton(index));
    }
    async ohs(index) {
        await this._checkRadioButton(this.ohsRadioButton(index));
    }
    async csr(index) {
        await this._checkRadioButton(this.csrRadioButton(index));
    }
    async environmentManagement(index) {
        await this._checkRadioButton(this.environmentManagementRadioButton(index));
    }
    async supplyChain(index) {
        await this._checkRadioButton(this.supplyChainRadioButton(index));
    }
    async bioDiversity(index) {
        await this._checkRadioButton(this.bioDiversityRadioButton(index));
    }
    async productResponsibility(index) {
        await this._checkRadioButton(this.productResponsibilityRadioButton(index));
    }

    async save() {
        await this.saveButton.click();
    }

    async submit() {
        // Wait for submit button to be enabled
        await this.submitButton.waitFor({ state: 'visible', timeout: 10000 });
        
        // Check if button is disabled and wait for it to be enabled
        let isDisabled = await this.submitButton.isDisabled();
        let attempts = 0;
        while (isDisabled && attempts < 10) {
            console.log(`Submit button is disabled, waiting... (attempt ${attempts + 1})`);
            await this.page.waitForTimeout(1000);
            isDisabled = await this.submitButton.isDisabled();
            attempts++;
        }
        
        if (isDisabled) {
            console.error('Submit button is still disabled after 10 seconds. Check if all radio buttons are selected.');
            throw new Error('Submit button remains disabled. All assessment questions may not be answered.');
        }
        
        console.log('Submit button is now enabled, proceeding with submit...');
        await this.submitButton.click();
        // Wait for and click the confirmation "Yes" button in the modal
        await this.confirmSubmitButton.waitFor({ state: 'visible', timeout: 5000 });
        await this.confirmSubmitButton.click();
        console.log('Clicked submit and confirmed assessment submission.');
    }
}

module.exports = AssessmentPage;
