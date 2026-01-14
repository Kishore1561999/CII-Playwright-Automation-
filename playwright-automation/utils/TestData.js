const fs = require('fs');
const path = require('path');

class TestData {
    static get filePath() {
        return path.join(__dirname, 'test-data.json');
    }

    static save(data) {
        let currentData = {};
        if (fs.existsSync(this.filePath)) {
            currentData = JSON.parse(fs.readFileSync(this.filePath, 'utf8'));
        }
        const newData = { ...currentData, ...data };
        fs.writeFileSync(this.filePath, JSON.stringify(newData, null, 2));
    }

    static load() {
        if (fs.existsSync(this.filePath)) {
            return JSON.parse(fs.readFileSync(this.filePath, 'utf8'));
        }
        return {};
    }

    static clear() {
        if (fs.existsSync(this.filePath)) {
            fs.unlinkSync(this.filePath);
        }
    }
}

module.exports = TestData;
