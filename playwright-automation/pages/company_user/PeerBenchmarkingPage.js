const BasePage = require('../BasePage');

class PeerBenchmarkingPage extends BasePage {
    constructor(page) {
        super(page);
        // Navigation
        this.peerBenchmarkingLink = page.locator('a[href="/company_user/peer_benchmarking"]');

        // User Guide Modal
        this.userGuideModal = page.locator('div.modal-content').filter({ has: page.locator('#userGuideModalLabel') });
        this.userGuideCloseBtn = page.locator('button.create-cookies[data-bs-dismiss="modal"]');

        // Consent
        this.consentCheckbox = page.locator('input#consent_form');

        // Provide Data Selection
        this.provideDataCard = page.locator('#provideDataCard');

        // Sector Confirmation Modal
        this.sectorConfirmModal = page.locator('.modal_header_text', { hasText: 'Please re-confirm the sector' });
        this.sectorConfirmBtn = page.locator('#updateUserDataBtn');

        this.nextBtn = page.locator('button.next');

        this.answerOption = (index) => page.locator(`#pb_${index}_No_information`);
        this.answerOption2 = (index) => page.locator(`#pb_${index}_No_clear_information`);
        this.answerOption3 = (index) => page.locator(`#pb_${index}_No_information_available`);
        // this.answerOptions = (index) => {
        //     const pIndex = index.toString().padStart(2, '0');
        //     return page.locator(`input[name^="answer-PB-${pIndex}-"]`)
        //         .locator('xpath=..')
        //         .filter({ hasText: /No\s/i })
        //         .locator('input')
        //         .first();
        // };

        this.savebtn = page.locator('button.save_assessment');

        this.runAnalyticsBtn = page.locator('#runAnalytics_download');

    }

    async navigateToPeerBenchmarking() {
        await this.peerBenchmarkingLink.click();
        // Wait for modal might be a good implicit check, or load state
        await this.page.waitForLoadState('networkidle');
        console.log('✓ Navigated to Peer Benchmarking');
    }

    async handleUserGuideModal() {
        try {
            await this.userGuideCloseBtn.waitFor({ state: 'visible', timeout: 5000 });
            await this.userGuideCloseBtn.click();
            await this.userGuideCloseBtn.waitFor({ state: 'hidden', timeout: 5000 });
            console.log('✓ Closed User Guide Modal');
        } catch (e) {
            console.log('ℹ User Guide Modal did not appear or was already closed');
        }
    }

    async acceptConsent() {
        await this.consentCheckbox.waitFor({ state: 'visible' });
        if (!(await this.consentCheckbox.isChecked())) {
            await this.consentCheckbox.check();
            console.log('✓ Accepted Consent');
        } else {
            console.log('ℹ Consent already accepted');
        }
    }

    async clickProvideData() {
        await this.provideDataCard.waitFor({ state: 'visible' });
        await this.provideDataCard.click();
        console.log('✓ Clicked Provide & Edit Data');
    }

    async confirmSector() {
        try {
            // Wait for modal to appear
            await this.sectorConfirmBtn.waitFor({ state: 'visible', timeout: 5000 });
            await this.sectorConfirmBtn.click();
            await this.sectorConfirmBtn.waitFor({ state: 'hidden', timeout: 5000 });
            console.log('✓ Confirmed Sector');
        } catch (e) {
            console.log('ℹ Sector confirmation modal did not appear');
        }
    }

    async _checkRadioButtonPB(locator) {
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

    async fillPeerBenchmarkQuestions(index) {
        // await this._checkRadioButtonPB(this.answerOptions(index));
        await this.answerOption(index).dblclick({ force: true });
    }

    async fillPeerBenchmarkQuestions2(index) {
        // await this._checkRadioButtonPB(this.answerOptions(index));
        await this.answerOption2(index).dblclick({ force: true });
    }

    async fillPeerBenchmarkQuestions3(index) {
        // await this._checkRadioButtonPB(this.answerOptions(index));
        await this.answerOption3(index).dblclick({ force: true });
    }

    async nextButton() {
        await this.nextBtn.click();
    }

    async saveButton() {
        await this.savebtn.click();
    }

    async runAnalytics() {
        await this.runAnalyticsBtn.click();
    }

    async closeSuccessMessage() {
        try {
            // Success message snippet: "Report generated successfully and report has been sent to your mail"
            const successMsg = this.page.getByText('Report generated successfully');
            const closeBtn = this.page.locator('button', { hasText: '×' }).first();
            if (await successMsg.isVisible()) {
                await closeBtn.click();
                await successMsg.waitFor({ state: 'hidden', timeout: 5000 });
                console.log('✓ Closed analytics success message');
            }
        } catch (e) {
            console.log('ℹ Success message was not visible or already closed');
        }
    }
}

module.exports = PeerBenchmarkingPage;
